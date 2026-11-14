#!/usr/bin/env python3
"""Exercise assembled Rival3AI switching in PyBoy; build red and blue_debug first.

Run with a Python environment containing pyboy. UI routines are stubbed, and
send-out stops after selecting a slot; AI dispatch, roster search, withdrawal,
and destination selection execute from the ROM.
"""
from test_elite_baos import Machine, SPECIES, TRAINERS


def check_rom(rom):
    vm = Machine(rom)
    try:
        for name in ('PrintText', 'SlideTrainerPicOffScreen', 'PrintEmptyString',
                     'SaveScreenTilesToBuffer1', 'EnemySendOutWithSelection.next3'):
            vm.stub(name)
        # Keep healing randomness predictable: return zero.
        bank, addr = vm.symbols['Random']
        vm.mem[bank, addr:addr + 2] = [0xaf, 0xc9]
        stride = vm.addr('wEnemyMon2') - vm.addr('wEnemyMon1')

        def setup(player='MEWTWO', active=0, wob_hp=100, count=1, trainer='ODO'):
            vm.set('wIsInBattle', 2)
            vm.set('wLinkState', 0)
            vm.set('wTrainerClass', TRAINERS[trainer])
            vm.set('wAICount', count)
            vm.set('wPlayerMonNumber', 0)
            vm.set('wPartySpecies', SPECIES[player])
            vm.set('wEnemyPartyCount', 4)
            vm.set('wEnemyMonPartyPos', active)
            vm.set('wEnemyMonSpecies2', SPECIES['WOBBUFFET' if active == 2 else 'PORYGON'])
            vm.set('wEnemyMonStatus', 0)
            vm.set('wCurrentMenuItem', 3)
            vm.set('wWhichPokemon', 99)
            for i, species in enumerate(('PORYGON', 'HERACROSS', 'WOBBUFFET', 'MUK')):
                base = vm.addr('wEnemyMon1') + i * stride
                vm.mem[base:base + 4] = [SPECIES[species], 0, wob_hp if i == 2 else 100, i]
            for name, hp in (('wEnemyMonHP', 80), ('wEnemyMonMaxHP', 100)):
                vm.mem[vm.addr(name):vm.addr(name) + 2] = [0, hp]

        # Both threats, every Rival3AI trainer, including an exhausted item budget.
        for trainer in ('ODO', 'RIVAL3', 'PROF_OAK', 'ELITE_BAO'):
            for player in ('MEW', 'MEWTWO'):
                for count in (0, 1, 255):
                    setup(player=player, count=count, trainer=trainer)
                    vm.call('TrainerAI')
                    assert vm.get('wWhichPokemon') == 2, (trainer, player, count)
                    assert vm.reg.F & 0x10
                    assert vm.get('wCurrentMenuItem') == 3
                    assert vm.mem[vm.addr('wEnemyMon1HP') + 1] == 80

        # No switch for other opponents, a fainted Wobbuffet, or Wobbuffet already out.
        for args in ({'player': 'PIKACHU'}, {'wob_hp': 0}, {'active': 2},
                     {'trainer': 'YOUNGSTER', 'count': 0}):
            setup(**args)
            vm.call('TrainerAI')
            assert vm.get('wWhichPokemon') == 99, args
            assert not vm.reg.F & 0x10, args

        # An ordinary switch still picks the first living, inactive teammate.
        setup(active=0)
        vm.call('SwitchEnemyMon')
        assert vm.get('wWhichPokemon') == 1
        assert vm.reg.F & 0x10

        # Healing remains available below one-third HP, but never after exhaustion.
        bank, addr = vm.symbols['AIUseFullRestore']
        vm.mem[bank, addr:addr + 4] = [0x3e, 0xa5, 0x37, 0xc9]
        for count in (0, 1):
            setup(player='PIKACHU', count=count)
            vm.mem[vm.addr('wEnemyMonHP') + 1] = 20
            vm.call('TrainerAI')
            assert bool(vm.reg.F & 0x10) == bool(count)
            if count:
                assert vm.reg.A == 0xa5
        print(f'{rom}: Rival3AI switching and healing checks passed')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
