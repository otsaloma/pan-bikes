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
import Sailfish.Silica 1.0

MapQuickItem {
    id: station
    anchorPoint.x: bubble.width / 2
    anchorPoint.y: arrow.y
    sourceItem: Item {

        Rectangle {
            id: bubble
            anchors.bottom: bar.bottom
            anchors.left: bikesText.left
            anchors.margins: -Theme.paddingSmall
            anchors.right: capacityText.right
            anchors.top: separator.top
            color: "#d0000000"
        }

        Image {
            id: arrow
            anchors.horizontalCenter: bubble.horizontalCenter
            anchors.top: bubble.bottom
            // Try to avoid a stripe between bubble and arrow.
            anchors.topMargin: Theme.pixelRatio * -0.5
            smooth: false
            source: app.getIcon("bubble-arrow")
        }

        Text {
            id: separator
            color: "white"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio * 18)
            text: "/"
        }

        Text {
            id: bikesText
            anchors.baseline: separator.baseline
            anchors.right: separator.left
            anchors.rightMargin: Math.round(Theme.pixelRatio * 2)
            color: "white"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio * 18)
            horizontalAlignment: Text.AlignRight
            text: station.bikes != null ? station.bikes : "–"
        }

        Text {
            id: capacityText
            anchors.baseline: separator.baseline
            anchors.left: separator.right
            anchors.leftMargin: Math.round(Theme.pixelRatio * 2)
            color: "white"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio * 18)
            horizontalAlignment: Text.AlignLeft
            text: station.capacity != null ? station.capacity : "–"
        }

        Rectangle {
            id: bar
            anchors.left: bubble.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.top: capacityText.bottom
            anchors.topMargin: Theme.paddingSmall
            color: Theme.highlightColor
            height: Theme.paddingSmall
            width: {
                var total = bubble.width - 2 * anchors.leftMargin;
                var bikes = station.bikes != null ? station.bikes : 0;
                var capacity = station.capacity != null ? station.capacity : 10;
                return Math.floor(Math.min(1, bikes/capacity) * total);
            }
        }

    }

    // Use var so that we can have nulls,
    // int can't hold null, undefined or NaN.
    property var bikes: 0
    property var capacity: 0
    property bool found: false
    property string uid: ""

    function setCounts(freeBikes, emptySlots) {
        // Update bike count and capacity, accounting for missing data.
        station.bikes = freeBikes;
        station.capacity = (freeBikes != null && emptySlots != null) ?
            freeBikes + emptySlots : null;
    }

}
