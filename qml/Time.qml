/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt demos.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5

QtObject {
    id: time

    property bool twentyFourHourFormat: true
    property string amPmFormat: "AP"
    property alias updateInterval: __updateTimer.interval

    readonly property alias hour: __private.hour
    readonly property alias minute: __private.minute
    readonly property alias second: __private.second
    readonly property alias amPm: __private.amPm

    property QtObject __private: QtObject {
        id: __private

        property int hour: 0
        property int minute: 0
        property int second: 0
        property string amPm: "AM"
    }

    property Timer __updateTimer: Timer {
        id: __updateTimer

        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            var currentTime = new Date()

            var hour = currentTime.getHours()

            if (time.twentyFourHourFormat) {
                __private.hour = hour
            } else {
                if (hour === 0) {
                    __private.hour = 12
                } else if (hour < 13) {
                    __private.hour = hour
                } else {
                    __private.hour = hour - 12
                }
            }

            __private.minute = currentTime.getMinutes()
            __private.second = currentTime.getSeconds()
            __private.amPm = Qt.formatTime(currentTime, time.amPmFormat)
        }
    }
}
