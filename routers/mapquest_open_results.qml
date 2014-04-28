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

Page {
    id: page
    allowedOrientations: Orientation.All
    property bool loading: true
    Label {
        id: busyLabel
        anchors.bottom: busyIndicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        text: "Searching"
        verticalAlignment: Text.AlignVCenter
        visible: page.loading || text != "Searching"
        width: parent.width
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
        visible: page.loading
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            busyLabel.text = "Searching";
        } else if (page.status == PageStatus.Active) {
            page.findRoute();
        }
    }
    function findRoute() {
        var routePage = app.pageStack.previousPage();
        py.call("poor.app.router.route",
                [routePage.from, routePage.to],
                function(route) {
                    if (route &&
                        route.hasOwnProperty("x") &&
                        route.x.length > 0) {
                        map.addRoute(route.x, route.y);
                        map.fitViewToRoute();
                        app.pageStack.pop(mapPage, PageStackAction.Immediate);
                        page.loading = false;
                    } else {
                        busyLabel.text = "No route found";
                        page.loading = false;
                    }
                });

    }
}