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
            anchors.left: counts.left
            anchors.margins: -Theme.paddingSmall
            anchors.right: counts.right
            anchors.top: counts.top
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
            id: counts
            color: "white"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio * 18)
            horizontalAlignment: Text.AlignHCenter
            text: station.label
            width: Math.max(implicitWidth, arrow.width + Theme.paddingSmall)
            onTextChanged: counts.doLayout();
        }

        Rectangle {
            id: bar
            anchors.left: bubble.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.top: counts.bottom
            anchors.topMargin: Theme.paddingSmall
            color: Theme.highlightColor
            height: Theme.paddingSmall
            width: {
                var total = bubble.width - 2 * anchors.leftMargin;
                var bikes = station.bikes > -1 ? station.bikes : 0;
                var capacity = station.capacity > -1 ? station.capacity : 10;
                return Math.floor(Math.min(1, bikes/capacity) * total);
            }
        }

    }

    property int bikes: 0
    property int capacity: 0
    property bool found: false
    property string label: ""
    property string name: ""
    property string uid: ""

    function setCounts(freeBikes, emptySlots) {
        // Update bike and capacity counts, accounting for missing data.
        // Missing freeBikes should be a rare error, but many networks don't provide
        // emptySlots at all, in which case it's better to show only the bike count.
        if (freeBikes != null) {
            station.bikes = freeBikes;
            station.label = freeBikes.toString();
        } else {
            station.bikes = -1;
            station.label = "–";
        }
        if (freeBikes != null && emptySlots != null) {
            station.capacity = freeBikes + emptySlots;
            station.label += "\u200a/\u200a%1".arg(station.capacity);
        } else {
            station.capacity = -1;
        }
    }

}
