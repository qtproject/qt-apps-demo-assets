/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt demos.
**
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
****************************************************************************/

import QtQuick 2.5
import QtQuick.Window 2.2

QtObject {
    id: tvRemoteInputMethod

    // item which this input method object is assigned as a property;
    // must be set if mode is autoFocusMode (focus is resolved through item.KeyNavigation)
    property Item item: null

    readonly property real dp: Screen.pixelDensity * 25.4 / 160

    property bool acceptingInput: false

    property real absoluteX: 0
    property real absoluteY: 0

    property real thresholdX: 300 * dp
    property real thresholdY: 150 * dp

    property real relativeX: thresholdX > 0 ? absoluteX / thresholdX : 0
    property real relativeY: thresholdY > 0 ? absoluteY / thresholdY : 0

    // 1 - true, 0 - false, -1 - undefined
    property int xIsIncreasing: -1
    property int yIsIncreasing: -1

    property bool accumulateAxisValue: false

    signal pressed()
    signal released()
    signal canceled()

    // KeyNavigation is used, no signals emitted (convenient for simple controls such as Buttons, TextFields etc)
    readonly property int autoFocusMode: 0
    // emit swipe(Direction) signals (can be used to control currentIndex of ListView)
    readonly property int manualFocusMode: 1
    // emit (x)(y)Changed signals (can be used by controls allowing panning)
    readonly property int panningMode: 2
    property int mode: autoFocusMode

    signal swipedLeft()
    signal swipedRight()
    signal swipedUp()
    signal swipedDown()

    signal xChanged(real deltaX)
    signal yChanged(real deltaY)

    function xInputHandler(deltaX) {
        if (xIsIncreasing === -1) {
            xIsIncreasing = (deltaX > 0) ? 1 : 0
        }

        if (accumulateAxisValue) {
            absoluteX += deltaX
        } else {
            if ((xIsIncreasing && deltaX > 0) ||
               (!xIsIncreasing && deltaX < 0)) {
                absoluteX += deltaX
            } else {
                absoluteX = deltaX
                xIsIncreasing = (xIsIncreasing === 0) ? 1 : 0
            }
        }

        if (mode === autoFocusMode) {
            if (relativeX >= 1) {
                setFocusOnItem(item.KeyNavigation.right)
            } else if (relativeX <= -1) {
                setFocusOnItem(item.KeyNavigation.left)
            }
        } else if (mode === manualFocusMode) {
            if (relativeX >= 1) {
                swipedRight()
                canceled()
            } else if (relativeX <= -1) {
                swipedLeft()
                canceled()
            }
        } else if (mode === panningMode) {
            xChanged(deltaX)
        }
    }

    function yInputHandler(deltaY) {
        if (yIsIncreasing === -1) {
            yIsIncreasing = (deltaY > 0) ? 1 : 0
        }

        if (accumulateAxisValue) {
            absoluteY += deltaY
        } else {
            if ((yIsIncreasing && deltaY > 0) ||
               (yIsIncreasing && deltaY < 0)) {
                absoluteY += deltaY
            } else {
                absoluteY = deltaY
                yIsIncreasing = (yIsIncreasing === 0) ? 1 : 0
            }
        }

        if (mode === autoFocusMode) {
            if (relativeY >= 1) {
                setFocusOnItem(item.KeyNavigation.down)
            } else if (relativeY <= -1) {
                setFocusOnItem(item.KeyNavigation.up)
            }
        } else if (mode === manualFocusMode) {
            if (relativeY >= 1) {
                swipedDown()
                canceled()
            } else if (relativeY <= -1) {
                swipedUp()
                canceled()
            }
        } else if (mode === positionSignalsMode) {
            yChanged(deltaY)
        }
    }

    onPressed: {
        acceptingInput = true
    }

    onReleased: {
        acceptingInput = false
        absoluteX = 0
        absoluteY = 0
        xIsIncreasing = -1
        yIsIncreasing = -1
    }

    onCanceled: {
        acceptingInput = false
        absoluteX = 0
        absoluteY = 0
        xIsIncreasing = -1
        yIsIncreasing = -1
    }

    function setFocusOnItem(targetItem) {
        if (targetItem && targetItem.enabled) {
            targetItem.forceActiveFocus()
            canceled()
        }
    }
}
