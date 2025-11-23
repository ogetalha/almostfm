import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

ApplicationWindow {

    ListModel {
        id: stationModel

        ListElement {
            name: "Radio Paradise"
            url: "http://stream.radioparadise.com/mp3-192"
            freq: 88.5
        }

        ListElement {
            name: "Swiss Jazz"
            url: "http://stream.srg-ssr.ch/m/rsj/mp3_128"
            freq: 95.2
        }

        ListElement {
               name: "KEXP Seattle"
               url: "http://live-mp3-128.kexp.org/kexp128.mp3"
               freq: 101.7
           }

           ListElement {
               name: "Soma FM Groove Salad"
               url: "http://ice1.somafm.com/groovesalad-128-mp3"
               freq: 92.8
           }

           ListElement {
               name: "Jazz24"
               url: "http://live.wostreaming.net/direct/ppm-jazz24aac-ibc1"
               freq: 106.5
           }
       }

    visible: true
    width: 800
    height: 500
    title: "AlmostFM"

    Rectangle {
        anchors.fill: parent
        color: "#d6c3a1"
        border.color: "#3a2b1a"
        border.width: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 35
            spacing: 35

            Text {
                text: "AlmostFM"
                font.pixelSize: 46
                font.bold: true
                color: "#3a2b1a"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 60
                Layout.alignment: Qt.AlignHCenter

                // Dial Section
                Item {
                    id: dial
                    width: 260; height: 260
                    Layout.alignment: Qt.AlignHCenter

                    property real minFreq: 80.0
                    property real maxFreq: 110.0
                    property real value: 88.5
                    property real angle: (value - minFreq) / (maxFreq - minFreq) * 270 - 135
                    property string currentStation: ""
                    signal frequencyChanged(real freq)

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#c3ab84" }
                            GradientStop { position: 1; color: "#ae9469" }
                        }
                        border.color: "#3a2b1a"
                        border.width: 6
                    }

                    // Dial tick marks
                    Repeater {
                        model: 11

                        Rectangle {
                            width: 4
                            height: 16
                            color: "#3a2b1a"
                            radius: 1

                            property real tickAngle: -135 + index * 27
                            property real rad: (tickAngle - 90) * Math.PI / 180   // FIX HERE

                            x: dial.width/2  - width/2 + Math.cos(rad) * (dial.width/2 - 30)
                            y: dial.height/2 - height/2 + Math.sin(rad) * (dial.height/2 - 30)

                            rotation: tickAngle
                        }
                    }



                    // Needle
                    Rectangle {
                        id: needle
                        width: 6
                        height: dial.height/2 - 35
                        color: "#b01818"
                        radius: 3
                        x: dial.width/2 - width/2
                        y: dial.height/2 - height
                        transformOrigin: Item.Bottom
                        rotation: dial.angle
                    }

                    // Center cap
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: "#3a2b1a"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: updateDialFromMouse(mouse.x, mouse.y)
                        onPositionChanged: {
                            if (pressed) {
                                updateDialFromMouse(mouse.x, mouse.y)
                            }
                        }

                        function updateDialFromMouse(mouseX, mouseY) {
                            const dx = mouseX - width/2
                            const dy = mouseY - height/2
                            let deg = Math.atan2(dy, dx) * 180 / Math.PI

                            // Clamp to valid range (-135 to 135)
                            deg = Math.max(-135, Math.min(135, deg))

                            dial.angle = deg
                            dial.value = dial.minFreq + ((deg + 135) / 270) * (dial.maxFreq - dial.minFreq)
                            dial.frequencyChanged(dial.value)
                        }
                    }

                    Text {
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 10
                        text: dial.value.toFixed(1) + " MHz"
                        font.pixelSize: 24
                        color: "#3a2b1a"
                    }
                }

                // Retro Screen
                Rectangle {
                    width: 320; height: 180
                    radius: 14
                    color: "#3a2b1a"
                    border.color: "#000"
                    border.width: 3
                    Layout.alignment: Qt.AlignVCenter

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: radioStatus.playing ? "Tuned In" : "Searching..."
                            color: "#e4d7c5"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }

                        Text {
                            text: radioStatus.playing ? dial.currentStation : "Static"
                            color: "#e4d7c5"
                            font.pixelSize: 16
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 14
                            Layout.alignment: Qt.AlignHCenter

                            Button { text: "Pause"; onClicked: radioStatus.pause() }
                            Button { text: "Resume"; onClicked: radioStatus.resume() }
                            Button { text: "Stop"; onClicked: radioStatus.stop() }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: dial
        function onFrequencyChanged(freq) {
            let nearest = null;
            let minDiff = 999;

            for (let i = 0; i < stationModel.count; i++) {
                let st = stationModel.get(i);
                let diff = Math.abs(st.freq - freq);
                if (diff < minDiff && diff < 0.3) {
                    minDiff = diff;
                    nearest = st;
                }
            }

            if (nearest) {
                dial.currentStation = nearest.name;
                radioStatus.play(nearest.url);
            } else {
                dial.currentStation = "";
                radioStatus.stop();
            }
        }
    }
}
