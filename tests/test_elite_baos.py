#!/usr/bin/env python3
"""Execute the assembled gauntlet routines in PyBoy, without a player save.

Build both ROMs, install pyboy in a virtualenv, then run:
    python tests/test_elite_baos.py
Rendering, sound, and player-facing delays are disabled. Gameplay routines run
as assembled; only text, music and delay routines are stubbed for scripted input.
"""
import re
from pathlib import Path

from pyboy import PyBoy

ROOT = Path(__file__).resolve().parents[1]


def enum_names(path, macro):
    return {name: i for i, name in enumerate(re.findall(
        rf'^\s*{macro}\s+(\w+)', (ROOT / path).read_text(), re.M))}


TRAINERS = enum_names('constants/trainer_constants.asm', 'trainer_const')
MAPS = enum_names('constants/map_constants.asm', 'map_const')
SPECIES = enum_names('constants/pokemon_constants.asm', 'const')


class Machine:
    def __init__(self, rom):
        self.symbols = {}
        for line in (ROOT / rom).with_suffix('.sym').read_text().splitlines():
            if not line or line.startswith(';'):
                continue
            loc, name = line.split()
            if ':' in loc:
                bank, addr = loc.split(':')
                self.symbols[name] = int(bank, 16), int(addr, 16)
        self.pyboy = PyBoy(str(ROOT / rom), window='null', sound_emulated=False,
                           log_level='ERROR')
        self.pyboy.set_emulation_speed(0)
        self.mem = self.pyboy.memory
        self.reg = self.pyboy.register_file
        self.mem[0xff50] = 1  # disable boot ROM
        self.mem[0xffff] = 0  # interrupts off for isolated routine calls
        self.mem[0xff40] = 0  # LCD off
        self.mem[0xc010:0xc012] = [0x18, 0xfe]  # return trampoline: jr self
        self.set('hRandomAdd', 123)
        self.set('hRandomSub', 87)
        self.set('hRandomLast', 45)
        for name in ('DelayFrames', 'PlayTrainerMusic'):
            self.stub(name)

    def addr(self, name):
        return self.symbols[name][1]

    def get(self, name):
        return self.mem[self.addr(name)]

    def set(self, name, value):
        self.mem[self.addr(name)] = value

    def stub(self, name):
        bank, addr = self.symbols[name]
        self.mem[bank, addr] = 0xc9  # ret

    def call(self, name, offset=0):
        bank, addr = self.symbols[name]
        self.mem[0x2000] = bank or 1
        self.set('hLoadedROMBank', bank or 1)
        self.reg.SP = 0xdffc  # real stack region, outside scratch buffers
        self.mem[0xdffc:0xdffe] = [0x10, 0xc0]
        self.reg.PC = addr + offset
        for _ in range(100):
            self.pyboy.tick(1, False)
            if self.reg.PC == 0xc010:
                return
        raise AssertionError(f'{name} did not return: PC={self.reg.PC:04x}, bank={self.get("hLoadedROMBank"):02x}')

    def rom_bytes(self, name, count):
        bank, addr = self.symbols[name]
        return self.mem[bank, addr:addr + count]


