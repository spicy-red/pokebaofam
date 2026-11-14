#!/usr/bin/env python3
"""Check assembled critical-hit damage at every level, including above 127."""
from test_elite_baos import Machine
from test_rage_effect import EFFECTS


def check_rom(rom):
    vm = Machine(rom)
    try:
        def word(name, value):
            addr = vm.addr(name)
            vm.mem[addr:addr + 2] = [value >> 8, value & 255]

        def read_word(name):
            addr = vm.addr(name)
            return vm.mem[addr] * 256 + vm.mem[addr + 1]

        # Link-mode stat lookup reads the supplied party stats directly.
        # Keep baseline and current stats equal so crit stat resets are neutral.
        vm.set('wLinkState', 4)
        vm.set('wPlayerMonNumber', 0)
        vm.set('wEnemyMonPartyPos', 0)
        for name in ('wPlayerBattleStatus3', 'wEnemyBattleStatus3'):
            vm.set(name, 0)

        def check(turn, critical, level, power, attack, defense, explosion=False,
                  special=False):
            vm.set('hWhoseTurn', turn)
            vm.set('wCriticalHitOrOHKO', critical)
            prefix, attacker, defender = ('Enemy', 'Enemy', 'Battle') if turn else ('Player', 'Battle', 'Enemy')
            vm.set(f'w{attacker}MonLevel', level)
            vm.set(f'w{prefix}MovePower', power)
            vm.set(f'w{prefix}MoveType', 20 if special else 0)
            vm.set(f'w{prefix}MoveEffect', EFFECTS['EXPLODE_EFFECT'] if explosion else 0)
            offensive, defensive = ('Special', 'Special') if special else ('Attack', 'Defense')
            word(f'w{attacker}Mon{offensive}', attack)
            word(f'w{defender}Mon{defensive}', defense)
            word(f'w{"Enemy" if turn else "Party"}Mon1{offensive}', attack)
            word(f'w{"Party" if turn else "Enemy"}Mon1{defensive}', defense)
            vm.call(f'GetDamageVarsFor{prefix}Attack')
            assert vm.reg.E == level  # level is not pre-doubled into one byte
            scaled_attack, scaled_defense = attack, defense
            if max(attack, defense) > 255:
                scaled_attack, scaled_defense = max(1, attack // 4), defense // 4
            if explosion:
                scaled_defense = max(1, scaled_defense // 2)
            expected = min(999, ((level * (4 if critical else 2) // 5 + 2)
                                * power * scaled_attack // scaled_defense // 50) + 2)
            vm.call('CalculateDamage')
            actual = read_word('wDamage')
            assert actual == expected, (turn, critical, level, power, attack,
                                        defense, explosion, special, actual, expected)
            return actual

        count = 0
        for turn in (0, 1):
            for critical in (0, 1):
                # Every representable level, covering both normal attacks and
                # Explosion's separate defense-halving and damage-cap path.
                for level in range(1, 256):
                    for explosion, power in ((False, 95), (True, 250)):
                        check(turn, critical, level, power, 200, 200, explosion)
                        count += 1
                for level in (100, 127, 128, 130, 200, 250, 255):
                    for attack, defense in ((300, 300), (999, 999), (999, 4)):
                        for explosion in (False, True):
                            check(turn, critical, level, 250, attack, defense, explosion)
                            count += 1
                    check(turn, critical, level, 95, 300, 300, special=True)
                    count += 1
            normal = check(turn, 0, 130, 95, 200, 200)
            critical = check(turn, 1, 130, 95, 200, 200)
            assert (normal, critical) == (104, 203)
        print(f'{rom}: {count} damage cases passed; levels 1–255, both sides, crits, Explosion, scaling and caps')
    finally:
        vm.pyboy.stop(save=False)


if __name__ == '__main__':
    for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
        check_rom(rom)
