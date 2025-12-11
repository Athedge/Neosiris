// EmojiPicker.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    signal emojiSelected(string emoji)
    
    width: 350
    height: 300
    color: "#1E1E1E"
    radius: 12
    border.color: "#3B3B3B"
    border.width: 1
    
    // Pack d'emojis de visages
    property var emojis: [
        "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂",
        "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩",
        "😘", "😗", "☺️", "😚", "😙", "🥲", "😋", "😛",
        "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
        "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄",
        "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷",
        "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴",
        "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐",
        "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳",
        "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭",
        "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱",
        "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️"
    ]
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        Text {
            text: "Choisir un emoji"
            font.pixelSize: 14
            font.bold: true
            color: "#FFFFFF"
        }
        
        ScrollView {
            width: parent.width
            height: parent.height - 30
            clip: true
            
            Grid {
                width: parent.width
                columns: 8
                spacing: 8
                
                Repeater {
                    model: root.emojis
                    
                    Rectangle {
                        width: 40
                        height: 40
                        color: mouseArea.containsMouse ? "#2596be" : "#252525"
                        radius: 8
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 24
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.emojiSelected(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
