pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import qs.utils


Item {
    id: root

    required property Session session
    property list<string> monitorNames: Hypr.monitorNames()

    anchors.fill: parent

    ClippingRectangle {
        id: taskbarClippingRect

        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.normal

        radius: taskbarBorder.innerRadius
        color: "transparent"

        Loader {
            id: taskbarLoader

            anchors.fill: parent
            anchors.margins: Appearance.padding.large + Appearance.padding.normal
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large

            asynchronous: true
            sourceComponent: taskbarContentComponent
        }
    }

    InnerBorder {
        id: taskbarBorder

        leftThickness: 0
        rightThickness: Appearance.padding.normal
    }

    Component {
        id: taskbarContentComponent

        StyledFlickable {
            id: sidebarFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: sidebarLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: sidebarFlickable
            }

            ColumnLayout {
                id: sidebarLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Appearance.spacing.normal

                RowLayout {
                    spacing: Appearance.spacing.smaller

                    StyledText {
                        text: qsTr("Touch")
                        font.pointSize: Appearance.font.size.large
                        font.weight: 500
                    }
                }

                GridLayout {
                    id: monitorGrid
                    
                    columns: 3 

                    Repeater {
                        model: root.monitorNames

                        delegate: SectionContainer {
                            id: monitorDelegate

                            required property var modelData
                            readonly property string screenName: {
                                if (typeof modelData === "string") return modelData;
                                if (modelData && modelData.name) return modelData.name;
                                return "Unknown";
                            }

                            StyledText {
                                text: modelData
                                font.pointSize: Appearance.font.size.small
                                opacity: 0.7
                                font.weight: 600
                            }
                            Repeater {
                                model: [
                                    { "id": "dashboard", "name": qsTr("Dashboard") },
                                    { "id": "launcher",  "name": qsTr("Launcher") },
                                    { "id": "osd",       "name": qsTr("OSD") },
                                    { "id": "utilities", "name": qsTr("Utilities") }
                                ]

                                delegate: SwitchRow {
                                    label: modelData.name
                                    checked: (Config.touch && Config.touch[monitorDelegate.screenName]) ? Config.touch[monitorDelegate.screenName][modelData.id] : false

                                    required property var modelData

                                    onToggled: checked => {
                                        if (!Config.touch[monitorDelegate.screenName]) Config.touch[monitorDelegate.screenName] = {};
                                        
                                        Config.touch[monitorDelegate.screenName][modelData.id] = checked;
                                        Config.save();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
