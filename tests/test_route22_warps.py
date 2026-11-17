#!/usr/bin/env python3
"""Run Route 22's assembled warp engine in headless PyBoy, without a save.

    make -j2 pokebaofamred.gb pokebaofamblue_debug.gb
    python3 tests/test_route22_warps.py

Only transition presentation and the EnterMap gameplay loop are stubbed.
LoadMapHeader (including bank switching and destination position loading),
coordinate/direction matching, and WarpFound2 execute from the built ROM.
Landing coordinates are checked before the automatic step out of a door.
"""
import unittest

from test_elite_baos import MAPS, Machine


class Route22WarpsTest(unittest.TestCase):
    def test_transitions(self):
        # Source map, source tile, direction, destination map, landing tile.
        cases = (
            ('ROUTE_22_GATE', (0, 3), 2, 'ROUTE_22', (1, 4)),
            ('ROUTE_22_GATE', (0, 4), 2, 'ROUTE_22', (1, 5)),
            ('ROUTE_22', (1, 4), 1, 'ROUTE_22_GATE', (0, 3)),
            ('ROUTE_22', (1, 5), 1, 'ROUTE_22_GATE', (0, 4)),
            ('ROUTE_22_GATE', (12, 7), 4, 'ROUTE_22', (8, 7)),
            ('ROUTE_22_GATE', (13, 7), 4, 'ROUTE_22', (8, 7)),
            ('ROUTE_22', (33, 3), 0, 'ROUTE_22_OLD_ROD_HOUSE', (2, 7)),
            ('ROUTE_22_OLD_ROD_HOUSE', (2, 7), 4, 'ROUTE_22', (33, 3)),
            ('ROUTE_22_OLD_ROD_HOUSE', (3, 7), 4, 'ROUTE_22', (33, 3)),
        )
        for rom in ('pokebaofamred.gb', 'pokebaofamblue_debug.gb'):
            vm = Machine(rom)
            try:
                for name in ('PlayMapChangeSound', 'IgnoreInputForHalfSecond',
                             'EnterMap'):
                    vm.stub(name)
                for source, tile, direction, destination, expected in cases:
                    with self.subTest(rom=rom, source=source, tile=tile):
                        vm.set('wCurMap', MAPS[source])
                        vm.set('wLastMap', MAPS['ROUTE_22'])
                        vm.set('wCurMapTileset', 0)
                        vm.set('wDestinationWarpID', 255)
                        vm.set('wStatusFlags4', 0)
                        vm.set('wStatusFlags6', 0)
                        vm.set('wMovementFlags', 0)
                        vm.call('LoadMapHeader')
                        vm.set('wXCoord', tile[0])
                        vm.set('wYCoord', tile[1])
                        vm.set('wPlayerMovingDirection', direction)
                        # ANY_DIR doors use the no-collision path's coordinate
                        # lookup; directional exits use the collision path.
                        vm.call('CheckWarpAtPlayerCoord' if direction
                                else 'TryWarpAtPlayerCoord')
                        self.assertTrue(vm.reg.F & 0x10, 'warp was not detected')
                        # CheckWarpAtPlayerCoord leaves C as the warp-search
                        # counter needed by WarpFound2; Machine.call preserves it.
                        vm.call('WarpFound2')
                        self.assertEqual(vm.get('wCurMap'), MAPS[destination])
                        destination_id = vm.get('wDestinationWarpID') + 1
                        vm.call('LoadMapHeader')
                        actual = (vm.get('wXCoord'), vm.get('wYCoord'))
                        print(f'{rom}: {source}{tile} -> {destination} '
                              f'warp {destination_id} at {actual}', flush=True)
                        self.assertEqual(actual, expected,
                                         f'{destination} warp {destination_id}')
            finally:
                vm.pyboy.stop(save=False)


if __name__ == '__main__':
    unittest.main()
