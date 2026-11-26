#!/usr/bin/env python3
"""Check charge-turn damage and reflected damage in both assembled ROMs."""
from test_elite_baos import Machine, ROOT
from test_rage_effect import EFFECTS, MOVES
import re


MULTIPLIER = int(re.search(
    r'DEF RETALIATE_DAMAGE_MULTIPLIER EQU (\d+)',
    (ROOT / 'constants/battle_constants.asm').read_text())[1])
CHARGING_UP, INVULNERABLE = 1 << 4, 1 << 6


def check_rom(rom):
    vm = Machine(rom)
    try:
        for name in ('PrintText', 'PlayBattleAnimation', 'PlayCurrentMoveAnimation'):
            vm.stub(name)

        messages = []
        vm.pyboy.hook_register(*vm.symbols['PrintText'],
                               lambda _: messages.append(vm.reg.HL), None)

        def word(name, value):
            addr = vm.addr(name)
            vm.mem[addr:addr + 2] = [value >> 8, value & 255]

        def damage():
            addr = vm.addr('wDamage')
            return vm.mem[addr] * 256 + vm.mem[addr + 1]

        for turn, user, target, mon in ((0, 'Player', 'Enemy', 'Battle'),
                                        (1, 'Enemy', 'Player', 'Enemy')):
            for move, move_type in (('SOLARBEAM', 22), ('SKY_ATTACK', 2),
                                    ('SKULL_BASH', 0), ('FLY', 2), ('DIG', 4)):
                for reflected_move in ('RETALIATE', 'COUNTER'):
                    for stale_damage in (1, 50, 256, 999):
                        vm.set('hWhoseTurn', turn)
                        vm.set('wObtainedBadges', 0)
                        vm.set('wLinkState', 0)
                        vm.set(f'w{user}BattleStatus1', 0)
                        vm.set(f'w{user}BattleStatus2', 0)
                        vm.set(f'w{target}BattleStatus1', 0)
                        # X Accuracy makes the subsequent reflection deterministic.
                        vm.set(f'w{target}BattleStatus2', 1)
                        vm.set(f'w{user}MoveNum', MOVES[move])
                        vm.set(f'w{user}SelectedMove', MOVES[move])
                        vm.set(f'w{user}MovePower', 100)
                        vm.set(f'w{user}MoveType', move_type)
                        vm.set(f'w{user}MoveEffect', EFFECTS['CHARGE_EFFECT'])
                        vm.set(f'w{target}MoveNum', MOVES[reflected_move])
                        vm.set(f'w{target}SelectedMove', MOVES[reflected_move])
                        vm.set(f'w{target}MoveEffect', 0)
                        mods = vm.addr(f'w{user}MonStatMods')
                        vm.mem[mods:mods + 6] = [7] * 6
                        word(f'w{user}MonUnmodifiedDefense', 100)
                        word(f'w{mon}MonDefense', 100)
                        word('wDamage', stale_damage)

                        messages.clear()
                        vm.call('ChargeEffect')
                        expected_messages = [vm.addr('ChargeMoveEffectText')]
                        if move in ('SOLARBEAM', 'SKY_ATTACK', 'SKULL_BASH'):
                            expected_messages.append(vm.addr('ChargeDefenseText'))
                        assert messages == expected_messages, (turn, move, messages)
                        assert damage() == 0, (turn, move, reflected_move, damage())
                        flags = CHARGING_UP | (INVULNERABLE if move in ('FLY', 'DIG') else 0)
                        assert vm.get(f'w{user}BattleStatus1') == flags
                        assert vm.get(f'w{user}MoveEffect') == EFFECTS['CHARGE_EFFECT']
                        assert vm.mem[mods:mods + 6] == [7] * 6

                        vm.set('hWhoseTurn', turn ^ 1)
                        vm.call('HandleCounterMove')
                        assert vm.get('wMoveMissed') == 1
                        assert damage() == 0

                        # After the strike clears charging and supplies fresh damage,
                        # Retaliate reflects either category; Counter only physical.
                        vm.set(f'w{user}BattleStatus1', 0)
                        word('wDamage', 50)
                        vm.call('HandleCounterMove')
                        eligible = reflected_move == 'RETALIATE' or move != 'SOLARBEAM'
                        assert vm.get('wMoveMissed') == (0 if eligible else 1)
                        multiplier = MULTIPLIER if reflected_move == 'RETALIATE' else 2
                        assert damage() == (50 * multiplier if eligible else 50)
        print(f'{rom}: charge turns fail reflection; fresh strike damage reflects correctly '
              '(both sides, all five charge moves, Counter and Retaliate)')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
