#!/usr/bin/env python3
"""Check end-of-turn Rage boosts and message dispatch in assembled ROMs.

Build red and blue_debug first, then run with a Python environment containing
pyboy. Only text and animation routines are stubbed; stat updates run normally.
"""
import re

from test_elite_baos import Machine, ROOT, enum_names


EFFECTS = {}
effect_index = 0
for line in (ROOT / 'constants/move_effect_constants.asm').read_text().splitlines():
    match = re.match(r'\s*(const_skip|const)\b\s*(\w+)?', line)
    if match:
        if match[1] == 'const':
            EFFECTS[match[2]] = effect_index
        effect_index += 1
MOVES = enum_names('constants/move_constants.asm', 'const')


def check_rom(rom):
    vm = Machine(rom)
    try:
        for name in ('PrintText', 'PlayCurrentMoveAnimation'):
            vm.stub(name)

        def word(name, value):
            addr = vm.addr(name)
            vm.mem[addr:addr + 2] = [value >> 8, value & 255]

        def setup(turn, hp=0, stage=7, effect='RAGE_EFFECT'):
            vm.set('hWhoseTurn', turn)
            vm.set('wObtainedBadges', 0)
            vm.set('wLinkState', 0)
            for prefix, mon in (('Player', 'Battle'), ('Enemy', 'Enemy')):
                vm.set(f'w{prefix}BattleStatus2', 0)
                vm.set(f'w{prefix}MoveNum', MOVES['RAGE'])
                vm.set(f'w{prefix}MoveEffect', EFFECTS[effect])
                mods = vm.addr(f'w{prefix}MonStatMods')
                vm.mem[mods:mods + 6] = [stage, 7, 7, 7, 7, 7]
                word(f'w{prefix}MonUnmodifiedAttack', 100)
                word(f'w{mon}MonAttack', 100)
                vm.set(f'w{mon}MonStatus', 0)
            word('wEnemyMonHP' if turn == 0 else 'wBattleMonHP', hp)

        messages = []

        def record_text(_):
            messages.append((vm.reg.HL,
                             vm.get('hWhoseTurn')))

        vm.pyboy.hook_register(*vm.symbols['PrintText'], record_text, None)
        expected_texts = [vm.addr('BuildingRageText'), vm.addr('MonsStatsRoseText')]

        for turn, user, target, mon in ((0, 'Player', 'Enemy', 'Battle'),
                                        (1, 'Enemy', 'Player', 'Enemy')):
            for hp in (0, 1, 256):
                for stage in (7, 12, 13):
                    setup(turn, hp=hp, stage=stage)
                    word('wBattleMonHP' if turn == 0 else 'wEnemyMonHP', 100)
                    messages.clear()
                    # Activating Rage never boosts mid-action, even on a KO.
                    vm.call('RageEffect')
                    vm.call('RageEffect')
                    assert vm.get(f'w{user}MonStatMods') == stage
                    assert not messages
                    vm.call('HandleEndOfTurnRage')
                    assert vm.get(f'w{user}MonStatMods') == min(stage + 1, 13)
                    assert vm.get(f'w{target}MonStatMods') == stage
                    expected = [(addr, turn) for addr in expected_texts] if stage < 13 else []
                    assert messages == expected, messages
                    if stage == 7:
                        addr = vm.addr(f'w{mon}MonAttack')
                        assert vm.mem[addr:addr + 2] == [0, 150]
                    assert vm.get(f'w{user}MoveNum') == MOVES['RAGE']
                    assert vm.get(f'w{user}MoveEffect') == EFFECTS['RAGE_EFFECT']
                    assert vm.get('hWhoseTurn') == turn

            # No boosts for fainted or non-Rage users.
            setup(turn, hp=100)
            vm.call('RageEffect')
            word('wBattleMonHP' if turn == 0 else 'wEnemyMonHP', 0)
            messages.clear()
            vm.call('HandleEndOfTurnRage')
            assert vm.get(f'w{user}MonStatMods') == 7
            assert not messages
            setup(turn, hp=100)
            vm.call('HandleEndOfTurnRage')
            assert vm.get(f'w{user}MonStatMods') == 7

            # Being hit still boosts immediately, in addition to the turn bonus.
            setup(turn, hp=100)
            word('wBattleMonHP' if turn == 0 else 'wEnemyMonHP', 100)
            vm.call('RageEffect')
            vm.set('hWhoseTurn', turn ^ 1)
            vm.call('HandleBuildingRage')
            assert vm.get(f'w{user}MonStatMods') == 8
            vm.call('HandleEndOfTurnRage')
            assert vm.get(f'w{user}MonStatMods') == 9
            assert vm.get(f'w{target}MonStatMods') == 7

        # Both active Rage users get exactly one turn bonus.
        setup(0, hp=100)
        word('wBattleMonHP', 100)
        vm.call('RageEffect')
        vm.set('hWhoseTurn', 1)
        vm.call('RageEffect')
        messages.clear()
        vm.call('HandleEndOfTurnRage')
        assert vm.get('wPlayerMonStatMods') == 8
        assert vm.get('wEnemyMonStatMods') == 8
        assert messages == [(addr, turn) for turn in (0, 1) for addr in expected_texts]
        assert vm.get('hWhoseTurn') == 1

        # Exercise both move orders through the end of the main turn flow.
        for name in ('MainInBattleLoop', 'DrawHUDsAndHPBars', 'CheckNumAttacksLeft'):
            vm.stub(name)
        for name in ('ExecutePlayerMove', 'ExecuteEnemyMove'):
            bank, addr = vm.symbols[name]
            vm.mem[bank, addr:addr + 3] = [0x06, 0x01, 0xc9]  # ld b,1; ret
        for name in ('TrainerAI', 'HandlePoisonBurnLeechSeed'):
            bank, addr = vm.symbols[name]
            # NZ, no carry: no faint and no AI item action.
            vm.mem[bank, addr:addr + 4] = [0x3e, 0x01, 0xa7, 0xc9]
        for entry in ('MainInBattleLoop.playerMovesFirst', 'MainInBattleLoop.enemyMovesFirst'):
            setup(0, hp=100)
            word('wBattleMonHP', 100)
            vm.set('wEscapedFromBattle', 0)
            vm.call('RageEffect')
            messages.clear()
            vm.call(entry)
            assert vm.get('wPlayerMonStatMods') == 8
            assert messages == [(addr, 0) for addr in expected_texts]

        # A faint also ends the turn before a replacement is sent out.
        for entry, turn, own_hp, target_hp in (
                ('HandleEnemyMonFainted', 0, 'wBattleMonHP', 'wEnemyMonHP'),
                ('HandlePlayerMonFainted', 1, 'wEnemyMonHP', 'wBattleMonHP')):
            bank, addr = vm.symbols[entry]
            assert vm.mem[bank, addr] == 0xcd  # call HandleEndOfTurnRage
            assert vm.mem[bank, addr + 1:addr + 3] == [
                vm.addr('HandleEndOfTurnRage') & 255,
                vm.addr('HandleEndOfTurnRage') >> 8]
            vm.mem[bank, addr + 3] = 0xc9  # stop before faint UI/replacement
            setup(turn)
            word(own_hp, 100)
            word(target_hp, 0)
            vm.call('RageEffect')
            messages.clear()
            vm.call(entry)
            user = 'Enemy' if turn else 'Player'
            assert vm.get(f'w{user}MonStatMods') == 8
            assert messages == [(addr, turn) for addr in expected_texts]
        print(f'{rom}: Rage turn timing, messages, cap, fainting, and hit boost checks passed')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
