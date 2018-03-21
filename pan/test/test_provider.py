# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa
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


class TestProvider(pan.test.TestCase):

    def setup_method(self, method):
        self.provider = pan.Provider("citybikes")
        self.network = "citybikes-helsinki"
        # Lauttasaari, Helsinki
        self.bbox = [24.84519, 24.89440, 60.14357, 60.17153]

    def test___new__(self):
        a = pan.Provider("citybikes")
        b = pan.Provider("citybikes")
        assert a is b

    def test_get_center(self):
        self.provider.list_stations(self.network)
        center = self.provider.get_center(self.network)
        assert 24 < center["x"] < 25
        assert 60 < center["y"] < 61

    def test_get_total_stations(self):
        self.provider.list_stations(self.network)
        total = self.provider.get_total_stations
        assert 100 < total(self.network) < 200
        assert 6 < total(self.network, self.bbox) < 12

    def test_list_networks(self):
        networks = self.provider.list_networks(x=24.941, y=60.169)
        assert networks[0]["id"] == self.network

    def test_list_stations(self):
        stations = self.provider.list_stations(self.network)
        assert len(stations) == pan.conf.max_stations
        stations = self.provider.list_stations(self.network, self.bbox)
        assert 6 < len(stations) < 12
