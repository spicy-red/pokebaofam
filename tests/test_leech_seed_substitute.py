#!/usr/bin/env python3
"""Check Leech Seed against Substitute in both assembled ROMs."""
from test_elite_baos import Machine


SUBSTITUTE, SEEDED = 1 << 4, 1 << 7
GRASS = 22


def check_rom(rom):
    vm = Machine(rom)
    try:
        # Isolate seed application from accuracy, animation and text handling.
        for name in ('MoveHitTest', 'PlayCurrentMoveAnimation', 'PrintText',
                     'PrintDidntAffectText'):
            vm.stub(name)

        count = 0
        for turn, user, target, target_type in (
                (0, 'Player', 'Enemy', 'wEnemyMonType1'),
                (1, 'Enemy', 'Player', 'wBattleMonType1')):
            for own_sub in (0, SUBSTITUTE):
                for target_sub in (0, SUBSTITUTE):
                    for seeded in (0, SEEDED):
                        for types in ((0, 0), (GRASS, 0), (0, GRASS)):
                            for missed in (0, 1):
                                vm.set('hWhoseTurn', turn)
                                vm.set('wMoveMissed', missed)
                                # Preserve unrelated battle-status flags, too.
                                own_flags = own_sub | 1
                                target_flags = target_sub | seeded | 2
                                vm.set(f'w{user}BattleStatus2', own_flags)
                                vm.set(f'w{target}BattleStatus2', target_flags)
                                addr = vm.addr(target_type)
                                vm.mem[addr:addr + 2] = list(types)
                                vm.call('LeechSeedEffect')
                                expected = target_flags
                                if not missed and not target_sub and GRASS not in types:
                                    expected |= SEEDED
                                assert vm.get(f'w{target}BattleStatus2') == expected, (
                                    turn, own_sub, target_sub, seeded, types, missed)
                                assert vm.get(f'w{user}BattleStatus2') == own_flags
                                count += 1
        print(f'{rom}: {count} Leech Seed cases passed; both sides, Substitute, '
              'existing seeds, Grass immunity and misses')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
