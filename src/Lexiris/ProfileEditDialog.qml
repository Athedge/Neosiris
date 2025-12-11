// ProfileEditDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Popup {
    id: dialog
    modal: true
    focus: true
    width: 600
    height: 700
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape
    
    property var profileData: ({})
    property string mode: "add"
    property string cardType: "profile"
    property string currentImage: ""
    
    signal saved(var data)
    
    onProfileDataChanged: {
        currentImage = profileData.image || ""
    }
    
    onOpened: {
        currentImage = profileData.image || ""
        previewContainer.imageOffset = Qt.point(0, 0)
        previewContainer.zoomLevel = 1.0
        zoomSlider.value = 1.0
    }
    
    background: Rectangle {
        radius: 12
        color: "#1E1E1E"
        border.color: "#3B3B3B"
        border.width: 1
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: {
                    if (dialog.mode === "view") return "Voir le " + (dialog.cardType === "profile" ? "profil" : "avocat")
                    if (dialog.mode === "edit") return "Modifier le " + (dialog.cardType === "profile" ? "profil" : "avocat")
                    return "Ajouter un " + (dialog.cardType === "profile" ? "profil" : "avocat")
                }
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
                Layout.fillWidth: true
            }
            
            Button {
                text: "✕"
                font.pixelSize: 18
                flat: true
                onClicked: dialog.close()
                
                background: Rectangle {
                    color: parent.hovered ? "#e74c3c" : "transparent"
                    radius: 6
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        // ScrollView pour tout le contenu
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            
            ColumnLayout {
                width: parent.parent.width - 20
                spacing: 15
                
                // Section Image
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 280
                    color: "#252525"
                    radius: 10
                    border.color: "#3B3B3B"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "📷 Image du profil"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#FFFFFF"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            // Preview image circulaire avec crop/zoom  
                            Rectangle {
                                id: previewContainer
                                Layout.preferredWidth: 180
                                Layout.preferredHeight: 180
                                radius: 90
                                color: "#2B2B2B"
                                border.color: "#3B3B3B"
                                border.width: 2
                                
                                property point imageOffset: Qt.point(0, 0)
                                property real zoomLevel: 1.0
                                
                                Canvas {
                                    id: previewCanvas
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    visible: dialog.currentImage !== "" && dialog.currentImage.startsWith("file")
                                    
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
                                            var imgWidth = width * previewContainer.zoomLevel
                                            var imgHeight = height * previewContainer.zoomLevel
                                            var x = (width - imgWidth) / 2 + previewContainer.imageOffset.x
                                            var y = (height - imgHeight) / 2 + previewContainer.imageOffset.y
                                            ctx.drawImage(loadedImage, x, y, imgWidth, imgHeight)
                                        }
                                        
                                        ctx.restore()
                                    }
                                    
                                    Image {
                                        id: previewImage
                                        source: dialog.currentImage
                                        visible: false
                                        onStatusChanged: {
                                            if (status === Image.Ready) {
                                                previewCanvas.loadedImage = previewImage
                                                previewCanvas.requestPaint()
                                            }
                                        }
                                    }
                                }
                                
                                onImageOffsetChanged: previewCanvas.requestPaint()
                                onZoomLevelChanged: previewCanvas.requestPaint()
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.ArrowCursor
                                    enabled: dialog.mode !== "view" && dialog.currentImage.startsWith("file")
                                    hoverEnabled: true
                                    
                                    property point dragStart: Qt.point(0, 0)
                                    
                                    onPressed: function(mouse) {
                                        dragStart = Qt.point(mouse.x, mouse.y)
                                    }
                                    
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var dx = mouse.x - dragStart.x
                                            var dy = mouse.y - dragStart.y
                                            
                                            var newX = previewContainer.imageOffset.x + dx
                                            var newY = previewContainer.imageOffset.y + dy
                                            
                                            var maxOffset = 100
                                            newX = Math.max(Math.min(newX, maxOffset), -maxOffset)
                                            newY = Math.max(Math.min(newY, maxOffset), -maxOffset)
                                            
                                            previewContainer.imageOffset = Qt.point(newX, newY)
                                            dragStart = Qt.point(mouse.x, mouse.y)
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: dialog.currentImage
                                    font.pixelSize: 72
                                    visible: dialog.currentImage !== "" && dialog.currentImage.length <= 4
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: dialog.cardType === "profile" ? "👤" : "🎭"
                                    font.pixelSize: 72
                                    visible: dialog.currentImage === ""
                                }
                            }
                            
                            // Contrôles
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Button {
                                    Layout.fillWidth: true
                                    text: "📁 Choisir une image"
                                    enabled: dialog.mode !== "view"
                                    
                                    background: Rectangle {
                                        color: parent.enabled ? (parent.hovered ? "#1e7da0" : "#2596be") : "#3B3B3B"
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: fileDialog.open()
                                }
                                
                                Button {
                                    Layout.fillWidth: true
                                    text: "😀 Choisir un emoji"
                                    enabled: dialog.mode !== "view"
                                    
                                    background: Rectangle {
                                        color: parent.enabled ? (parent.hovered ? "#d68910" : "#f39c12") : "#3B3B3B"
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: emojiPopup.open()
                                }
                                
                                Text {
                                    text: "🔍 Zoom"
                                    font.pixelSize: 11
                                    color: "#888888"
                                    visible: dialog.currentImage.startsWith("file")
                                }
                                
                                Slider {
                                    id: zoomSlider
                                    Layout.fillWidth: true
                                    from: 0.5
                                    to: 2.0
                                    value: 1.0
                                    enabled: dialog.mode !== "view" && dialog.currentImage.startsWith("file")
                                    visible: dialog.currentImage.startsWith("file")
                                    
                                    onValueChanged: {
                                        previewContainer.zoomLevel = value
                                    }
                                    
                                    background: Rectangle {
                                        x: zoomSlider.leftPadding
                                        y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                                        width: zoomSlider.availableWidth
                                        height: 4
                                        radius: 2
                                        color: "#3B3B3B"
                                        
                                        Rectangle {
                                            width: zoomSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: "#2596be"
                                            radius: 2
                                        }
                                    }
                                    
                                    handle: Rectangle {
                                        x: zoomSlider.leftPadding + zoomSlider.visualPosition * (zoomSlider.availableWidth - width)
                                        y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: zoomSlider.pressed ? "#1e7da0" : "#2596be"
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Champs de formulaire
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    // Nom (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Nom *"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: nameField
                            width: parent.width
                            text: profileData.name || ""
                            placeholderText: "Nom"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Prénom (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Prénom"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: firstNameField
                            width: parent.width
                            text: profileData.firstName || ""
                            placeholderText: "Prénom"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Email (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Email"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: emailField
                            width: parent.width
                            text: profileData.email || ""
                            placeholderText: "email@exemple.com"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Téléphone (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Téléphone"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: phoneField
                            width: parent.width
                            text: profileData.phone || ""
                            placeholderText: "+33 6 12 34 56 78"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Adresse (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Adresse postale"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: addressField
                            width: parent.width
                            text: profileData.address || ""
                            placeholderText: "Adresse complète"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Titre (seulement pour tons)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "lawyer"
                        
                        Text {
                            text: "Titre"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        TextField {
                            id: titleField
                            width: parent.width
                            text: profileData.title || ""
                            placeholderText: "Titre du ton"
                            enabled: dialog.mode !== "view"
                            
                            background: Rectangle {
                                color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                    
                    // Description (seulement pour tons, remplace Notes)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "lawyer"
                        
                        Text {
                            text: "Description"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        ScrollView {
                            width: parent.width
                            height: 150
                            clip: true
                            
                            TextArea {
                                id: descriptionField
                                text: profileData.description || ""
                                placeholderText: "Description libre du ton..."
                                wrapMode: Text.WordWrap
                                enabled: dialog.mode !== "view"
                                
                                background: Rectangle {
                                    color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                    radius: 8
                                    border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                    border.width: 1
                                }
                                
                                color: "#FFFFFF"
                                font.pixelSize: 13
                            }
                        }
                    }
                    
                    // Notes libres (seulement pour rédacteurs)
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        visible: dialog.cardType === "profile"
                        
                        Text {
                            text: "Notes"
                            font.pixelSize: 11
                            color: "#888888"
                        }
                        
                        ScrollView {
                            width: parent.width
                            height: 120
                            clip: true
                            
                            TextArea {
                                id: notesField
                                text: profileData.notes || ""
                                placeholderText: "Notes libres..."
                                wrapMode: Text.WordWrap
                                enabled: dialog.mode !== "view"
                                
                                background: Rectangle {
                                    color: parent.enabled ? "#2B2B2B" : "#1E1E1E"
                                    radius: 8
                                    border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                    border.width: 1
                                }
                                
                                color: "#FFFFFF"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
        
        // Footer avec boutons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: dialog.mode === "view" ? "Fermer" : "Annuler"
                
                background: Rectangle {
                    color: parent.hovered ? "#3B3B3B" : "transparent"
                    radius: 8
                    border.color: "#3B3B3B"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: dialog.close()
            }
            
            Button {
                text: "💾 Enregistrer"
                visible: dialog.mode !== "view"
                
                background: Rectangle {
                    color: parent.hovered ? "#1e7da0" : "#2596be"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // Validation différente selon le type
                    if (dialog.cardType === "profile" && nameField.text.trim() === "") {
                        return
                    }
                    if (dialog.cardType === "lawyer" && titleField.text.trim() === "") {
                        return
                    }
                    
                    var data = {
                        id: profileData.id || "",
                        image: profileData.image || "",
                        active: profileData.active !== undefined ? profileData.active : false
                    }
                    
                    // Champs spécifiques rédacteurs
                    if (dialog.cardType === "profile") {
                        data.name = nameField.text.trim()
                        data.firstName = firstNameField.text.trim()
                        data.email = emailField.text.trim()
                        data.phone = phoneField.text.trim()
                        data.address = addressField.text.trim()
                        data.notes = notesField.text.trim()
                    }
                    
                    // Champs spécifiques tons
                    if (dialog.cardType === "lawyer") {
                        data.name = titleField.text.trim()
                        data.title = titleField.text.trim()
                        data.description = descriptionField.text.trim()
                    }
                    
                    dialog.saved(data)
                    dialog.close()
                }
            }
        }
    }
    
    // File Dialog
    FileDialog {
        id: fileDialog
        title: "Choisir une image"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.gif)"]
        onAccepted: {
            dialog.currentImage = fileDialog.selectedFile.toString()
            profileData.image = dialog.currentImage
            previewContainer.imageOffset = Qt.point(0, 0)
            previewContainer.zoomLevel = 1.0
            zoomSlider.value = 1.0
        }
    }
    
    // Emoji Picker Popup
    Popup {
        id: emojiPopup
        anchors.centerIn: Overlay.overlay
        modal: true
        
        background: Rectangle {
            color: "transparent"
        }
        
        EmojiPicker {
            onEmojiSelected: function(emoji) {
                dialog.currentImage = emoji
                profileData.image = emoji
                emojiPopup.close()
            }
        }
    }
}
