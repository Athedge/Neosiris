// ProfileItem.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string itemId: ""
    property string itemName: ""
    property string itemSubtitle: ""
    property string imagePath: ""
    property bool isActive: false
    property string itemType: "profile"
    
    signal viewClicked()
    signal editClicked()
    signal exportClicked()
    signal activeToggled(bool active)
    
    width: parent.width
    height: 70
    color: mouseArea.containsMouse ? Qt.rgba(37, 150, 190, 0.1) : "#1E1E1E"
    radius: 12
    border.color: mouseArea.containsMouse ? "#2596be" : "#3B3B3B"
    border.width: 1
    
    Behavior on color {
        ColorAnimation { duration: 200 }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.viewClicked()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            radius: 25
            color: "#2B2B2B"
            border.color: "#3B3B3B"
            border.width: 2
            clip: true
            
            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: root.imagePath || ""
                fillMode: Image.PreserveAspectCrop
                visible: root.imagePath !== ""
                smooth: true
            }
            
            Text {
                anchors.centerIn: parent
                text: root.itemType === "profile" ? "👤" : "✍️"
                font.pixelSize: 32
                visible: root.imagePath === ""
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                text: root.itemName || "Sans nom"
                font.pixelSize: 13
                font.bold: true
                color: "#FFFFFF"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            Text {
                text: root.itemSubtitle || ""
                font.pixelSize: 11
                color: "#888888"
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: root.itemSubtitle !== ""
            }
        }
        
        RowLayout {
            spacing: 8
            
            Button {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                
                background: Rectangle {
                    color: parent.hovered ? "#3498db" : "transparent"
                    radius: 6
                    border.color: "#3498db"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: "👁"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    mouse.accepted = true
                    root.viewClicked()
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Voir"
                ToolTip.delay: 500
            }
            
            Button {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                
                background: Rectangle {
                    color: parent.hovered ? "#f39c12" : "transparent"
                    radius: 6
                    border.color: "#f39c12"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: "✏️"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    mouse.accepted = true
                    root.editClicked()
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Modifier"
                ToolTip.delay: 500
            }
            
            Button {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                
                background: Rectangle {
                    color: parent.hovered ? "#27ae60" : "transparent"
                    radius: 6
                    border.color: "#27ae60"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: "📤"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    mouse.accepted = true
                    root.exportClicked()
                }
                
                ToolTip.visible: hovered
                ToolTip.text: "Exporter"
                ToolTip.delay: 500
            }
        }
        
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 24
            radius: 12
            color: root.isActive ? "#2596be" : "#3B3B3B"
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: "#FFFFFF"
                x: root.isActive ? parent.width - width - 2 : 2
                y: 2
                
                Behavior on x {
                    NumberAnimation { duration: 200 }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.isActive = !root.isActive
                    root.activeToggled(root.isActive)
                }
            }
        }
    }
}
