/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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
import Sailfish.Silica 1.0

Item {
    anchors.bottom: parent.bottom
    anchors.margins: Math.round(Theme.pixelRatio * 16)
    anchors.right: parent.right
    height: box.height
    width: box.width
    z: 500

    Rectangle {
        id: box
        anchors.fill: message
        anchors.margins: -Theme.paddingMedium
        color: "yellow"
        opacity: 0.85
        visible: message.text
    }

    Text {
        id: message
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: Math.round(Theme.pixelRatio * 22)
        opacity: 0.95
    }

    function update(bbox) {
        // Update the amount of visible and total stations.
        py.call("pan.app.get_total_stations", [bbox], function(total) {
            var limit = app.conf.get("max_stations");
            message.text = total > limit ? "%1\u200a/\u200a%2".arg(limit).arg(total) : "";
        });
    }

}
