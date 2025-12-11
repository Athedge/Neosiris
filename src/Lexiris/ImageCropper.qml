// ImageCropper.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string imagePath: ""
    property real zoomLevel: 1.0
    property bool circularMask: true
    
    width: 200
    height: 200
    color: "#2B2B2B"
    radius: circularMask ? width / 2 : 12
    border.color: "#3B3B3B"
    border.width: 2
    
    clip: true
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        clip: true
        radius: root.circularMask ? width / 2 : 12
        
        Image {
            id: displayImage
            anchors.centerIn: parent
            width: parent.width * root.zoomLevel
            height: parent.height * root.zoomLevel
            source: root.imagePath
            fillMode: Image.PreserveAspectCrop
            smooth: true
            
            property point dragStart: Qt.point(0, 0)
            property point imageOffset: Qt.point(0, 0)
            
            x: imageOffset.x
            y: imageOffset.y
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                
                onPressed: {
                    parent.dragStart = Qt.point(mouse.x, mouse.y)
                    cursorShape = Qt.ClosedHandCursor
                }
                
                onPositionChanged: {
                    if (pressed) {
                        var dx = mouse.x - parent.dragStart.x
                        var dy = mouse.y - parent.dragStart.y
                        parent.imageOffset = Qt.point(
                            Math.max(Math.min(parent.imageOffset.x + dx, 50), -50),
                            Math.max(Math.min(parent.imageOffset.y + dy, 50), -50)
                        )
                        parent.dragStart = Qt.point(mouse.x, mouse.y)
                    }
                }
                
                onReleased: {
                    cursorShape = Qt.OpenHandCursor
                }
            }
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: root.imagePath === ""
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "📷"
            font.pixelSize: 48
        }
        
        Text {
            text: "Aucune image"
            font.pixelSize: 11
            color: "#888888"
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            // Appeler une fonction Python pour ouvrir le sélecteur de fichier
            var path = profilesModule.selectImageFile()
            if (path) {
                root.imagePath = path
                root.zoomLevel = 1.0
                displayImage.imageOffset = Qt.point(0, 0)
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.5)
            visible: parent.containsMouse
            radius: root.circularMask ? width / 2 : 12
            
            Text {
                anchors.centerIn: parent
                text: root.imagePath === "" ? "Cliquer pour ajouter" : "Cliquer pour changer"
                font.pixelSize: 11
                color: "#FFFFFF"
            }
        }
    }
    
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8
        spacing: 8
        visible: root.imagePath !== ""
        
        Button {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            
            background: Rectangle {
                color: parent.hovered ? "#1e7da0" : "#2596be"
                radius: 15
                opacity: 0.9
            }
            
            contentItem: Text {
                text: "−"
                font.pixelSize: 18
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                root.zoomLevel = Math.max(0.5, root.zoomLevel - 0.1)
            }
        }
        
        Text {
            text: Math.round(root.zoomLevel * 100) + "%"
            font.pixelSize: 11
            color: "#FFFFFF"
            Layout.preferredWidth: 45
            horizontalAlignment: Text.AlignHCenter
            
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                color: Qt.rgba(0, 0, 0, 0.7)
                radius: 4
                z: -1
            }
        }
        
        Button {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            
            background: Rectangle {
                color: parent.hovered ? "#1e7da0" : "#2596be"
                radius: 15
                opacity: 0.9
            }
            
            contentItem: Text {
                text: "+"
                font.pixelSize: 18
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                root.zoomLevel = Math.min(3.0, root.zoomLevel + 0.1)
            }
        }
    }
}
