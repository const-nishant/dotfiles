import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: cInk

    // config degerleri string gelir; `Number(x) || def` deseni "0"i falsy
    // sayip default'a duser, blurAmount=0 sessizce 0.06 olur. Bu yuzden
    // eksik/bozuk deger ile gecerli sifir burada acikca ayristirilir.
    function confNum(v, def) {
        if (v === undefined || v === null || v === "") return def
        var n = Number(v)
        return isNaN(n) ? def : n
    }

    // ================= scaling =================
    // Tema 1080p referans alinarak olculendi. 4K'da sabit pikseller ekranin
    // yarisi kadar kalir, o yuzden her olcu px() uzerinden gecer.
    //
    // Varsayilan 1.0: Qt'nin High-DPI autoscaling'i yogunluk telafisini zaten
    // yapiyor, ekran yuksekligini 1080'e oranlamak bunun ustune ikinci kez
    // binip 4K'da paneli iki katina cikariyor. Buyutmek isteyen elle verir.
    //
    // scale transform yerine bunun tercih edilmesinin sebebi: transform metni
    // temel boyutunda render edip buyutur ve bulaniklastirir; carpani pixelSize
    // icine koymak Qt'nin glyph'leri dogrudan hedef boyutta uretmesini saglar.
    readonly property real uiScale: Math.max(0.5, Math.min(3.0, confNum(config.uiScale, 1.0)))

    function px(v) { return Math.round(v * root.uiScale) }

    // ================= palette =================
    readonly property color cPaper:    config.paperColor    || "#e2d8bd"
    readonly property color cPaperDim: config.paperDimColor || "#c7bb9b"
    readonly property color cInk:      config.inkColor      || "#14120f"
    readonly property color cInkSoft:  config.inkSoftColor  || "#26221b"
    readonly property color cBlood:    config.accentColor   || "#8f2b22"

    readonly property real   tintAmount: confNum(config.tintAmount, 0.20)
    readonly property real   blurAmount: confNum(config.blurAmount, 0.06)
    readonly property string fontMain:   config.fontFamily || "JetBrainsMono Nerd Font"
    readonly property int    panelW:     px(confNum(config.panelWidth, 460))
    readonly property string panelPos:   (config.panelPosition || "left").toLowerCase()

    property bool busy: false

    // ================= artwork =================
    Image {
        id: bg
        anchors.fill: parent
        source: config.background || "backgrounds/wall.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: root.blurAmount <= 0.01
    }

    MultiEffect {
        anchors.fill: parent
        source: bg
        blurEnabled: root.blurAmount > 0.01
        blur: root.blurAmount
        blurMax: root.px(24)
        autoPaddingEnabled: false
        visible: root.blurAmount > 0.01
    }

    Rectangle {
        anchors.fill: parent
        color: cInk
        opacity: root.tintAmount
    }

    // yon farkindali karartma gecisi
    Rectangle {
        anchors.left:   root.panelPos === "right"  ? undefined : parent.left
        anchors.right:  root.panelPos === "left"   ? undefined : parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.panelPos === "center" ? parent.width : panelW * 2.2

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: root.panelPos === "right"
                    ? "transparent"
                    : Qt.rgba(cInk.r, cInk.g, cInk.b, root.panelPos === "center" ? 0.60 : 0.92)
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(cInk.r, cInk.g, cInk.b, root.panelPos === "center" ? 0.78 : 0.55)
            }
            GradientStop {
                position: 1.0
                color: root.panelPos === "left"
                    ? "transparent"
                    : Qt.rgba(cInk.r, cInk.g, cInk.b, root.panelPos === "center" ? 0.60 : 0.92)
            }
        }
    }

    QtObject { id: clock; property var now: new Date() }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.now = new Date() }

    // ================= panel =================
    Item {
        id: panel
        width: panelW
        height: stack.implicitHeight

        readonly property int edgeMargin: root.px(root.confNum(config.panelMargin, 88))
        property real shakeOffset: 0

        x: {
            if (root.panelPos === "right")  return root.width - width - edgeMargin
            if (root.panelPos === "center") return (root.width - width) / 2
            return edgeMargin
        }
        y: (root.height - height) / 2

        transform: Translate { x: panel.shakeOffset }

        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: stack
            width: parent.width
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(clock.now, config.timeFormat || "HH:mm")
                color: cPaper
                font.family: fontMain
                font.pixelSize: root.px(128)
                font.weight: Font.Bold
                font.letterSpacing: root.px(-6)
                lineHeight: 0.9
            }

            Item { Layout.preferredHeight: root.px(6) }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(clock.now, config.dateFormat || "dddd · d MMMM yyyy").toUpperCase()
                color: cPaperDim
                font.family: fontMain
                font.pixelSize: root.px(13)
                font.letterSpacing: root.px(4)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: root.px(30)
                Layout.bottomMargin: root.px(4)
                height: root.px(3)
                color: cPaper
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: root.px(30)
                height: root.px(1)
                color: cPaper
                opacity: 0.5
            }

            // ---------- USER ----------
            Text {
                Layout.fillWidth: true
                text: (config.userLabel || "USER").toUpperCase()
                color: cPaperDim
                font.family: fontMain
                font.pixelSize: root.px(10)
                font.letterSpacing: root.px(3)
            }

            ComboBox {
                id: userList
                Layout.fillWidth: true
                Layout.topMargin: root.px(2)
                Layout.preferredHeight: root.px(40)
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex

                contentItem: Text {
                    text: userList.currentText
                    color: root.cPaper
                    font.family: root.fontMain
                    font.pixelSize: root.px(26)
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    rightPadding: root.px(28)
                }

                background: Rectangle {
                    color: userList.hovered ? Qt.rgba(root.cPaper.r, root.cPaper.g, root.cPaper.b, 0.05)
                                            : "transparent"
                    Behavior on color { ColorAnimation { duration: 140 } }
                }

                indicator: Canvas {
                    id: userArrow
                    x: userList.width - width - 2
                    y: (userList.height - height) / 2
                    width: root.px(12); height: root.px(7)
                    rotation: userList.popup.visible ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.beginPath()
                        ctx.moveTo(0, 0)
                        ctx.lineTo(width, 0)
                        ctx.lineTo(width / 2, height)
                        ctx.closePath()
                        ctx.fillStyle = root.cPaperDim
                        ctx.fill()
                    }
                }

                popup: Popup {
                    y: userList.height + root.px(6)
                    width: userList.width
                    implicitHeight: Math.min(contentItem.implicitHeight + root.px(8), root.px(260))
                    padding: root.px(4)

                    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 } }
                    exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 110 } }

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: userList.popup.visible ? userList.delegateModel : null
                        currentIndex: userList.highlightedIndex
                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        color: root.cInk
                        border.color: root.cPaper
                        border.width: root.px(1)
                        radius: root.px(2)
                    }
                }

                delegate: Item {
                    id: userDeleg
                    required property string name
                    required property int index

                    width: userList.width - root.px(8)
                    height: root.px(38)

                    readonly property bool hot: userMouse.containsMouse
                    readonly property bool sel: userList.currentIndex === userDeleg.index

                    Rectangle {
                        anchors.fill: parent
                        radius: root.px(1)
                        color: userDeleg.hot ? root.cPaper : "transparent"
                        Behavior on color { ColorAnimation { duration: 110 } }
                    }

                    Text {
                        id: userMark
                        anchors.left: parent.left
                        anchors.leftMargin: root.px(8)
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.px(14)
                        text: userDeleg.sel ? "*" : ""
                        color: userDeleg.hot ? root.cInk : root.cPaper
                        font.family: root.fontMain
                        font.pixelSize: root.px(16)
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        anchors.left: userMark.right
                        anchors.leftMargin: root.px(6)
                        anchors.right: parent.right
                        anchors.rightMargin: root.px(10)
                        anchors.verticalCenter: parent.verticalCenter
                        text: userDeleg.name
                        color: userDeleg.hot ? root.cInk : root.cPaper
                        font.family: root.fontMain
                        font.pixelSize: root.px(15)
                        font.letterSpacing: root.px(1)
                        font.weight: userDeleg.sel ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: userMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            userList.currentIndex = userDeleg.index
                            userList.popup.close()
                        }
                    }
                }
            }

            // ---------- PASSWORD ----------
            Text {
                Layout.fillWidth: true
                Layout.topMargin: root.px(26)
                text: (config.passwordLabel || "PASSWORD").toUpperCase()
                color: errorText.visible ? cBlood : cPaperDim
                font.family: fontMain
                font.pixelSize: root.px(10)
                font.letterSpacing: root.px(3)
                Behavior on color { ColorAnimation { duration: 160 } }
            }

            Item {
                Layout.fillWidth: true
                Layout.topMargin: root.px(6)
                Layout.preferredHeight: root.px(46)

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(cPaper.r, cPaper.g, cPaper.b, 0.07)
                    border.width: pw.activeFocus ? 2 : 1
                    border.color: errorText.visible ? cBlood
                                : (pw.activeFocus ? cPaper : Qt.rgba(cPaper.r, cPaper.g, cPaper.b, 0.28))
                    radius: root.px(2)
                    Behavior on border.color { ColorAnimation { duration: 160 } }
                }

                TextField {
                    id: pw
                    anchors.fill: parent
                    anchors.leftMargin: root.px(14)
                    anchors.rightMargin: root.px(62)
                    echoMode: reveal.on ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "\u25CF"
                    color: cPaper
                    font.family: fontMain
                    font.pixelSize: root.px(15)
                    font.letterSpacing: root.px(3)
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle { color: "transparent" }
                    focus: true
                    enabled: !root.busy

                    Keys.onReturnPressed: root.doLogin()
                    Keys.onEnterPressed: root.doLogin()
                    onTextChanged: errorText.visible = false
                }

                Text {
                    id: reveal
                    property bool on: false
                    anchors.right: parent.right
                    anchors.rightMargin: root.px(14)
                    anchors.verticalCenter: parent.verticalCenter
                    text: reveal.on ? "HIDE" : "SHOW"
                    color: revealArea.containsMouse ? cPaper : cPaperDim
                    font.family: fontMain
                    font.pixelSize: root.px(9)
                    font.letterSpacing: root.px(2)
                    Behavior on color { ColorAnimation { duration: 140 } }
                    MouseArea {
                        id: revealArea
                        anchors.fill: parent
                        anchors.margins: root.px(-8)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: reveal.on = !reveal.on
                    }
                }
            }

            Text {
                id: errorText
                Layout.fillWidth: true
                Layout.topMargin: root.px(8)
                visible: false
                text: "» " + (config.errorMessage || "ACCESS DENIED")
                color: cBlood
                font.family: fontMain
                font.pixelSize: root.px(11)
                font.letterSpacing: root.px(2)
            }

            // ---------- ENTER ----------
            Rectangle {
                id: loginBtn
                Layout.fillWidth: true
                Layout.topMargin: root.px(26)
                Layout.preferredHeight: root.px(50)
                radius: root.px(2)
                clip: true

                color: root.busy ? Qt.rgba(cPaper.r, cPaper.g, cPaper.b, 0.55)
                     : (loginArea.containsMouse ? Qt.lighter(cPaper, 1.06) : cPaper)
                Behavior on color { ColorAnimation { duration: 150 } }

                scale: loginArea.pressed ? 0.99 : 1.0
                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    visible: !root.busy
                    text: (config.loginText || "ENTER").toUpperCase()
                    color: root.cInk
                    font.family: root.fontMain
                    font.pixelSize: root.px(14)
                    font.weight: Font.Bold
                    font.letterSpacing: root.px(6)
                }

                // ---- spinner: sadece giris sirasinda ----
                Item {
                    id: spinner
                    anchors.centerIn: parent
                    width: root.px(22); height: root.px(22)
                    visible: root.busy

                    Canvas {
                        id: ring
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var r = width / 2 - root.px(2)
                            ctx.lineWidth = root.px(2.5)
                            ctx.lineCap = "butt"

                            // ince taban halka
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2)
                            ctx.strokeStyle = Qt.rgba(root.cInk.r, root.cInk.g, root.cInk.b, 0.18)
                            ctx.stroke()

                            // donen yay
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, r, -Math.PI / 2, Math.PI * 1.05)
                            ctx.strokeStyle = root.cInk
                            ctx.stroke()
                        }
                    }

                    RotationAnimator {
                        target: spinner
                        running: root.busy
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }

                MouseArea {
                    id: loginArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !root.busy
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: root.px(30)
                height: root.px(1)
                color: cPaper
                opacity: 0.28
            }

            // ---------- SESSION + POWER ----------
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: root.px(14)
                spacing: 0

                ComboBox {
                    id: sessionCombo
                    Layout.preferredWidth: root.px(260)
                    Layout.preferredHeight: root.px(28)
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex

                    contentItem: Text {
                        text: sessionCombo.currentText.toUpperCase()
                        color: sessionCombo.hovered ? root.cPaper : root.cPaperDim
                        font.family: root.fontMain
                        font.pixelSize: root.px(10)
                        font.letterSpacing: root.px(2)
                        verticalAlignment: Text.AlignVCenter
                        rightPadding: root.px(22)
                        elide: Text.ElideRight
                        Behavior on color { ColorAnimation { duration: 140 } }
                    }

                    background: Rectangle { color: "transparent" }

                    indicator: Canvas {
                        x: sessionCombo.width - width - 2
                        y: (sessionCombo.height - height) / 2
                        width: root.px(9); height: root.px(5)
                        rotation: sessionCombo.popup.visible ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(width, 0)
                            ctx.lineTo(width / 2, height)
                            ctx.closePath()
                            ctx.fillStyle = root.cPaperDim
                            ctx.fill()
                        }
                    }

                    popup: Popup {
                        y: -implicitHeight - root.px(6)
                        width: root.px(240)
                        implicitHeight: Math.min(contentItem.implicitHeight + root.px(8), root.px(220))
                        padding: root.px(4)

                        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 } }
                        exit:  Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 110 } }

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: sessionCombo.popup.visible ? sessionCombo.delegateModel : null
                            currentIndex: sessionCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: root.cInk
                            border.color: root.cPaper
                            border.width: root.px(1)
                            radius: root.px(2)
                        }
                    }

                    delegate: Item {
                        id: sesDeleg
                        required property string name
                        required property int index

                        width: root.px(232)
                        height: root.px(32)

                        readonly property bool hot: sesMouse.containsMouse
                        readonly property bool sel: sessionCombo.currentIndex === sesDeleg.index

                        Rectangle {
                            anchors.fill: parent
                            radius: root.px(1)
                            color: sesDeleg.hot ? root.cPaper : "transparent"
                            Behavior on color { ColorAnimation { duration: 110 } }
                        }

                        Text {
                            id: sesMark
                            anchors.left: parent.left
                            anchors.leftMargin: root.px(8)
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.px(12)
                            text: sesDeleg.sel ? "*" : ""
                            color: sesDeleg.hot ? root.cInk : root.cPaper
                            font.family: root.fontMain
                            font.pixelSize: root.px(13)
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.left: sesMark.right
                            anchors.leftMargin: root.px(6)
                            anchors.right: parent.right
                            anchors.rightMargin: root.px(10)
                            anchors.verticalCenter: parent.verticalCenter
                            text: sesDeleg.name
                            color: sesDeleg.hot ? root.cInk : root.cPaper
                            font.family: root.fontMain
                            font.pixelSize: root.px(11)
                            font.letterSpacing: root.px(1)
                            font.weight: sesDeleg.sel ? Font.Medium : Font.Normal
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: sesMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                sessionCombo.currentIndex = sesDeleg.index
                                sessionCombo.popup.close()
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Repeater {
                    model: [
                        { label: "SLEEP",  act: "suspend",  show: sddm.canSuspend  },
                        { label: "REBOOT", act: "reboot",   show: sddm.canReboot   },
                        { label: "OFF",    act: "poweroff", show: sddm.canPowerOff }
                    ]

                    delegate: Text {
                        required property var modelData
                        visible: modelData.show
                        Layout.leftMargin: root.px(16)
                        text: modelData.label
                        color: pwrArea.containsMouse ? root.cBlood : root.cPaperDim
                        font.family: root.fontMain
                        font.pixelSize: root.px(10)
                        font.letterSpacing: root.px(2)
                        Behavior on color { ColorAnimation { duration: 140 } }

                        MouseArea {
                            id: pwrArea
                            anchors.fill: parent
                            anchors.margins: root.px(-8)
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.act === "poweroff") sddm.powerOff()
                                else if (modelData.act === "reboot") sddm.reboot()
                                else sddm.suspend()
                            }
                        }
                    }
                }
            }
        }
    }

    // ================= corner marks =================
    Repeater {
        model: [ { hx: 0, hy: 0 }, { hx: 1, hy: 0 }, { hx: 0, hy: 1 }, { hx: 1, hy: 1 } ]
        delegate: Item {
            required property var modelData
            width: root.px(22); height: root.px(22)
            x: panel.x - root.px(26) + modelData.hx * (panel.width + root.px(30))
            y: panel.y - root.px(26) + modelData.hy * (panel.height + root.px(30))
            opacity: panel.opacity * 0.55

            Rectangle {
                width: root.px(22); height: root.px(2); color: root.cPaper
                anchors.left:   modelData.hx === 0 ? parent.left : undefined
                anchors.right:  modelData.hx === 1 ? parent.right : undefined
                anchors.top:    modelData.hy === 0 ? parent.top : undefined
                anchors.bottom: modelData.hy === 1 ? parent.bottom : undefined
            }
            Rectangle {
                width: root.px(2); height: root.px(22); color: root.cPaper
                anchors.left:   modelData.hx === 0 ? parent.left : undefined
                anchors.right:  modelData.hx === 1 ? parent.right : undefined
                anchors.top:    modelData.hy === 0 ? parent.top : undefined
                anchors.bottom: modelData.hy === 1 ? parent.bottom : undefined
            }
        }
    }

    // ================= logic =================
    function doLogin() {
        if (root.busy || pw.text.length === 0) return
        root.busy = true
        sddm.login(userList.currentText, pw.text, sessionCombo.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            errorText.visible = true
            pw.text = ""
            pw.forceActiveFocus()
            shake.start()
        }
        function onLoginSucceeded() { root.busy = false }
    }

    SequentialAnimation {
        id: shake
        loops: 2
        NumberAnimation { target: panel; property: "shakeOffset"; to: -root.px(10); duration: 45 }
        NumberAnimation { target: panel; property: "shakeOffset"; to:  root.px(10); duration: 45 }
        NumberAnimation { target: panel; property: "shakeOffset"; to:   0; duration: 45 }
    }

    Component.onCompleted: pw.forceActiveFocus()
}
