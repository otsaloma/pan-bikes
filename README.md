Pan Bikes
=========

[![Build Status](https://travis-ci.org/otsaloma/pan-bikes.svg)](
https://travis-ci.org/otsaloma/pan-bikes)

Pan Bikes is an application for Sailfish OS to view the locations and
real-time occupancy of city bike stations. It primarily uses
the [citybik.es](https://citybik.es/) API and supports all networks and
cities proxied by that API. It is also possible add new providers
directly to Pan Bikes.

Pan Bikes is free software released under the GNU General Public
License (GPL), see the file [`COPYING`](COPYING) for details.

For testing purposes you can just run `qmlscene qml/pan-bikes.qml`. For
installation, you can build the RPM package with command `make rpm`. You
don't need an SDK to build the RPM, only basic tools: `make`,
`rpmbuild`, `gettext` and `linguist` from `qttools`
