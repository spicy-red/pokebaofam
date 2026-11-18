#!/usr/bin/env python3
"""Exercise assembled Nurse Joy box healing, including full SRAM comparisons.

Build red and blue_debug, then run with Python containing pyboy.
Only Nurse Joy's presentation/input is stubbed; healing and checksums run in ROM.
SRAM fixtures are synthetic; the emulator shuts down without saving.
"""
import math

from test_elite_baos import Machine, enum_names


SPECIES = enum_names('constants/pokemon_constants.asm', 'const')
MOVES = enum_names('constants/move_constants.asm', 'const')


def check_rom(rom):
    vm = Machine(rom)
    try:
        m = vm.mem
        box_size = vm.addr('wBoxDataEnd') - vm.addr('wBoxDataStart')
        mon_offset = vm.addr('wBoxMons') - vm.addr('wBoxDataStart')
        mon_size = vm.addr('wBoxMon2') - vm.addr('wBoxMon1')
        fields = {name: vm.addr('wLoadedMon' + name) - vm.addr('wLoadedMon')
                  for name in ('HP', 'BoxLevel', 'Status', 'Moves', 'Exp',
                               'HPExp', 'DVs', 'PP')}

        def select(bank):
            m[0x0000] = 0x0a
            m[0x4000] = bank

        def sram(bank):
            select(bank)
            return list(m[0xa000:0xc000])

        def run(name):
            bank, addr = vm.symbols[name]
            m[0x2000] = bank
            vm.set('hLoadedROMBank', bank)
            vm.reg.SP = 0xdffc
            m[0xdffc:0xdffe] = [0x10, 0xc0]
            vm.reg.PC = addr
            start = vm.pyboy.frame_count
            for _ in range(6000):
                vm.pyboy.tick(1, False)
                if vm.reg.PC == 0xc010:
                    assert vm.get('hLoadedROMBank') == bank
                    assert vm.reg.SP == 0xdffe
                    return (vm.pyboy.frame_count - start) / 59.7275
            raise AssertionError(f'{name} did not return: PC={vm.reg.PC:04x}, '
                                 f'bank={vm.get("hLoadedROMBank"):02x}, '
                                 f'SP={vm.reg.SP:04x}')

        def fixture(species, level, stat_exp, dvs, ppups):
            vm.set('wCurSpecies', SPECIES[species])
            vm.call('GetMonHeader')
            base_hp = vm.get('wMonHBaseHP')
            vm.reg.D = level
            vm.call('CalcExperience')
            exp = list(m[vm.addr('hExperience'):vm.addr('hExperience') + 3])
            mon = [0x37] * mon_size
            mon[0] = SPECIES[species]
            mon[fields['HP']:fields['HP'] + 2] = [0, 0]
            mon[fields['BoxLevel']] = level
            mon[fields['Status']] = 0x88
            mon[fields['Exp']:fields['Exp'] + 3] = exp
            mon[fields['HPExp']:fields['HPExp'] + 2] = list(stat_exp.to_bytes(2, 'big'))
            mon[fields['DVs']:fields['DVs'] + 2] = dvs
            moves = [MOVES[n] for n in ('SPLASH', 'RECOVER', 'TACKLE')] + [0]
            mon[fields['Moves']:fields['Moves'] + 4] = moves
            mon[fields['PP']:fields['PP'] + 4] = [n * 64 + 1 for n in ppups] + [0x81]
            healed = mon.copy()
            iv = ((dvs[0] >> 4 & 1) << 3 | (dvs[0] & 1) << 2 |
                  (dvs[1] >> 4 & 1) << 1 | dvs[1] & 1)
            root = math.isqrt(stat_exp)
            bonus = min(255, root + (root * root != stat_exp)) // 4
            hp = ((base_hp + iv) * 2 + bonus) * level // 100 + level + 10
            healed[fields['HP']:fields['HP'] + 2] = list(hp.to_bytes(2, 'big'))
            healed[fields['Status']] = 0
            for i, move in enumerate(moves[:3]):
                base = vm.rom_bytes('Moves', move * 6)[(move - 1) * 6 + 5]
                healed[fields['PP'] + i] = ppups[i] * 64 + base + min(7, base // 5) * ppups[i]
            return mon, healed

        examples = [fixture('CHANSEY', 100, 65535, [0xff, 0xff], [0, 1, 3]),
                    fixture('BULBASAUR', 37, 1001, [0x12, 0x34], [3, 2, 1]),
                    fixture('PIKACHU', 12, 0, [0x88, 0x88], [2, 0, 2])]

        def box(slots, legacy=False):
            before = [0x59] * box_size
            before[0] = len(slots)
            before[1:22] = [0] * 20 + [255]
            after = before.copy()
            for slot in slots:
                raw, healed = examples[0 if len(slots) == 20 else slot % len(examples)]
                before[1 + slot] = after[1 + slot] = raw[0]
                start = mon_offset + slot * mon_size
                before[start:start + mon_size] = raw
                after[start:start + mon_size] = healed
            if legacy:
                before[1 + len(slots)] = after[1 + len(slots)] = 255
                # Stale records beyond an old terminator must stay untouched.
                before[2 + len(slots)] = after[2 + len(slots)] = SPECIES['CHANSEY']
            return before, after

        def checksum(data):
            return ~sum(data) & 255

        def update_checksums(data):
            end = vm.addr('sBank2AllBoxesChecksum') - 0xa000
            data[end] = checksum(data[:end])
            for i in range(6):
                data[end + 1 + i] = checksum(data[i * box_size:(i + 1) * box_size])

        for name in ('SaveScreenTilesToBuffer1', 'PrintText', 'YesNoChoicePokeCenter',
                     'LoadScreenTilesFromBuffer1', 'Delay3', 'AnimateHealingMachine',
                     'PlayMusic', 'UpdateSprites'):
            vm.stub(name)

        # New game, sparse/legacy boxes, and all 240 mons. Deliberately leave
        # unoccupied records and unrelated SRAM filled with nonzero canaries.
        for case, initialized, slots, legacy in (
                ('uninitialized SRAM', False, [0, 9, 19], False),
                ('sparse boxes', True, [0, 9, 19], False),
                ('legacy boxes', True, [0, 1, 2], True),
                ('full boxes', True, list(range(20)), False),
                ('empty boxes', True, [], False)):
            current = 8
            banks = [[(i * 13 + bank * 31) & 255 for i in range(8192)]
                     for bank in range(4)]
            expected = [data.copy() for data in banks]
            for bank in (2, 3):
                for i in range(6):
                    # The active box is absent from the inactive-box banks.
                    raw, healed = box([] if (bank - 2) * 6 + i == current else slots, legacy)
                    start = i * box_size
                    banks[bank][start:start + box_size] = raw
                    expected[bank][start:start + box_size] = healed if initialized else raw
                update_checksums(banks[bank])
                if initialized:
                    update_checksums(expected[bank])
                else:
                    expected[bank] = banks[bank].copy()
            for bank in range(4):
                select(bank)
                m[0xa000:0xc000] = banks[bank]
            m[0x0000] = 0
            raw, healed = box(slots, legacy)
            start = vm.addr('wBoxDataStart')
            m[start:start + box_size] = raw
            vm.set('wCurrentBoxNum', current | (0x80 if initialized else 0))
            vm.set('wWhichPokemon', 4)
            vm.set('wMonDataLocation', 2)
            vm.set('wCurrentMenuItem', 0)
            vm.set('wPartyCount', 1)
            vm.set('wPartySpecies', SPECIES['CHANSEY'])
            m[vm.addr('wPartySpecies') + 1] = 255
            vm.set('wPartyMon1Species', SPECIES['CHANSEY'])
            m[vm.addr('wPartyMon1Moves'):vm.addr('wPartyMon1Moves') + 4] = [0] * 4
            vm.set('wPartyMon1Status', 0x40)
            m[vm.addr('wPartyMon1MaxHP'):vm.addr('wPartyMon1MaxHP') + 2] = [2, 191]

            elapsed = run('DisplayPokemonCenterDialogue_')
            assert list(m[start:start + box_size]) == healed, case
            assert vm.get('wCurrentBoxNum') == current | (0x80 if initialized else 0)
            assert vm.get('wMonDataLocation') == 2
            assert list(m[vm.addr('wPartyMon1HP'):vm.addr('wPartyMon1HP') + 2]) == [2, 191]
            assert vm.get('wPartyMon1Status') == 0
            for bank in range(4):
                actual = sram(bank)
                assert actual == expected[bank], (case, bank,
                    next((hex(0xa000 + i), a, e) for i, (a, e) in
                         enumerate(zip(actual, expected[bank])) if a != e))
            print(f'{rom}: {case}: fields, SRAM canaries and checksums passed '
                  f'({elapsed:.2f}s emulated, presentation disabled)', flush=True)

        # Declining Nurse Joy must leave every box and all SRAM unchanged.
        vm.set('wCurrentMenuItem', 1)
        raw, _ = box([0, 9, 19])
        m[start:start + box_size] = raw
        snapshots = [sram(bank) for bank in range(4)]
        run('DisplayPokemonCenterDialogue_')
        assert list(m[start:start + box_size]) == raw
        assert [sram(bank) for bank in range(4)] == snapshots

        # Normal save/load preserves the healed live box and main checksum.
        vm.set('wCurrentMenuItem', 0)
        run('HealAllBoxes')
        live = list(m[start:start + box_size])
        vm.call('SaveGameData')
        save = sram(1)
        lo, hi = vm.addr('sGameData') - 0xa000, vm.addr('sGameDataEnd') - 0xa000
        assert checksum(save[lo:hi]) == save[vm.addr('sMainDataCheckSum') - 0xa000]
        m[start:start + box_size] = [0] * box_size
        vm.call('LoadCurrentBoxData')
        assert not vm.reg.F & 0x10
        assert list(m[start:start + box_size]) == live
        assert vm.get('wCurrentBoxNum') == current | 0x80
        print(f'{rom}: declined healing and save/load passed', flush=True)

        # Run the real box-copy path in both directions and across both banks.
        # Newly loaded boxes must retain their healed HP/status/PP and names.
        for bank in (2, 3):
            select(bank)
            for slot in range(6):
                raw, _ = box([] if (bank - 2) * 6 + slot == current else [0, 9, 19])
                addr = 0xa000 + slot * box_size
                m[addr:addr + box_size] = raw
        run('HealAllBoxes')
        _, expected_box = box([0, 9, 19])
        for target in (0, 6, 11, current):
            vm.call('GetBoxSRAMLocation')
            vm.reg.D, vm.reg.E = vm.reg.HL >> 8, vm.reg.HL & 255
            vm.reg.HL = start
            vm.call('CopyBoxToOrFromSRAM')
            vm.set('wCurrentBoxNum', target | 0x80)
            vm.call('GetBoxSRAMLocation')
            vm.reg.D, vm.reg.E = start >> 8, start & 255
            vm.call('CopyBoxToOrFromSRAM')
            assert list(m[start:start + box_size]) == expected_box
            for bank in (2, 3):
                data = sram(bank)
                expected_sums = data.copy()
                update_checksums(expected_sums)
                assert data == expected_sums
        print(f'{rom}: switching healed boxes across SRAM banks passed', flush=True)
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
