/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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
import "."

CoverBackground {
    id: cover
    anchors.fill: parent

    property bool active: status === Cover.Active

    Image {
        id: image
        anchors.centerIn: parent
        height: width/sourceSize.width * sourceSize.height
        opacity: 0.1
        smooth: true
        source: "icons/cover.png"
        width: 2 * parent.width
    }

    Label {
        id: title
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeLarge
        text: "Pan Bikes"
    }

    SilicaListView {
        id: view
        anchors.centerIn: parent
        visible: false
        width: parent.width

        delegate: Item {
            id: listItem
            height: separatorLabel.height + nameLabel.height
            width: parent.width

            Label {
                id: separatorLabel
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                height: implicitHeight + 2 * Theme.paddingSmall
                horizontalAlignment: Text.AlignHCenter
                text: "/"
                verticalAlignment: Text.AlignBottom
            }

            Label {
                id: bikesLabel
                anchors.baseline: separatorLabel.baseline
                anchors.right: separatorLabel.left
                anchors.rightMargin: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeLarge
                horizontalAlignment: Text.AlignRight
                text: model.bikes > -1 ? model.bikes : "–"
            }

            Label {
                id: capacityLabel
                anchors.baseline: separatorLabel.baseline
                anchors.left: separatorLabel.right
                anchors.leftMargin: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeLarge
                horizontalAlignment: Text.AlignLeft
                text: model.capacity > -1 ? model.capacity : "–"
            }

            Label {
                id: nameLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: separatorLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + 2 * Theme.paddingSmall
                horizontalAlignment: implicitWidth >
                    parent.width - anchors.leftMargin - anchors.rightMargin ?
                    Text.AlignLeft : Text.AlignHCenter
                text: model.name
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignTop
            }

            Component.onCompleted: view.height = view.model.count * listItem.height;

        }

        model: ListModel {}

    }

    Component.onCompleted: {
        // Pre-fill list view model with blank entries.
        view.model.append({"bikes": -1, "capacity": -1, "name": ""});
        view.model.append({"bikes": -1, "capacity": -1, "name": ""});
        view.model.append({"bikes": -1, "capacity": -1, "name": ""});
    }

    function clear() {
        // Clear the list of closest bike stations.
        for (var i = 0; i < view.model.count; i++)
            view.model.set(i, {"bikes": -1, "capacity": -1, "name": ""});
    }

    function update(bbox) {
        // Update the list of closest bike stations.
        var stations = map.stations.sort(function(a, b) {
            return (map.center.distanceTo(a.coordinate) -
                    map.center.distanceTo(b.coordinate));
        });
        if (stations.length > 0) {
            // Show nearest stations.
            cover.clear();
            var n = Math.min(stations.length, view.model.count);
            for (var i = 0; i < n; i++)
                view.model.set(i, stations[i]);
            image.visible = false
            title.visible = false;
            view.visible = true;
        } else {
            // No stations; show image and title.
            cover.clear();
            view.visible = false;
            image.visible = true;
            title.visible = true;
        }
    }

}
