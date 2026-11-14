#!/usr/bin/env python3
"""Run Expert AI effective-power comparisons in the assembled ROMs with PyBoy."""
from test_elite_baos import Machine, TRAINERS
from test_rage_effect import EFFECTS, MOVES


NORMAL, FIGHTING, FLYING, ROCK, BUG, GHOST = 0, 1, 2, 5, 7, 8
FIRE, WATER, GRASS = 20, 21, 22


def check_rom(rom):
    vm = Machine(rom)
    try:
        def put(name, values):
            addr = vm.addr(name)
            vm.mem[addr:addr + len(values)] = values

        def estimate(power=100, effect='NO_ADDITIONAL_EFFECT', move_type=NORMAL,
                     user=(NORMAL, NORMAL), target=(NORMAL, NORMAL),
                     accuracy=255, x_accuracy=False):
            put('wEnemyMonType1', user)
            put('wBattleMonType', target)
            vm.set('wEnemyBattleStatus2', 1 if x_accuracy else 0)
            vm.set('wEnemyMovePower', power)
            vm.set('wEnemyMoveEffect', EFFECTS[effect])
            vm.set('wEnemyMoveType', move_type)
            vm.set('wEnemyMoveAccuracy', accuracy)
            vm.call('AIEstimateMovePower')
            return vm.reg.HL

        assert estimate() == 1494  # 100 power, STAB, neutral, 255/256 accuracy
        assert estimate(user=(WATER, WATER)) == 996
        assert estimate(user=(WATER, NORMAL)) == 1494  # second type gives STAB
        assert estimate(target=(ROCK, ROCK)) == 747  # duplicate types counted once
        assert estimate(move_type=FIGHTING, user=(WATER, WATER),
                        target=(NORMAL, ROCK)) == 3984  # 4x weakness
        assert estimate(target=(GHOST, NORMAL)) == 0  # immunity overrides weakness
        assert estimate(power=0) == 0
        assert estimate(power=1, effect='SPECIAL_DAMAGE_EFFECT') == 0
        assert estimate(effect='CHARGE_EFFECT') == 747
        assert estimate(effect='HYPER_BEAM_EFFECT') == 747
        assert estimate(effect='ATTACK_TWICE_EFFECT') == 2988
        assert estimate(effect='TWINEEDLE_EFFECT') == 2988
        assert estimate(effect='TWO_TO_FIVE_ATTACKS_EFFECT') == 4482
        assert estimate(accuracy=128) == 750
        assert estimate(accuracy=128, x_accuracy=True) == 1500
        assert estimate(effect='SWIFT_EFFECT', accuracy=128) == 1500
        # Maximum encoded power, 3 hits, STAB and 4x weakness must not wrap.
        assert estimate(power=255, effect='TWO_TO_FIVE_ATTACKS_EFFECT',
                        move_type=FIGHTING, user=(FIGHTING, FIGHTING),
                        target=(NORMAL, ROCK)) == 45720

        def setup(moves, user=(NORMAL, NORMAL), target=(NORMAL, NORMAL),
                  scores=(10, 10, 10, 10), pp=(10, 10, 10, 10)):
            ids = [MOVES[name] for name in moves]
            put('wEnemyMonMoves', ids + [0] * (4 - len(ids)))
            put('wEnemyMonPP', list(pp))
            put('wBuffer', list(scores))
            put('wEnemyMonType1', user)
            put('wBattleMonType', target)
            vm.set('wEnemyBattleStatus2', 0)
            vm.set('wActionResultOrTookBattleTurn', 0)

        def score():
            vm.call('AIPreferStrongestMove')
            return vm.mem[vm.addr('wBuffer'):vm.addr('wBuffer') + 4]

        # Strong neutral STAB beats a weaker super-effective attack.
        setup(('DOUBLE_EDGE', 'EMBER'), target=(GRASS, GRASS))
        assert score() == [10, 12, 10, 10]
        # A charge move can lose to a weaker single-turn attack.
        setup(('FLY', 'WING_ATTACK'), user=(FLYING, FLYING))
        assert score() == [12, 10, 10, 10]
        # A sufficiently strong charge move remains worth considering.
        setup(('SKY_ATTACK', 'WING_ATTACK'), user=(FLYING, FLYING))
        assert score() == [10, 12, 10, 10]
        # Ties, setup and fixed-damage moves retain their tactical scores.
        setup(('FIRE_PUNCH', 'ICE_PUNCH', 'SWORDS_DANCE', 'SEISMIC_TOSS'))
        assert score() == [10, 10, 10, 10]
        for scores, pp in (((80, 10, 10, 10), (10, 10, 10, 10)),
                           ((15, 10, 10, 10), (10, 10, 10, 10)),
                           ((10, 10, 10, 10), (0xc0, 10, 10, 10))):
            setup(('DOUBLE_EDGE', 'POUND'), scores=scores, pp=pp)
            assert score() == list(scores)  # unavailable moves cannot set the benchmark
        setup(('DOUBLE_EDGE', 'POUND'))
        vm.set('wActionResultOrTookBattleTurn', 10)
        assert score() == [10, 10, 10, 10]

        # Exercise actual Expert-layer dispatch and final move filtering.
        setup(('DOUBLE_EDGE', 'POUND'))
        vm.set('wTrainerClass', TRAINERS['ODO'])
        vm.set('wEnemyBattleStatus1', 0)
        vm.set('wPlayerBattleStatus1', 0)
        vm.set('wPlayerBattleStatus2', 0)
        vm.set('wEnemyMonStatus', 0)
        vm.set('wEnemyDisabledMove', 0)
        put('wEnemyMonAttack', [0, 100])
        put('wEnemyMonSpecial', [0, 100])
        vm.call('AIEnemyTrainerChooseMoves')
        assert vm.mem[vm.addr('wBuffer'):vm.addr('wBuffer') + 4] == [MOVES['DOUBLE_EDGE'], 0, 0, 0]
        setup(('DOUBLE_EDGE', 'EMBER'), target=(GRASS, GRASS))
        vm.call('AIEnemyTrainerChooseMoves')
        assert vm.mem[vm.addr('wBuffer'):vm.addr('wBuffer') + 4] == [MOVES['DOUBLE_EDGE'], 0, 0, 0]
        print(f'{rom}: effective power, STAB, types, accuracy, turn cost, availability and Expert dispatch passed')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
