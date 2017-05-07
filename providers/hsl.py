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
City bikes in the Helsinki region.

https://www.hsl.fi/kaupunkipyorat
https://digitransit.fi/en/developers/services-and-apis/1-routing-api/bicycling/
"""

import pan

# Send Accept header to get JSON output from OpenTripPlanner.
# https://github.com/opentripplanner/OpenTripPlanner/wiki/JsonOrXml
HEADERS = {"Accept": "application/json"}

def list_networks():
    """Return a list of supported city bike networks."""
    return [dict(
        city="Helsinki",
        country="FI",
        id="hsl",
        name="HSL",
        x=24.941,
        y=60.169,
    )]

def list_stations(network):
    """Return a list of bike stations and their occupancy."""
    url = "https://api.digitransit.fi/routing/v1/routers/hsl/bike_rental"
    stations = pan.http.get_json(url, headers=HEADERS)
    stations = pan.AttrDict(stations)
    return [dict(
        empty_slots=station.spacesAvailable,
        free_bikes=station.bikesAvailable,
        id=station.id,
        x=station.x,
        y=station.y,
    ) for station in stations.stations]
