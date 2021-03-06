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

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property bool loading: false
    property var  networks: []

    SilicaListView {
        id: view
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: cityLabel.height + nameLabel.height + sourceLabel.height

            ListItemLabel {
                id: cityLabel
                anchors.leftMargin: view.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: implicitHeight + Theme.paddingMedium
                text: "%1, %2".arg(model.city_qml).arg(model.country)
                verticalAlignment: Text.AlignBottom
            }

            ListItemLabel {
                id: nameLabel
                anchors.leftMargin: view.searchField.textLeftMargin
                anchors.top: cityLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + Theme.paddingSmall
                text: model.name
                verticalAlignment: Text.AlignVCenter
            }

            ListItemLabel {
                id: sourceLabel
                anchors.leftMargin: view.searchField.textLeftMargin
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + 1.5 * Theme.paddingMedium
                text: app.tr("via %1", model.provider_name)
                verticalAlignment: Text.AlignTop
            }

            onClicked: {
                py.call_sync("pan.app.set_provider", [model.provider_id]);
                app.conf.set("network", model.id);
                app.conf.set("network_label", model.city);
                map.clearStations();
                map.setCenter(model.x, model.y);
                map.changed = true;
                app.pageStack.pop(app.initialPage);
            }

        }

        header: Column {
            height: header.height + searchField.visible * searchField.height
            width: parent.width

            PageHeader {
                id: header
                title: app.tr("Networks")
            }

            SearchField {
                id: searchField
                placeholderText: app.tr("Search")
                visible: !page.loading
                width: parent.width
                onTextChanged: page.filterNetworks();
            }

            Component.onCompleted: view.searchField = searchField;

        }

        model: ListModel {}

        property var searchField: null

        VerticalScrollDecorator {}

    }

    BusyModal {
        id: busy
        running: page.loading
    }

    onStatusChanged: {
        if (page.status === PageStatus.Activating) {
            view.model.clear();
            page.loading = true;
            busy.text = app.tr("Loading");
        } else if (page.status === PageStatus.Active) {
            page.loadNetworks();
        }
    }

    function filterNetworks() {
        // Filter view to show networks matching search query.
        view.model.clear();
        for (var i = 0; i < page.networks.length; i++)
            page.networks[i].city_qml = page.networks[i].city;
        var query = view.searchField.text.toLowerCase();
        if (query === "")
            return filterNetworksClosest();
        for (var i = 0; i < page.networks.length; i++) {
            var item = page.networks[i].city.toLowerCase();
            if (item.indexOf(query) < 0) continue;
            page.networks[i].city_qml = Theme.highlightText(
                page.networks[i].city, query, Theme.highlightColor);
            view.model.append(page.networks[i]);
        }
    }

    function filterNetworksClosest() {
        // Filter view to show the closest networks.
        for (var i = 0; i < page.networks.length; i++)
            view.model.append(page.networks[i]);
    }

    function loadNetworks() {
        // Load provider model entries from the Python backend.
        view.model.clear();
        var x = map.center.longitude || 0;
        var y = map.center.latitude || 0;
        py.call("pan.app.list_networks", [x, y], function(results) {
            if (results && results.error && results.message) {
                busy.error = results.message;
                page.loading = false;
            } else if (results && results.length > 0) {
                page.networks = results;
                page.loading = false;
                page.filterNetworks();
            } else {
                busy.error = app.tr("No networks found");
                page.loading = false;
            }
        });
    }

}