def check_rom(rom):
    vm = Machine(rom)
    try:
        m = vm.mem
        vm.set('wCurMap', MAPS['BATTLE_HALL'])
        vm.set('wPartyCount', 6)
        vm.set('wYCoord', 6)
        flags = vm.addr('wToggleableObjectFlagsCont')
        # Simulate an older save: newly allocated toggle flags start cleared.
        m[flags:flags + 32] = [0] * 32
        vm.set('wCurrentMapScriptFlags', 1 << 3)
        table_bank, table = vm.symbols['BattleHallToggleData']
        _, base = vm.symbols['ToggleableObjectStatesCont']
        toggle_start = (table - base) // 3
        # Both constants and the map's toggle list must identify the same NPCs.
        entries = vm.rom_bytes('BattleHallToggleData', 33)
        assert entries[1::3] == list(range(1, 12))
        vm.call('MarkTownVisitedAndLoadToggleableObjects')
        local_toggles = vm.addr('wToggleableObjectList')
        assert m[local_toggles:local_toggles + 22][::2] == list(range(1, 12))
        assert m[local_toggles:local_toggles + 22][1::2] == list(range(toggle_start, toggle_start + 11)), (toggle_start, m[local_toggles:local_toggles+23])
        # Supply the actual map's trainer extra data for EngageMapTrainer.
        extra = vm.addr('wMapSpriteExtraData')
        for obj in range(1, 12):
            apprentice = obj == 2
            cls = TRAINERS['BAO_APPRENTICE' if apprentice else 'ELITE_BAO']
            number = 1 if obj <= 2 else obj - 1
            m[extra + (obj - 1) * 2:extra + obj * 2] = [200 + cls, number]
        parties = (ROOT / 'data/trainers/parties.asm').read_text().split('EliteBaoData:')[1]
        fixed, fixed_levels = [], []
        for line in parties.splitlines():
            if 'db $FF' not in line:
                continue
            fields = [item.strip() for item in line.split(';', 1)[0].split('db $FF,', 1)[1].split(',')]
            assert len(fields) == 13 and fields[-1] == '0', line
            fixed.append(fields[1:-1:2])
            fixed_levels.append([int(level) for level in fields[:-1:2]])
        assert len(fixed) == 10 and all(len(team) == 6 for team in fixed)
        # Validate every pool entry against assembled evolution data, and
        # ensure no eligible final/single-stage species was accidentally lost.
        _, pool_start = vm.symbols['BaoApprenticeMons']
        _, pool_end = vm.symbols['BaoApprenticeMonsEnd']
        pool = set(vm.rom_bytes('BaoApprenticeMons', pool_end - pool_start))
        evo_bank, _ = vm.symbols['EvosMovesPointerTable']
        pointers = vm.rom_bytes('EvosMovesPointerTable', (len(SPECIES) - 1) * 2)
        dex = vm.rom_bytes('PokedexOrder', len(SPECIES) - 1)
        forbidden = {SPECIES[n] for n in ('PSYDUCK', 'ODOS_PSYDUCK',
                     'FOSSIL_KABUTOPS', 'FOSSIL_AERODACTYL', 'MON_GHOST')}
        expected_pool = set()
        for species in range(1, len(SPECIES)):
            ptr = pointers[(species - 1) * 2] | pointers[(species - 1) * 2 + 1] << 8
            if dex[species - 1] and species not in forbidden and m[evo_bank, ptr] == 0:
                expected_pool.add(species)
        assert pool == expected_pool
        assert pool_end - pool_start == len(pool)  # no duplicate weighting
        apprentice_teams = set()
        hp_addr, pp_addr = vm.addr('wPartyMon1HP'), vm.addr('wPartyMon1PP')
        m[hp_addr:hp_addr + 2] = [0, 7]
        m[pp_addr:pp_addr + 4] = [1, 2, 3, 4]
        for battle in range(20):
            vm.set('wBattleHallState', battle << 3)
            vm.call('BattleHallSetUpScript')
            vm.call('BattleHallSetUpScript')  # ordinary idle frames preserve progress
            assert vm.get('wBattleHallState') == battle << 3
            expected_obj = 2 if battle % 2 == 0 else (1 if battle == 1 else battle // 2 + 2)
            visible = [i + 1 for i in range(11)
                       if not (m[flags + (toggle_start + i) // 8] & (1 << ((toggle_start + i) % 8)))]
            assert visible == [expected_obj], (battle, visible)
            vm.set('wSpriteIndex', expected_obj)
            vm.call('BattleHallStartBattleScript')
            cls = TRAINERS['ELITE_BAO' if battle % 2 else 'BAO_APPRENTICE']
            assert vm.get('wCurOpponent') == 200 + cls
            assert vm.get('wTrainerNo') == battle // 2 + 1
            assert vm.get('wBattleHallState') == (battle << 3) | 4
            vm.set('wTrainerClass', cls)
            vm.call('GetTrainerName')
            if battle % 2:
                name = 'BAO SNOOPY' if battle == 1 else f'BAO FILLER{battle // 2 + 1}'
                assert len('ELITE ' + name) <= 18  # title fits on one battle row
                assert len(name + ': ') <= 14  # defeat prefix fits separately
                expected_name = [0x80 + ord(c) - ord('A') if c.isalpha()
                                 else 0x7f if c == ' ' else 0xf6 + int(c)
                                 for c in name] + [0x50]
                name_addr = vm.addr('wTrainerName')
                assert m[name_addr:name_addr + len(expected_name)] == expected_name
                # Defeat-text name lookup must retain the personal name too.
                vm.call('SaveTrainerName')
                buf = vm.addr('wNameBuffer')
                assert m[buf:buf + len(expected_name)] == expected_name
            vm.call('ReadTrainer')
            assert vm.get('wEnemyPartyCount') == 6
            team = tuple(m[vm.addr('wEnemyPartySpecies'):vm.addr('wEnemyPartySpecies') + 6])
            # All gauntlet opponents, including fixed teams, must be final/single-stage.
            assert set(team) <= pool
            if battle % 2 == 0:
                apprentice_teams.add(team)
                assert set(team) <= pool
                assert not set(team) & forbidden
            else:
                assert team == tuple(SPECIES[n] for n in fixed[battle // 2])
            for member in range(1, 7):
                expected_level = fixed_levels[battle // 2][member - 1] if battle % 2 else 110
                assert vm.get(f'wEnemyMon{member}Level') == expected_level
                ev = vm.addr(f'wEnemyMon{member}HPExp')
                assert m[ev:ev + 10] == [255] * 10
                hp, maximum = vm.addr(f'wEnemyMon{member}HP'), vm.addr(f'wEnemyMon{member}MaxHP')
                assert m[hp:hp + 2] == m[maximum:maximum + 2] != [0, 0]
            vm.set('wBattleResult', 0)
            vm.call('BattleHallPostBattleScript')
            assert vm.get('wBattleHallState') == (battle + 1) << 3
            assert m[hp_addr:hp_addr + 2] == [0, 7]
            assert m[pp_addr:pp_addr + 4] == [1, 2, 3, 4]
        assert len(apprentice_teams) == 10
        vm.call('BattleHallSetUpScript')
        assert vm.get('wBattleHallState') == 20 << 3
        # The real save writer and loader must round-trip progress and party data.
        for progress in (0, 1, 9, 18, 19, 20):
            vm.set('wBattleHallState', progress << 3)
            vm.call('SaveMainData')
            vm.call('SavePartyAndDexData')
            vm.set('wBattleHallState', 0)
            m[hp_addr:hp_addr + 2] = [0, 0]
            vm.call('LoadMainData')
            vm.call('LoadPartyAndDexData')
            assert vm.get('wBattleHallState') == progress << 3
            assert m[hp_addr:hp_addr + 2] == [0, 7]
        vm.set('wBattleHallState', (8 << 3) | 4)
        vm.set('wBattleResult', 1)
        vm.call('BattleHallPostBattleScript')
        assert vm.get('wBattleHallState') == 0
        # Isolate menu choice while executing the real exit script body.
        vm.stub('PrintText')
        vm.stub('YesNoChoice')
        # RST pushes a return address to the following text bytes.
        # Discard that address, then return to the test caller.
        m[0, vm.addr('TextScriptEnd'):vm.addr('TextScriptEnd') + 2] = [0xe1, 0xc9]
        for choice in (1, 0):
            vm.set('wCurrentMenuItem', choice)
            vm.set('wJoyIgnore', 0)
            vm.set('hWarpDestinationMap', 123)
            vm.set('wBattleHallState', 9 << 3)
            vm.call('BattleHallExitText', offset=1)  # skip text_asm bytecode
            if choice:
                assert vm.get('wBattleHallState') == (9 << 3) | 5
                assert vm.get('wSimulatedJoypadStatesIndex') == 1
                vm.set('wSimulatedJoypadStatesIndex', 0)
                vm.call('BattleHallExitPromptScript')
                assert vm.get('wBattleHallState') == 9 << 3
            else:
                assert vm.get('wBattleHallState') == 6
                assert vm.get('wJoyIgnore') == 0  # dialog can still close
                assert vm.get('wDoNotWaitForButtonPressAfterDisplayingText') == 1
                assert vm.get('hWarpDestinationMap') == 123
                # Model text cleanup clobbering shared HRAM before next frame.
                vm.set('hWarpDestinationMap', 77)
                vm.call('BattleHallExitWarpScript')
                assert vm.get('wBattleHallState') == 0
                assert vm.get('wJoyIgnore') == 255
                assert vm.get('hWarpDestinationMap') == MAPS['ROUTE_22_GATE']
                assert vm.get('wDestinationWarpID') == 8
        # Global reset also covers poison-induced whiteouts outside battle.
        vm.set('wBattleHallState', 18 << 3)
        # Use a valid party for the normal blackout healing routine.
        party, enemy = vm.addr('wPartyMons'), vm.addr('wEnemyMons')
        m[party:party + 6 * 44] = m[enemy:enemy + 6 * 44]
        species, enemy_species = vm.addr('wPartySpecies'), vm.addr('wEnemyPartySpecies')
        m[species:species + 7] = m[enemy_species:enemy_species + 7]
        vm.call('ResetStatusAndHalveMoneyOnBlackout')
        assert vm.get('wBattleHallState') == 0
        # Both gauntlet classes must request a real whiteout, not an exhibition loss.
        for cls in ('ELITE_BAO', 'BAO_APPRENTICE'):
            vm.set('wCurOpponent', 200 + TRAINERS[cls])
            vm.call('HandlePlayerBlackOut')
            assert vm.reg.F & 0x10  # carry requests the normal whiteout
        # Item and field Softboiled entry points cannot heal during the run.
        for item in (1, 20, 80, 255):
            vm.set('wCurItem', item)
            vm.call('UseItem_')
            assert vm.get('wActionResultOrTookBattleTurn') == 0
        vm.call('ItemUseMedicine')
        assert vm.get('wActionResultOrTookBattleTurn') == 0
        vm.set('wBattleHallState', 8)
        # PC access stays available mid-run; bypass only its text interpreter.
        vm.stub('PrintPredefTextID')
        vm.set('wSpritePlayerStateData1FacingDirection', 4)  # up at the PC
        vm.set('wAutoTextBoxDrawingControl', 99)
        vm.call('OpenPokemonCenterPC')
        assert vm.get('wAutoTextBoxDrawingControl') == 1
        assert vm.get('wBattleHallState') == 8
        # The ordinary warp must never bypass confirmation.
        vm.call('TryWarpAtPlayerCoord')
        assert not vm.reg.F & 0x10
        vm.stub('DisplayTextID')
        vm.set('wBattleHallState', 8)
        vm.set('wCurrentMapScriptFlags', 1 << 3)
        vm.set('wYCoord', 9)
        vm.set('wXCoord', 11)
        vm.set('wSpritePlayerStateData1FacingDirection', 0)  # down
        # Arriving on the stair facing down must walk into the room, not prompt.
        vm.set('hTextID', 99)
        vm.call('BattleHallSetUpScript')
        assert vm.get('hTextID') == 99
        assert vm.get('wBattleHallState') == 8 | 5
        assert vm.get('wSimulatedJoypadStatesIndex') == 1
        vm.set('wSimulatedJoypadStatesIndex', 0)
        vm.call('BattleHallExitPromptScript')
        # Returning to the stair prompts from above, left, right or below.
        # Include a completed run, whose map-load flag must also clear.
        for progress in (8, 20 << 3):
            vm.set('wBattleHallState', progress)
            vm.set('wYCoord', 8)
            vm.set('wCurrentMapScriptFlags', 1 << 3)
            vm.call('BattleHallSetUpScript')
            assert not vm.get('wCurrentMapScriptFlags') & (1 << 3)
            vm.set('wYCoord', 9)
            for facing in (0, 4, 8, 12):
                vm.set('hTextID', 99)
                vm.set('wSpritePlayerStateData1FacingDirection', facing)
                vm.call('BattleHallSetUpScript')
                assert vm.get('hTextID') == 13
                assert vm.get('wBattleHallState') == progress
        # Other special trainers must retain their authored parties.
        vm.set('wTrainerClass', TRAINERS['BROCK'])
        vm.set('wTrainerNo', 1)
        vm.call('ReadTrainer')
        assert vm.get('wEnemyPartyCount') == 5
        assert vm.get('wEnemyMon1Level') == 12
        print(f'{rom}: 20 encounters, teams/stats, HP/PP endurance, save/load, exit and whiteout PASS')
    finally:
        vm.pyboy.stop(save=False)


def check_dialogue_widths():
    source = (ROOT / 'text/BattleHall.asm').read_text()
    label = ''
    for line in source.splitlines():
        if line.endswith('::'):
            label = line[:-2]
        match = re.match(r'\s*(text|line|cont|para) "([^"]*)"', line)
        if match:
            width = len(match[2].replace('#', 'POKé').replace('@', ''))
            limit = 15 if label == '_EliteBaoWantsToFightText' else 14
            assert width <= limit, (label, width, match[2])
    for i in range(1, 11):
        assert f'_EliteBao{i}DefeatedText::\n\ttext_start\n\tline ' in source
    assert '_ApprenticeDefeatedText::\n\ttext_start\n\tline ' in source
    odo = (ROOT / 'text/MtSilver3F.asm').read_text().split('_MtSilver3FYellowDefeatedText::', 1)[1]
    odo = odo.split('\n\n;text', 1)[0]
    for match in re.finditer(r'\s*(?:text|line|cont|para) "([^"]*)"', odo):
        assert len(match[1]) <= 14, match[1]
    for phrase in ('Wow you beat', 'me.', 'ELITE BAO', 'ROUTE 22', 'VIRIDIAN CITY.',
                   'ROUTE 23.', 'on floor 3.', 'Contact ODO', 'favorite team'):
        assert phrase in odo


if __name__ == '__main__':
    check_dialogue_widths()
    for target in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(target)
