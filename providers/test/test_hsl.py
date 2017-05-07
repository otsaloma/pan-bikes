# -*- coding: utf-8 -*-

# Copyright (C) 2017 Osmo Salomaa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import pan.test


class TestModule(pan.test.TestCase):

    def setup_method(self, method):
        self.provider = pan.Provider("hsl")

    def test_list_networks(self):
        networks = self.provider.list_networks()
        networks = list(map(pan.AttrDict, networks))
        assert networks
        for network in networks:
            assert network.city
            assert network.country
            assert network.id
            assert network.x
            assert network.y

    def test_list_stations(self):
        stations = self.provider.list_stations("hsl")
        stations = list(map(pan.AttrDict, stations))
        assert stations
        for station in stations:
            assert station.empty_slots >= 0
            assert station.free_bikes >= 0
            assert station.id
            assert station.name
            assert station.x
            assert station.y
