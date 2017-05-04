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

CoverBackground {
    id: cover
    anchors.fill: parent

    property bool active: status === Cover.Active

    Image {
        anchors.centerIn: parent
        height: 0.9 * parent.height
        opacity: 0.15
        smooth: true
        source: "icons/cover.png"
        width: height/sourceSize.height * sourceSize.width
    }

    Label {
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeLarge
        text: "Pan Bikes"
    }

}
