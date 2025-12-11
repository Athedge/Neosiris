// ProfileCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string profileId: ""
    property string profileName: ""
    property string profileFirstName: ""
    property string profileImage: ""
    property bool isActive: false
    property string cardType: "profile"
    
    signal viewClicked()
    signal editClicked()
    signal deleteClicked()
    signal exportClicked()
    signal activeToggled(bool active)
    
    width: parent.width
    height: 80
    color: mouseArea.containsMouse ? Qt.rgba(37, 150, 190, 0.1) : "#1E1E1E"
    radius: 12
    border.color: mouseArea.containsMouse ? "#2596be" : "#3B3B3B"
    border.width: 1
    
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: true
        onClicked: function(mouse) {
            mouse.accepted = false
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15
        
        // Image/Avatar circulaire
        Item {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            
            Rectangle {
                anchors.fill: parent
                radius: 25
                color: "#2B2B2B"
                border.color: "#3B3B3B"
                border.width: 2
            }
            
            Canvas {
                id: cardCanvas
                anchors.fill: parent
                anchors.margins: 2
                visible: (root.profileImage || "") !== "" && (root.profileImage || "").startsWith("file")
                
                property var loadedImage: null
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.save()
                    ctx.clearRect(0, 0, width, height)
                    
                    // Créer un clip circulaire
                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/2, 0, Math.PI * 2)
                    ctx.clip()
                    
                    if (loadedImage && loadedImage.status === Image.Ready) {
                        ctx.drawImage(loadedImage, 0, 0, width, height)
                    }
                    
                    ctx.restore()
                }
                
                Image {
                    id: cardImage
                    source: ((root.profileImage || "").startsWith("file")) ? root.profileImage : ""
                    visible: false
                    onStatusChanged: {
                        if (status === Image.Ready) {
                            cardCanvas.loadedImage = cardImage
                            cardCanvas.requestPaint()
                        }
                    }
                }
                
                Connections {
                    target: root
                    function onProfileImageChanged() {
                        if ((root.profileImage || "").startsWith("file")) {
                            cardImage.source = root.profileImage
                        } else {
                            cardImage.source = ""
                            cardCanvas.requestPaint()
                        }
                    }
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.profileImage && root.profileImage.length <= 4 ? root.profileImage : (root.cardType === "profile" ? "👤" : "🎭")
                font.pixelSize: 28
                visible: (root.profileImage || "") === "" || !(root.profileImage || "").startsWith("file")
            }
        }
        
        // Nom et prénom
        Column {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                text: root.profileName || "Sans nom"
                font.pixelSize: 14
                font.bold: true
                color: "#FFFFFF"
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                text: root.profileFirstName || ""
                font.pixelSize: 12
                color: "#888888"
                elide: Text.ElideRight
                width: parent.width
                visible: root.profileFirstName !== ""
            }
        }
        
        // Interrupteur actif/inactif
        Item {
            Layout.preferredWidth: 48
            Layout.minimumWidth: 48
            Layout.maximumWidth: 48
            Layout.preferredHeight: 32
            
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: root.isActive ? "#2596be" : "#3B3B3B"
                
                Behavior on color { ColorAnimation { duration: 200 } }
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: "#FFFFFF"
                    x: root.isActive ? parent.width - width - 4 : 4
                    y: 4
                    
                    Behavior on x { NumberAnimation { duration: 200 } }
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
        
        // Boutons d'action
        RowLayout {
            spacing: 6
            
            // Bouton Voir
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                background: Rectangle {
                    color: parent.hovered ? "#1e7da0" : "#2596be"
                    radius: 8
                }
                
                contentItem: Text {
                    text: "👁"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.viewClicked()
                
                ToolTip.visible: hovered
                ToolTip.text: "Voir"
                ToolTip.delay: 500
            }
            
            // Bouton Modifier
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                background: Rectangle {
                    color: parent.hovered ? "#1e7da0" : "#2596be"
                    radius: 8
                }
                
                contentItem: Text {
                    text: "✏️"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.editClicked()
                
                ToolTip.visible: hovered
                ToolTip.text: "Modifier"
                ToolTip.delay: 500
            }
            
            // Bouton Exporter
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                background: Rectangle {
                    color: parent.hovered ? "#1e7da0" : "#2596be"
                    radius: 8
                }
                
                contentItem: Text {
                    text: "📤"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.exportClicked()
                
                ToolTip.visible: hovered
                ToolTip.text: "Exporter"
                ToolTip.delay: 500
            }
            
            // Bouton Supprimer
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                background: Rectangle {
                    color: parent.hovered ? "#c0392b" : "#e74c3c"
                    radius: 8
                }
                
                contentItem: Text {
                    text: "🗑"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.deleteClicked()
                
                ToolTip.visible: hovered
                ToolTip.text: "Supprimer"
                ToolTip.delay: 500
            }
        }
    }
}
