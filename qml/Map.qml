/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2016 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

Map {
    id: map
    anchors.fill: parent
    center: QtPositioning.coordinate(48.137, 11.575)
    gesture.enabled: true
    minimumZoomLevel: 3
    plugin: MapPlugin {}

    property bool centerFound: false
    property bool changed: true
    property bool ready: false
    property var  stations: []
    property var  updating: false
    property var  utime: -1
    property real zoomLevelPrev: 8

    Behavior on center {
        CoordinateAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on zoomLevel {
        id: zoomAnimation
        enabled: false
        NumberAnimation {
            duration: 200
            easing.type: Easing.Linear
        }
    }

    MenuButton {}
    PositionMarker {}
    StatusMessage { id: statusMessage }

    Timer {
        interval: 500
        repeat: true
        running: app.running && (page.status === PageStatus.Active || cover.active) && map.ready
        onTriggered: (map.changed || Date.now() - map.utime > 60000) && map.updateStations();
    }

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: map.centerOnPosition();
    }

    Component.onCompleted: {
        // Use a daytime gray street map if available.
        for (var i = 0; i < map.supportedMapTypes.length; i++) {
            var type = map.supportedMapTypes[i];
            if (type.style  === MapType.GrayStreetMap &&
                type.mobile === true &&
                type.night  === false) {
                map.activeMapType = type;
                break;
            }
        }
        map.centerOnPosition();
        gps.onInitialCenterChanged.connect(map.centerOnPosition);
        // XXX: Must set zoomLevel in onCompleted.
        // https://bugreports.qt.io/browse/QTBUG-40779
        map.setZoomLevel(Screen.sizeCategory >= Screen.Large ? 16 : 15);
        map.ready = true;
    }

    onCenterChanged: {
        // Ensure that stations are updated after panning.
        // This gets fired ridiculously often, so keep simple.
        map.changed = true;
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid blurry tiles.
        if (map.zoomLevel < map.zoomLevelPrev) {
            map.zoomLevel % 1 < 0.75 ?
                map.setZoomLevel(Math.floor(map.zoomLevel)):
                map.setZoomLevel(Math.ceil(map.zoomLevel));
        } else if (map.zoomLevel > map.zoomLevelPrev) {
            map.zoomLevel % 1 > 0.25 ?
                map.setZoomLevel(Math.ceil(map.zoomLevel)):
                map.setZoomLevel(Math.floor(map.zoomLevel));
        }
    }

    function addStation(props) {
        // Add a new station marker to the map.
        var component = Qt.createComponent("Station.qml");
        var station = component.createObject(map);
        station.uid = props.id;
        station.name = props.name;
        station.coordinate = QtPositioning.coordinate(props.y, props.x);
        station.setCounts(props.free_bikes, props.empty_slots);
        map.stations.push(station);
        map.addMapItem(station);
    }

    function centerOnPosition() {
        // Center map on current position.
        var coord = gps.position.coordinate;
        if (!coord.longitude || !coord.latitude) return;
        map.center = QtPositioning.coordinate(coord.latitude, coord.longitude);
        map.centerFound = true;
    }

    function clearStations() {
        // Remove all station markers from the map.
        while (map.stations.length > 0) {
            var station = map.stations.pop();
            map.removeMapItem(station);
            station.destroy();
        }
    }

    function getBoundingBox() {
        // Return the currently visible [xmin, xmax, ymin, ymax].
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        return [nw.longitude, se.longitude, se.latitude, nw.latitude];
    }

    function setCenter(x, y) {
        // Center map on given coordinates.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        zoomAnimation.enabled = true;
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
        zoomAnimation.enabled = false;
    }

    function updateStationMatching(props) {
        // Update matching station marker if found.
        for (var i = 0; i < map.stations.length; i++) {
            if (map.stations[i].uid !== props.id) continue;
            var coord = QtPositioning.coordinate(props.y, props.x);
            map.stations[i].name = props.name;
            map.stations[i].coordinate = coord;
            map.stations[i].setCounts(props.free_bikes, props.empty_slots);
            props.found = true;
            map.stations[i].found = true;
            return;
        }
    }

    function updateStationReuse(props) {
        // Update station reusing any existing free marker.
        for (var i = 0; i < map.stations.length; i++) {
            if (map.stations[i].found) continue;
            var coord = QtPositioning.coordinate(props.y, props.x);
            map.stations[i].uid = props.id;
            map.stations[i].name = props.name;
            map.stations[i].coordinate = coord;
            map.stations[i].setCounts(props.free_bikes, props.empty_slots);
            props.found = true;
            map.stations[i].found = true;
            return;
        }
    }

    function updateStations() {
        // Fetch data from the Python backend and update station markers.
        if (!py.ready) return;
        if (map.updating) return;
        map.updating = true;
        var bbox = map.getBoundingBox();
        py.call("pan.app.list_stations", [bbox], function(results) {
            var left = function(x) { return !x.found; };
            for (var i = 0; i < map.stations.length; i++)
                map.stations[i].found = false;
            for (var i = 0; i < results.length; i++)
                map.updateStationMatching(results[i]);
            results = results.filter(left);
            for (var i = 0; i < results.length; i++)
                map.updateStationReuse(results[i]);
            results = results.filter(left);
            for (var i = 0; i < results.length; i++)
                map.addStation(results[i]);
            // Inform user if not all stations are visible.
            statusMessage.update(bbox);
            cover.update(bbox);
            map.updating = false;
            if (!map.centerFound) {
                // If no positioning data has yet been received, we can
                // fall back to centering on the network, which is possible
                // after a list_stations call has been made.
                py.call("pan.app.get_center", [], function(coord) {
                    if (!coord.x || !coord.y) return;
                    map.setCenter(coord.x, coord.y);
                    map.centerFound = true;
                });
            }
        });
        map.changed = false;
        map.utime = Date.now();
    }

}
