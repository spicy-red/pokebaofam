#!/usr/bin/env python3
"""Exercise charge priority, incoming damage, and release timing in assembled ROMs."""
from itertools import product

from test_elite_baos import Machine
from test_rage_effect import EFFECTS, MOVES

BRACING = ('SOLARBEAM', 'SKY_ATTACK', 'SKULL_BASH')
CHARGING, MULTI_HIT = 1 << 4, 1 << 2


def check_rom(rom):
    vm = Machine(rom)
    try:
        def word(name, value):
            addr = vm.addr(name)
            vm.mem[addr:addr + 2] = [value >> 8, value & 255]

        def read_word(name):
            addr = vm.addr(name)
            return vm.mem[addr] * 256 + vm.mem[addr + 1]

        # Run the real ordering code; return an indicator at each chosen branch.
        for label, result in (('playerMovesFirst', 0), ('enemyMovesFirst', 1)):
            bank, addr = vm.symbols[f'MainInBattleLoop.{label}']
            vm.mem[bank, addr:addr + 3] = [0x3e, result, 0xc9]
        moves = BRACING + ('FLY', 'DIG', 'QUICK_ATTACK', 'TACKLE', 'RETALIATE', 'COUNTER')

        def priority(move, charging):
            if move == 'QUICK_ATTACK' or (move in BRACING and not charging):
                return 1
            return -1 if move in ('RETALIATE', 'COUNTER') else 0

        count = 0
        for player, enemy, pcharge, echarge, pspeed in product(
                moves, moves, (0, CHARGING), (0, CHARGING), (50, 150)):
            vm.set('wPlayerSelectedMove', MOVES[player])
            vm.set('wEnemySelectedMove', MOVES[enemy])
            vm.set('wPlayerBattleStatus1', pcharge)
            vm.set('wEnemyBattleStatus1', echarge)
            word('wBattleMonSpeed', pspeed)
            word('wEnemyMonSpeed', 100)
            p, e = priority(player, pcharge), priority(enemy, echarge)
            expected = 0 if p > e or (p == e and pspeed > 100) else 1
            vm.call('MainInBattleLoop.noLinkBattle')
            assert vm.reg.A == expected, (player, enemy, pcharge, echarge, pspeed)
            count += 1

        for name in ('PrintText', 'PlayBattleAnimation', 'PlayCurrentMoveAnimation',
                     'DrawHUDsAndHPBars', 'UpdateHPBar',
                     'HandleIfPlayerMoveMissed', 'HandleIfEnemyMoveMissed'):
            vm.stub(name)

        for turn, user, target, hp in ((0, 'Player', 'Enemy', 'wEnemyMonHP'),
                                       (1, 'Enemy', 'Player', 'wBattleMonHP')):
            def setup(move='SKY_ATTACK', charging=CHARGING, damage=100, effect=0):
                vm.set('hWhoseTurn', turn)
                vm.set(f'w{user}BattleStatus1', 0)
                vm.set(f'w{user}BattleStatus2', 0)
                vm.set(f'w{target}BattleStatus1', charging)
                vm.set(f'w{target}BattleStatus2', 0)
                vm.set(f'w{target}MoveNum', MOVES[move])
                vm.set(f'w{target}MoveEffect', EFFECTS['CHARGE_EFFECT'])
                vm.set(f'w{user}MoveNum', MOVES['TACKLE'])
                vm.set(f'w{user}MovePower', 100)
                vm.set(f'w{user}MoveEffect', effect)
                word(hp, 1000)
                word('wEnemyMonMaxHP' if turn == 0 else 'wBattleMonMaxHP', 1000)
                word('wDamage', damage)

            for move, charging, incoming in product(
                    BRACING + ('FLY', 'DIG', 'TACKLE'), (0, CHARGING), (0, 1, 3, 100, 257)):
                setup(move, charging, incoming)
                expected = max(1, incoming // 2) if move in BRACING and charging and incoming else incoming
                vm.call(f'{user}MoveDamageReady')
                vm.call(f'ApplyAttackTo{target}Pokemon')
                assert read_word(hp) == 1000 - expected, (turn, move, charging, incoming)
                assert read_word('wDamage') == expected

            # Fixed-damage attacks and Super Fang also pass through the shield.
            for move, effect, expected in (
                    ('SONICBOOM', 'SPECIAL_DAMAGE_EFFECT', 10),
                    ('DRAGON_RAGE', 'SPECIAL_DAMAGE_EFFECT', 20),
                    ('SUPER_FANG', 'SUPER_FANG_EFFECT', 250),
                    ('FISSURE', 'OHKO_EFFECT', 1000)):
                setup(damage=1000, effect=EFFECTS[effect])
                vm.set(f'w{user}MoveNum', MOVES[move])
                vm.call(f'{user}MoveDamageReady')
                vm.call(f'ApplyAttackTo{target}Pokemon')
                assert read_word(hp) == 1000 - expected, (turn, move, read_word(hp))

            # Every multi-hit strike reuses the halved value, never halves it again.
            setup(damage=100)
            vm.set(f'w{user}BattleStatus1', MULTI_HIT)
            vm.set(f'w{user}NumHits', 5)
            vm.call(f'{user}MoveDamageReady')
            for left in range(5, 0, -1):
                vm.set(f'w{user}NumAttacksLeft', left)
                vm.call(f'ApplyAttackTo{target}Pokemon')
                assert read_word('wDamage') == 50
                assert read_word(hp) == 1000 - 50 * (6 - left)

            # Trapping attacks also reuse damage across turns without halving again.
            setup(damage=100)
            vm.call(f'{user}MoveDamageReady')
            vm.set(f'w{user}BattleStatus1', 1 << 5)
            for hit in range(1, 4):
                vm.call(f'ApplyAttackTo{target}Pokemon')
                assert read_word('wDamage') == 50
                assert read_word(hp) == 1000 - 50 * hit

            # A charging user's Substitute receives the same reduced attack damage.
            setup(damage=100)
            vm.set(f'w{target}BattleStatus2', 1 << 4)
            vm.set(f'w{target}SubstituteHP', 200)
            vm.call(f'{user}MoveDamageReady')
            vm.call(f'ApplyAttackTo{target}Pokemon')
            assert vm.get(f'w{target}SubstituteHP') == 150
            assert read_word(hp) == 1000

            # Self-inflicted damage uses the direct HP path without protection.
            setup(damage=100)
            vm.call(f'ApplyDamageTo{target}Pokemon')
            assert read_word(hp) == 900

            # The actual release entry clears protection before starting the strike.
            setup(damage=100)
            vm.set('hWhoseTurn', turn ^ 1)
            vm.stub(f'{target}CanExecuteMove')
            vm.call(f'{target}CanExecuteChargingMove')
            assert not vm.get(f'w{target}BattleStatus1') & CHARGING
            vm.set('hWhoseTurn', turn)
            vm.call(f'{user}MoveDamageReady')
            vm.call(f'ApplyAttackTo{target}Pokemon')
            assert read_word(hp) == 900

        print(f'{rom}: {count} priority cases passed; both sides, charge/release timing, '
              'rounding, fixed damage, OHKO, multi-hit, trapping and direct self-damage')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
