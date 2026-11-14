#!/usr/bin/env python3
"""Exercise Seed/Substitute/recovery move choices in both assembled ROMs."""
from test_elite_baos import Machine, TRAINERS
from test_rage_effect import MOVES


SUBSTITUTE, SEEDED = 1 << 4, 1 << 7


def check_rom(rom):
    vm = Machine(rom)
    try:
        def put(name, values):
            addr = vm.addr(name)
            vm.mem[addr:addr + len(values)] = values

        def word(name, value):
            put(name, [value >> 8, value & 255])

        def setup(hp=100, own_sub=False, seeded=False, player_sub=False,
                  target_type=0, last_power=80):
            put('wEnemyMonMoves', [MOVES['LEECH_SEED'], MOVES['SUBSTITUTE'],
                                  MOVES['MEGA_DRAIN'], 0])
            put('wEnemyMonPP', [10, 10, 10, 0])
            put('wEnemyMonType1', [22, 22])
            put('wBattleMonType', [target_type, target_type])
            vm.set('wTrainerClass', TRAINERS['ODO'])
            vm.set('wEnemyBattleStatus2', SUBSTITUTE if own_sub else 0)
            vm.set('wPlayerBattleStatus2',
                   (SEEDED if seeded else 0) | (SUBSTITUTE if player_sub else 0))
            for name in ('wEnemyBattleStatus1', 'wPlayerBattleStatus1',
                         'wEnemyBattleStatus3', 'wPlayerBattleStatus3',
                         'wEnemyMonStatus', 'wBattleMonStatus',
                         'wEnemyDisabledMove', 'wPlayerDisabledMove',
                         'wActionResultOrTookBattleTurn'):
                vm.set(name, 0)
            vm.set('wAILastMovePower', last_power)
            word('wEnemyMonHP', hp)
            word('wEnemyMonMaxHP', 100)
            word('wBattleMonHP', 100)
            word('wBattleMonMaxHP', 100)
            word('wEnemyMonAttack', 100)
            word('wEnemyMonSpecial', 200)
            put('wEnemyMonStatMods', [7] * 6)
            put('wPlayerMonStatMods', [7] * 6)

        def choose():
            vm.call('AIEnemyTrainerChooseMoves')
            return vm.mem[vm.addr('wBuffer'):vm.addr('wBuffer') + 4]

        for args, expected in (
                ({}, 'LEECH_SEED'),
                ({'own_sub': True, 'last_power': 0}, 'LEECH_SEED'),
                ({'seeded': True, 'last_power': 0}, 'SUBSTITUTE'),
                ({'seeded': True, 'own_sub': True}, 'MEGA_DRAIN'),
                ({'hp': 40, 'seeded': True}, 'MEGA_DRAIN'),
                ({'hp': 25, 'seeded': True}, 'MEGA_DRAIN'),
                ({'hp': 24, 'seeded': True}, 'MEGA_DRAIN')):
            setup(**args)
            selected = choose()
            assert selected == [MOVES[expected] if i ==
                                ('LEECH_SEED', 'SUBSTITUTE', 'MEGA_DRAIN').index(expected)
                                else 0 for i in range(4)], (args, selected)

        setup(target_type=22)
        assert choose()[0] == 0  # never try to Seed a Grass-type

        # A protected opponent blocks Seed and draining moves; no healing bonus.
        setup(hp=40, player_sub=True)
        selected = choose()
        assert selected[0] == selected[2] == 0

        # Seed's setup bonus requires an actually available Substitute.
        for pp, disabled, found in ((10, 0, True), (0xc0, 0, False),
                                    (10, 0x21, False)):
            setup()
            vm.set('wEnemyDisabledMove', disabled)
            vm.mem[vm.addr('wEnemyMonPP') + 1] = pp
            vm.call('AIHasUsableSubstitute')
            assert bool(vm.reg.F & 0x10) == found

        # Low-HP recovery preference can outweigh the stronger-attack penalty.
        setup(hp=40)
        put('wEnemyMonMoves', [MOVES['MEGA_DRAIN'], MOVES['SOLARBEAM'], 0, 0])
        assert choose() == [MOVES['MEGA_DRAIN'], 0, 0, 0]
        print(f'{rom}: Seed setup, Substitute, recovery, invalid moves and HP-cost checks passed')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
