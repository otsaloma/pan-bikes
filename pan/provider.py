# -*- coding: utf-8 -*-

# Copyright (C) 2016 Osmo Salomaa
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

"""A proxy for information from providers."""

import copy
import hashlib
import importlib.machinery
import os
import pan
import random
import re
import statistics
import time

__all__ = ("Provider",)


class Provider:

    """A proxy for information from providers."""

    def __new__(cls, id):
        """Return possibly existing instance for `id`."""
        if not hasattr(cls, "_instances"):
            cls._instances = {}
        if not id in cls._instances:
            cls._instances[id] = object.__new__(cls)
        return cls._instances[id]

    def __init__(self, id):
        """Initialize a :class:`Provider` instance."""
        # Initialize properties only once.
        if hasattr(self, "id"): return
        path, values = self._load_attributes(id)
        self.id = id
        self.name = values["name"]
        self._networks = []
        self._path = path
        self._provider = None
        self._stations = {}
        self.stations_returned = 0
        self.stations_total = 0
        self._stations_utime = -1
        self._init_provider(id, re.sub(r"\.json$", ".py", path))

    def get_center(self, network):
        """Return coordinates of `network`'s center point."""
        if (not network in self._stations or
            not self._stations[network]):
            return dict(x=None, y=None)
        x = [s["x"] for s in self._stations[network]]
        y = [s["y"] for s in self._stations[network]]
        return dict(x=statistics.mean(x), y=statistics.mean(y))

    @property
    def info_qml_uri(self):
        """Return URI to provider info QML file."""
        path = re.sub(r"\.json$", "_info.qml", self._path)
        return pan.util.path2uri(path)

    def _init_provider(self, id, path):
        """Initialize transit provider module from `path`."""
        name = "pan.provider{:d}".format(random.randrange(10**12))
        loader = importlib.machinery.SourceFileLoader(name, path)
        self._provider = loader.load_module(name)

    @pan.util.api_query([])
    def list_networks(self, x=0, y=0):
        """Return a list of bike networks."""
        if not self._networks:
            self._networks = self._provider.list_networks()
        networks = copy.deepcopy(self._networks)
        return pan.util.sorted_by_distance(networks, x, y)

    @pan.util.api_query([])
    def list_stations(self, network, xmin=-180, xmax=180, ymin=-90, ymax=90):
        """Return a list of bike stations for `network`."""
        if (not network in self._stations or
            not self._stations[network] or
            time.time() - self._stations_utime > 60):
            stations = self._provider.list_stations(network)
            for station in stations:
                id = bytes(station["id"], "utf_8")
                station["key"] = hashlib.md5(id).hexdigest()
            self._stations[network] = stations
            self._stations_utime = time.time()
        stations = copy.deepcopy(self._stations[network])
        inbb = lambda x: xmin < x["x"] < xmax and ymin < x["y"] < ymax
        stations = list(filter(inbb, stations))
        self.stations_total = len(stations)
        self.stations_returned = min(50, len(stations))
        return sorted(stations, key=lambda x: x["key"])[:50]

    def _load_attributes(self, id):
        """Read and return attributes from JSON file."""
        leaf = os.path.join("providers", "{}.json".format(id))
        path = os.path.join(pan.DATA_HOME_DIR, leaf)
        if not os.path.isfile(path):
            path = os.path.join(pan.DATA_DIR, leaf)
        return path, pan.util.read_json(path)
