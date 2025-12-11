// PiecesPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#0A0A0A"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#0A0A0A"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                spacing: 20
                
                Text {
                    text: "📄 Pièces"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#FFFFFF"
                    Layout.fillWidth: true
                }
            }
        }
        
        // Contenu 4 colonnes
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 20
            
            // COLONNE 1: DOSSIER
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Dossier"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "🔍 Rechercher..."
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: parent.parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                        
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            text: "➕"
                            ToolTip.text: "Ajouter"
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        
                        Column {
                            width: parent.parent.width - 20
                            spacing: 10
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 50
                                text: "Aucun dossier"
                                font.pixelSize: 14
                                color: "#666666"
                            }
                        }
                    }
                }
            }
            
            // COLONNE 2: CLIENT
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Client"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "🔍 Rechercher..."
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: parent.parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                        
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            text: "➕"
                            ToolTip.text: "Ajouter"
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        
                        Column {
                            width: parent.parent.width - 20
                            spacing: 10
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 50
                                text: "Aucun client"
                                font.pixelSize: 14
                                color: "#666666"
                            }
                        }
                    }
                }
            }
            
            // COLONNE 3: BORDEREAUX
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Bordereaux"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "🔍 Rechercher..."
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: parent.parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                        
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            text: "➕"
                            ToolTip.text: "Ajouter"
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        
                        Column {
                            width: parent.parent.width - 20
                            spacing: 10
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 50
                                text: "Aucun bordereau"
                                font.pixelSize: 14
                                color: "#666666"
                            }
                        }
                    }
                }
            }
            
            // COLONNE 4: ADVERSAIRE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Adversaire"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#FFFFFF"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "🔍 Rechercher..."
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: parent.parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                        
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            text: "➕"
                            ToolTip.text: "Ajouter"
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        
                        Column {
                            width: parent.parent.width - 20
                            spacing: 10
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 50
                                text: "Aucun adversaire"
                                font.pixelSize: 14
                                color: "#666666"
                            }
                        }
                    }
                }
            }
        }
    }
}
