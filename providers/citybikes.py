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

"""
Global city bikes via a proxy API.

https://api.citybik.es/v2/
"""

import pan
import re

def list_networks():
    """Return a list of supported city bike networks."""
    url = "https://api.citybik.es/v2/networks?fields=id,location,name"
    networks = pan.http.get_json(url)
    networks = pan.AttrDict(networks)
    return [dict(
        city=network.location.city,
        country=network.location.country,
        id=network.id,
        name=network.name,
        x=network.location.longitude,
        y=network.location.latitude,
    ) for network in networks.networks]

def list_stations(network):
    """Return a list of bike stations and their occupancy."""
    url = "https://api.citybik.es/v2/networks/{}?fields=stations".format(network)
    stations = pan.http.get_json(url)
    stations = pan.AttrDict(stations)
    return [dict(
        empty_slots=station.empty_slots,
        free_bikes=station.free_bikes,
        id=station.id,
        name=parse_station_name(station),
        x=station.longitude,
        y=station.latitude,
    ) for station in stations.network.stations]

def parse_station_name(station):
    """Return short human readable station name."""
    # Many networks seem to include preceding numbers
    # and trailing city or neighbourhood names.
    # e.g. 200218 - Addison Road, Holland Park
    return re.sub(r"^[\d\W]+", "", station.name).split(",")[0].strip()
