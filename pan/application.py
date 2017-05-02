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

"""Locations and real-time occupancy of city bike stations."""

__all__ = ("Application",)

import copy
import pan
import sys


class Application:

    """Locations and real-time occupancy of city bike stations."""

    def __init__(self):
        """Initialize an :class:`Application` instance."""
        self.provider = None
        self.set_provider(pan.conf.provider)

    def list_networks(self, x, y):
        """Return a list of bike networks from all providers."""
        networks = []
        for provider in pan.util.get_providers():
            with pan.util.silent(Exception, tb=True):
                provider = pan.Provider(provider["pid"])
                for network in provider.list_networks(x, y):
                    network["provider_id"] = provider.id
                    network["provider_name"] = provider.name
                    networks.append(network)
        networks = copy.deepcopy(networks)
        return pan.util.sorted_by_distance(networks, x, y)

    def list_stations(self, xmin=-180, xmax=180, ymin=-90, ymax=90):
        """Return a list of bike stations from the current network."""
        return self.provider.list_stations(
            pan.conf.network, xmin, xmax, ymin, ymax)

    def quit(self):
        """Quit the application."""
        pan.http.pool.terminate()
        self.save()

    def save(self):
        """Write configuration files."""
        pan.conf.write()

    def set_provider(self, provider):
        """Set provider from string `provider`."""
        try:
            self.provider = pan.Provider(provider)
            pan.conf.provider = provider
        except Exception as error:
            print("Failed to load provider '{}': {}"
                  .format(provider, str(error)),
                  file=sys.stderr)
            if self.provider is None:
                default = pan.conf.get_default("provider")
                if default != provider:
                    self.set_provider(default)
