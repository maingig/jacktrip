import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Item {
    width: parent.width; height: parent.height
    clip: true
    
    property bool connecting: false
    
    property int leftHeaderMargin: 16
    property int fontBig: 28
    property int fontMedium: 12
    property int fontSmall: 10
    property int fontTiny: 8

    property int bodyMargin: 60
    property int bottomToolTipMargin: 8
    property int rightToolTipMargin: 4
    
    property string buttonColour: virtualstudio.darkMode ? "#494646" : "#EAECEC"
    property string muteButtonMutedColor: "#FCB6B6"
    property string textColour: virtualstudio.darkMode ? "#FAFBFB" : "#0F0D0D"
    property string meterColor: virtualstudio.darkMode ? "gray" : "#E0E0E0"
    property real imageLightnessValue: virtualstudio.darkMode ? 1.0 : 0.0
    property real muteButtonLightnessValue: virtualstudio.darkMode ? 1.0 : 0.0
    property real muteButtonMutedLightnessValue: 0.24
    property real muteButtonMutedSaturationValue: 0.73
    property string buttonStroke: virtualstudio.darkMode ? "#80827D7D" : "#34979797"
    property string sliderColour: virtualstudio.darkMode ? "#BABCBC" :  "#EAECEC"
    property string sliderPressedColour: virtualstudio.darkMode ? "#ACAFAF" : "#DEE0E0"
    property string shadowColour: virtualstudio.darkMode ? "#40000000" : "#80A1A1A1"
    property string toolTipBackgroundColour: virtualstudio.darkMode ? "#323232" : "#F3F3F3"
    property string toolTipTextColour: textColour

    property string meterGreen: "#61C554"
    property string meterYellow: "#F5BF4F"
    property string meterRed: "#F21B1B"

    function getNetworkStatsText (networkStats) {
        let minRtt = networkStats.minRtt;
        let maxRtt = networkStats.maxRtt;
        let avgRtt = networkStats.avgRtt;

        let texts = ["Measuring stats ...", ""];

        if (!minRtt || !maxRtt) {
            return texts;
        }

        texts[0] = "<b>" + minRtt + " ms - " + maxRtt + " ms</b>, avg " + avgRtt + " ms round-trip time";

        let quality = "poor";
        if (avgRtt <= 25) {

            if (maxRtt <= 30) {
                quality = "excellent";
            } else {
                quality = "good";
            }

        } else if (avgRtt <= 30) {
            quality = "good";
        } else if (avgRtt <= 35) {
            quality = "fair";
        }

        texts[1] = "Your connection quality is <b>" + quality + "</b>."
        return texts;
    }

    Image {
        id: jtlogo
        x: parent.width - (49 * virtualstudio.uiScale); y: 16 * virtualstudio.uiScale
        width: 32 * virtualstudio.uiScale; height: 59 * virtualstudio.uiScale
        source: "logo.svg"
        sourceSize: Qt.size(jtlogo.width,jtlogo.height)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
    
    Text {
        id: heading
        text: virtualstudio.connectionState
        x: leftHeaderMargin * virtualstudio.uiScale; y: 34 * virtualstudio.uiScale
        font { family: "Poppins"; weight: Font.Bold; pixelSize: fontBig * virtualstudio.fontScale * virtualstudio.uiScale }
        color: textColour
    }
    
    Studio {
        x: leftHeaderMargin * virtualstudio.uiScale; y: 96 * virtualstudio.uiScale
        width: parent.width - (2 * x)
        connected: true
        serverLocation: virtualstudio.currentStudio >= 0 && virtualstudio.regions[serverModel[virtualstudio.currentStudio].location] ? "in " + virtualstudio.regions[serverModel[virtualstudio.currentStudio].location].label : ""
        flagImage: virtualstudio.currentStudio >= 0 ? ( serverModel[virtualstudio.currentStudio].bannerURL ? serverModel[virtualstudio.currentStudio].bannerURL : serverModel[virtualstudio.currentStudio].flag ) : "flags/DE.svg"
        studioName: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].name : "Test Studio"
        publicStudio: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].isPublic : false
        manageable: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].isManageable : false
        available: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].canConnect : false
        studioId: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].id : ""
        inviteKeyString: virtualstudio.currentStudio >= 0 ? serverModel[virtualstudio.currentStudio].inviteKey : ""
    }

    Item {
        id: inputDevice
        x: bodyMargin * virtualstudio.uiScale; y: 230 * virtualstudio.uiScale
        width: Math.min(parent.width / 2, 320 * virtualstudio.uiScale) - x
        height: 100 * virtualstudio.uiScale
        clip: true

        Image {
            id: mic
            source: "mic.svg"
            x: 0; y: 0
            width: 18 * virtualstudio.uiScale; height: 28 * virtualstudio.uiScale
            sourceSize: Qt.size(mic.width,mic.height)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Colorize {
            anchors.fill: mic
            source: mic
            hue: 0
            saturation: 0
            lightness: imageLightnessValue
        }

        Text {
            id: inputDeviceHeader
            x: 64 * virtualstudio.uiScale
            width: parent.width - 64 * virtualstudio.uiScale
            text: "<b>Input Device</b>"
            font {family: "Poppins"; pixelSize: fontMedium * virtualstudio.fontScale * virtualstudio.uiScale }
            anchors.verticalCenter: mic.verticalCenter
            color: textColour
            elide: Text.ElideRight
        }

        Text {
            id: inputDeviceName
            width: parent.width - 100 * virtualstudio.uiScale
            anchors.top: inputDeviceHeader.bottom
            anchors.left: inputDeviceHeader.left
            text: virtualstudio.audioBackend == "JACK" ?
                virtualstudio.audioBackend : inputComboModel.filter(item => item.type === "element")[virtualstudio.inputDevice].text
            font {family: "Poppins"; pixelSize: fontTiny * virtualstudio.fontScale * virtualstudio.uiScale }
            color: textColour
            elide: Text.ElideRight
        }
    }

    Item {
        id: outputDevice
        x: bodyMargin * virtualstudio.uiScale; y: 320 * virtualstudio.uiScale
        width: Math.min(parent.width / 2, 320 * virtualstudio.uiScale) - x
        height: 100 * virtualstudio.uiScale
        clip: true

        Image {
            id: headphones
            source: "headphones.svg"
            x: 0; y: 0
            width: 28 * virtualstudio.uiScale; height: 28 * virtualstudio.uiScale
            sourceSize: Qt.size(headphones.width,headphones.height)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Colorize {
            anchors.fill: headphones
            source: headphones
            hue: 0
            saturation: 0
            lightness: imageLightnessValue
        }

        Text {
            id: outputDeviceHeader
            x: 64 * virtualstudio.uiScale
            width: parent.width - 64 * virtualstudio.uiScale
            text: "<b>Output Device</b>"
            font {family: "Poppins"; pixelSize: fontMedium * virtualstudio.fontScale * virtualstudio.uiScale }
            anchors.verticalCenter: headphones.verticalCenter
            color: textColour
            elide: Text.ElideRight
        }

        Text {
            id: outputDeviceName
            width: parent.width - 100 * virtualstudio.uiScale
            anchors.top: outputDeviceHeader.bottom
            anchors.left: outputDeviceHeader.left
            text: virtualstudio.audioBackend == "JACK" ?
                virtualstudio.audioBackend : outputComboModel.filter(item => item.type === "element")[virtualstudio.outputDevice].text
            font {family: "Poppins"; pixelSize: fontTiny * virtualstudio.fontScale * virtualstudio.uiScale }
            color: textColour
            elide: Text.ElideRight
        }
    }

    Item {
        id: inputControls
        x: inputDevice.x + inputDevice.width; y: 230 * virtualstudio.uiScale
        width: parent.width - inputDevice.width - 2 * bodyMargin * virtualstudio.uiScale

        Meter {
            id: inputDeviceMeters
            x: 0; y: 0
            width: parent.width
            height: 100 * virtualstudio.uiScale
            model: inputMeterModel
            clipped: inputClipped
        }

        Slider {
            id: inputSlider
            from: 0.0
            value: virtualstudio ? virtualstudio.inputVolume : 0.5
            onMoved: { virtualstudio.inputVolume = value }
            to: 1.0
            enabled: !virtualstudio.inputMuted
            padding: 0
            y: inputDeviceMeters.y + 36 * virtualstudio.uiScale
            anchors.left: inputMute.right
            anchors.leftMargin: 8 * virtualstudio.uiScale
            anchors.right: inputDeviceMeters.right
            opacity: virtualstudio.inputMuted ? 0.3 : 1
            handle: Rectangle {
                x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                implicitWidth: 26 * virtualstudio.uiScale
                implicitHeight: 26 * virtualstudio.uiScale
                radius: 13 * virtualstudio.uiScale
                color: inputSlider.pressed ? sliderPressedColour : sliderColour
                border.color: buttonStroke
                opacity: virtualstudio.inputMuted ? 0.3 : 1
            }
        }

        Button {
            id: inputMute
            width: 24 * virtualstudio.uiScale
            height: 24
            anchors.left: inputDeviceMeters.left
            anchors.verticalCenter: inputDeviceMeters.verticalCenter
            background: Rectangle {
                color: virtualstudio.inputMuted ? muteButtonMutedColor : buttonColour
                width: 24 * virtualstudio.uiScale
                radius: 4 * virtualstudio.uiScale
            }
            onClicked: { virtualstudio.inputMuted = !virtualstudio.inputMuted }
            Image {
                id: micMute
                width: 11.57 * virtualstudio.uiScale; height: 18 * virtualstudio.uiScale
                anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
                source: virtualstudio.inputMuted ? "micoff.svg" : "mic.svg"
                sourceSize: Qt.size(micMute.width,micMute.height)
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            Colorize {
                anchors.fill: micMute
                source: micMute
                hue: 0
                saturation: virtualstudio.inputMuted ? muteButtonMutedSaturationValue : 0
                lightness: virtualstudio.inputMuted ? (inputMute.hovered ? muteButtonMutedLightnessValue + .1 : muteButtonMutedLightnessValue) : (inputMute.hovered ? muteButtonLightnessValue - .1 : muteButtonLightnessValue)
            }
            ToolTip {
                parent: inputMute
                visible: inputMute.hovered
                bottomPadding: bottomToolTipMargin * virtualstudio.uiScale
                rightPadding: rightToolTipMargin * virtualstudio.uiScale
                delay: 100
                contentItem: Rectangle {
                    color: toolTipBackgroundColour
                    radius: 3
                    anchors.fill: parent
                    anchors.bottomMargin: bottomToolTipMargin * virtualstudio.uiScale
                    anchors.rightMargin: rightToolTipMargin * virtualstudio.uiScale
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 1 * virtualstudio.uiScale
                        verticalOffset: 1 * virtualstudio.uiScale
                        radius: 10.0 * virtualstudio.uiScale
                        samples: 21
                        color: shadowColour
                    }

                    Text {
                        anchors.centerIn: parent
                        font { family: "Poppins"; pixelSize: fontSmall * virtualstudio.fontScale * virtualstudio.uiScale}
                        text: virtualstudio.inputMuted ?  qsTr("Click to unmute yourself") : qsTr("Click to mute yourself")
                        color: toolTipTextColour
                    }
                }
                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }

    Item {
        id: outputControls
        x: outputDevice.x + outputDevice.width; y: 320 * virtualstudio.uiScale
        width: parent.width - inputDevice.width - 2 * bodyMargin * virtualstudio.uiScale

        Meter {
            id: outputDeviceMeters
            x: 0; y: 0
            width: parent.width
            height: 100 * virtualstudio.uiScale
            model: outputMeterModel
            clipped: outputClipped
        }

        Slider {
            id: outputSlider
            from: 0.0
            value: virtualstudio ? virtualstudio.outputVolume : 0.5
            onMoved: { virtualstudio.outputVolume = value }
            to: 1.0
            padding: 0
            y: outputDeviceMeters.y + 36 * virtualstudio.uiScale
            anchors.left: outputDeviceMeters.left
            anchors.right: outputDeviceMeters.right
            handle: Rectangle {
                x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2
                implicitWidth: 26 * virtualstudio.uiScale
                implicitHeight: 26 * virtualstudio.uiScale
                radius: 13 * virtualstudio.uiScale
                color: outputSlider.pressed ? sliderPressedColour : sliderColour
                border.color: buttonStroke
            }
        }
    }

    Item {
        id: networkStatsHeader
        x: bodyMargin * virtualstudio.uiScale; y: 410 * virtualstudio.uiScale
        width: Math.min(parent.width / 2, 320 * virtualstudio.uiScale) - x
        height: 128 * virtualstudio.uiScale

        Image {
            id: network
            source: "network.svg"
            x: 0; y: 0
            width: 28 * virtualstudio.uiScale; height: 28 * virtualstudio.uiScale
            sourceSize: Qt.size(network.width,network.height)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Colorize {
            anchors.fill: network
            source: network
            hue: 0
            saturation: 0
            lightness: imageLightnessValue
        }

        Text {
            id: networkStatsHeaderText
            text: "<b>Network</b>"
            font {family: "Poppins"; pixelSize: fontMedium * virtualstudio.fontScale * virtualstudio.uiScale }
            x: 64 * virtualstudio.uiScale
            anchors.verticalCenter: network.verticalCenter
            color: textColour
        }
    }

    Item {
        id: networkStatsText
        x: networkStatsHeader.x + networkStatsHeader.width; y: 410 * virtualstudio.uiScale
        width: parent.width - networkStatsHeader.width - 2 * bodyMargin * virtualstudio.uiScale
        height: 128 * virtualstudio.uiScale

        Text {
            id: netstat0
            x: 0; y: 0
            text: getNetworkStatsText(virtualstudio.networkStats)[0]
            font {family: "Poppins"; pixelSize: fontTiny * virtualstudio.fontScale * virtualstudio.uiScale }
            color: textColour
        }

        Text {
            id: netstat1
            x: 0
            text: getNetworkStatsText(virtualstudio.networkStats)[1]
            font {family: "Poppins"; pixelSize: fontTiny * virtualstudio.fontScale * virtualstudio.uiScale }
            topPadding: 8 * virtualstudio.uiScale
            anchors.top: netstat0.bottom
            color: textColour
        }
    }
}
