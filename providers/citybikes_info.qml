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
import "../qml"

Column {

    ListItemLabel {
        font.pixelSize: Theme.fontSizeSmall
        height: implicitHeight + Theme.paddingLarge
        text: qsTranslate("", "Data is provided via the citybik.es API. If your local city bike system is not supported, or you see an error in the data, you can contribute to the pybikes backend of that API by filing an issue and/or contributing code.")
        wrapMode: Text.WordWrap
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        height: Theme.itemSizeLarge
        preferredWidth: Theme.buttonWidthLarge
        text: "github.com/eskerda/pybikes"
        onClicked: Qt.openUrlExternally("https://github.com/eskerda/pybikes");
    }

}
