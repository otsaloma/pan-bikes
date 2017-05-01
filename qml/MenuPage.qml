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
import "."

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column
            anchors.fill: parent
            property var info: null
            PageHeader { title: "Pan Bikes" }
            ValueButton {
                id: networkButton
                label: qsTranslate("", "Network")
                value: app.conf.get("network_label") || app.conf.get("network")
                width: parent.width
                onClicked: {
                    var dialog = app.pageStack.push("NetworkPage.qml");
                    dialog.accepted.connect(function() {
                        networkButton.value = app.conf.get("network_label") ||
                            app.conf.get("network");
                        column.addInfo();
                    });
                }
            }
            Component.onCompleted: column.addInfo();
            function addInfo() {
                // Add provider-specific info from provider's own QML file.
                column.info && column.info.destroy();
                var uri = py.evaluate("pan.app.provider.info_qml_uri");
                if (!uri) return;
                var component = Qt.createComponent(uri);
                column.info = component.createObject(column);
                column.info.anchors.left = column.left;
                column.info.anchors.right = column.right;
                column.info.width = column.width;
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTranslate("", "About")
                onClicked: app.pageStack.push("AboutPage.qml");
            }
        }
        VerticalScrollDecorator {}
    }
}
