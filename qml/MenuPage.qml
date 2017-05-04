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

            PageHeader {
                title: "Pan Bikes"
            }

            ValueButton {
                id: networkButton
                label: qsTranslate("", "Network")
                value: app.conf.get("network_label")
                width: parent.width
                onClicked: app.pageStack.push("NetworkPage.qml");
            }

            Item {
                id: placeholder
                height: info ? info.height : 0
                width: parent.width
                property var info: null
            }

            SectionHeader {
                text: qsTranslate("", "Preferences")
            }

            TextField {
                id: stationsField
                inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                label: qsTranslate("", "Maximum amount of stations visible")
                text: app.conf.get("max_stations").toString()
                validator: RegExpValidator { regExp: /^[0-9]+$/ }
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: stationsField.focus = false;
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        if (!stationsField.text.match(/^[0-9]+$/)) return;
                        var value = parseInt(stationsField.text, 10);
                        app.conf.set("max_stations", value);
                        map.clearStations();
                        map.changed = true;
                    });
                }
            }

            Component.onCompleted:  {
                // Add provider-specific info from provider's own QML file.
                placeholder.info && placeholder.info.destroy();
                var uri = py.evaluate("pan.app.provider.info_qml_uri");
                if (!uri) return;
                var component = Qt.createComponent(uri);
                placeholder.info = component.createObject(placeholder);
                placeholder.info.anchors.left = placeholder.left;
                placeholder.info.anchors.right = placeholder.right;
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
