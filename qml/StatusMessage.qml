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
    anchors.bottomMargin: Theme.paddingSmall + Math.round(Theme.pixelRatio * 12)
    anchors.right: parent.right
    anchors.rightMargin: Theme.paddingSmall + Math.round(Theme.pixelRatio * 12)
    height: box.height
    opacity: 0.9
    width: box.width
    z: 100
    Rectangle {
        id: box
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: "white"
        height: message.implicitHeight + 2 * Theme.paddingMedium
        opacity: 0.7
        visible: message.text
        width: message.implicitWidth + 2 * Theme.paddingMedium
    }
    Text {
        id: message
        anchors.centerIn: box
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: Math.round(Theme.pixelRatio * 20)
    }
    function update() {
        if (!py.ready) return;
        var returned = py.evaluate("pan.app.provider.stations_returned");
        var total = py.evaluate("pan.app.provider.stations_total");
        message.text = returned === total ? "" : "%1/%2".arg(returned).arg(total);
    }
}
