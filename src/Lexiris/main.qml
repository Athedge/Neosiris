import QtQuick 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 1400
    height: 900
    title: "NEOSIRIS"
    color: "#0A0A0A"
    
    property bool vaultOpen: false
    property string currentUser: ""
    property bool isEngineerMode: false
    
    property var appInstance: app
    
    // Gestion des onglets
    property var openTabs: []
    property int activeTabIndex: -1
    
    // Navigation
    property string currentAddress: ""
    property var favoritePages: [
        {name: "Menu Principal", icon: "🏠", type: "menu", isFolder: false},
        {name: "Avocats", icon: "⚖️", type: "avocat", isFolder: false},
        {name: "Travail", icon: "📁", type: "folder", isFolder: true, children: [
            {name: "Syndic", icon: "🏢", type: "syndic"},
            {name: "Architecte", icon: "🏛️", type: "architecte"}
        ]}
    ]
    
    signal tabsChanged()
    signal saveFavoritesRequested()
    
    onSaveFavoritesRequested: {
        saveFavoritesToVault()
    }
    
    // POPUP PROFIL ÉDITABLE
    Popup {
        id: userProfilePopup
        anchors.centerIn: parent
        width: 700
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        property string profileImagePath: ""
        property bool editMode: false
        
        background: Rectangle {
            color: "#1A1A1A"
            radius: 12
            border.color: "#333"
            border.width: 1
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Row {
                width: parent.width
                
                Text {
                    text: "Profil Utilisateur"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#FFFFFF"
                    width: parent.width - 120
                }
                
                Button {
                    text: userProfilePopup.editMode ? "Annuler" : "Éditer"
                    width: 100
                    height: 35
                    background: Rectangle {
                        color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                        border.color: "#555"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        userProfilePopup.editMode = !userProfilePopup.editMode
                        if (!userProfilePopup.editMode) {
                            displayNameField.text = window.currentUser
                        }
                    }
                }
            }
            
            Rectangle { width: parent.width; height: 1; color: "#333" }
            
            Row {
                spacing: 30
                width: parent.width
                
                Column {
                    spacing: 15
                    
                    Rectangle {
                        id: avatarContainer
                        width: 150
                        height: 150
                        radius: 75
                        color: "#2A2A2A"
                        border.color: "#555"
                        border.width: 3
                        
                        Canvas {
                            id: avatarCanvas
                            anchors.fill: parent
                            anchors.margins: 3
                            visible: userProfilePopup.profileImagePath !== ""
                            
                            property var loadedImage: null
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.save()
                                ctx.clearRect(0, 0, width, height)
                                
                                // Clip circulaire
                                ctx.beginPath()
                                ctx.arc(width/2, height/2, width/2, 0, Math.PI * 2)
                                ctx.clip()
                                
                                if (loadedImage && loadedImage.status === Image.Ready) {
                                    ctx.drawImage(loadedImage, 0, 0, width, height)
                                }
                                
                                ctx.restore()
                            }
                            
                            Image {
                                id: profileImage
                                source: userProfilePopup.profileImagePath
                                visible: false
                                onStatusChanged: {
                                    if (status === Image.Ready) {
                                        avatarCanvas.loadedImage = profileImage
                                        avatarCanvas.requestPaint()
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: window.currentUser.substring(0, 1).toUpperCase()
                            font.pixelSize: 60
                            font.bold: true
                            color: "#FFFFFF"
                            anchors.centerIn: parent
                            visible: userProfilePopup.profileImagePath === ""
                        }
                    }
                    
                    Button {
                        text: "Changer photo"
                        width: 150
                        height: 35
                        visible: userProfilePopup.editMode
                        background: Rectangle {
                            color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: imageCropPopup.open()
                    }
                }
                
                Column {
                    spacing: 20
                    width: parent.width - 200
                    
                    Column {
                        spacing: 8
                        width: parent.width
                        
                        Text {
                            text: "Nom d'utilisateur"
                            font.pixelSize: 12
                            color: "#999999"
                        }
                        
                        TextField {
                            width: parent.width
                            height: 40
                            text: window.currentUser
                            color: "#888888"
                            font.pixelSize: 14
                            readOnly: true
                            background: Rectangle {
                                color: "#0F0F0F"
                                border.color: "#333"
                                radius: 6
                            }
                        }
                    }
                    
                    Column {
                        spacing: 8
                        width: parent.width
                        
                        Text {
                            text: "Nom d'affichage"
                            font.pixelSize: 12
                            color: "#999999"
                        }
                        
                        TextField {
                            id: displayNameField
                            width: parent.width
                            height: 40
                            text: window.currentUser
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            readOnly: !userProfilePopup.editMode
                            background: Rectangle {
                                color: userProfilePopup.editMode ? "#1A1A1A" : "#0F0F0F"
                                border.color: userProfilePopup.editMode ? (displayNameField.activeFocus ? "#FFFFFF" : "#555") : "#333"
                                border.width: userProfilePopup.editMode ? 2 : 1
                                radius: 6
                            }
                        }
                    }
                    
                    Column {
                        spacing: 8
                        width: parent.width
                        
                        Text {
                            text: "Email"
                            font.pixelSize: 12
                            color: "#999999"
                        }
                        
                        TextField {
                            id: emailField
                            width: parent.width
                            height: 40
                            placeholderText: "email@exemple.com"
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            readOnly: !userProfilePopup.editMode
                            background: Rectangle {
                                color: userProfilePopup.editMode ? "#1A1A1A" : "#0F0F0F"
                                border.color: userProfilePopup.editMode ? (emailField.activeFocus ? "#FFFFFF" : "#555") : "#333"
                                border.width: userProfilePopup.editMode ? 2 : 1
                                radius: 6
                            }
                        }
                    }
                    
                    Row {
                        spacing: 10
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: window.isEngineerMode ? "#4CAF50" : "#999999"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: window.isEngineerMode ? "Mode Ingénieur" : "Utilisateur Standard"
                            font.pixelSize: 13
                            color: window.isEngineerMode ? "#4CAF50" : "#999999"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
            
            Item { height: 20 }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "Fermer"
                    width: 120
                    height: 40
                    visible: !userProfilePopup.editMode
                    background: Rectangle {
                        color: parent.hovered ? "#CCCCCC" : "#FFFFFF"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#000000"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: userProfilePopup.close()
                }
                
                Button {
                    text: "Enregistrer"
                    width: 120
                    height: 40
                    visible: userProfilePopup.editMode
                    background: Rectangle {
                        color: parent.hovered ? "#00CC00" : "#00AA00"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("Sauvegarde profil:", displayNameField.text, emailField.text)
                        
                        // Sauvegarder la photo de profil
                        if (userProfilePopup.profileImagePath) {
                            app.saveProfileImage(window.currentUser, userProfilePopup.profileImagePath)
                        }
                        
                        userProfilePopup.editMode = false
                        userProfilePopup.close()
                    }
                }
            }
        }
    }
    
    
    // POPUP CROP IMAGE
    Popup {
        id: imageCropPopup
        anchors.centerIn: parent
        width: 600
        height: 700
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        property string selectedImagePath: ""
        property real imageScale: 1.0
        property real imageX: 0
        property real imageY: 0
        
        background: Rectangle {
            color: "#1A1A1A"
            radius: 12
            border.color: "#333"
            border.width: 1
        }
        
        onOpened: {
            imageCropPopup.imageScale = 1.0
            imageCropPopup.imageX = 0
            imageCropPopup.imageY = 0
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                text: "Recadrer la photo de profil"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
            }
            
            // Zone de crop RONDE
            Rectangle {
                width: 400
                height: 400
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#0A0A0A"
                border.color: "#555"
                border.width: 2
                radius: 8
                
                // Cercle de découpe
                Item {
                    id: cropArea
                    anchors.centerIn: parent
                    width: 300
                    height: 300
                    clip: true
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 150
                        color: "transparent"
                        
                        Image {
                            id: cropImage
                            source: imageCropPopup.selectedImagePath
                            width: 300
                            height: 300
                            fillMode: Image.PreserveAspectFit
                            
                            x: imageCropPopup.imageX
                            y: imageCropPopup.imageY
                            scale: imageCropPopup.imageScale
                            transformOrigin: Item.Center
                            
                            MouseArea {
                                anchors.fill: parent
                                property point lastPos
                                
                                onPressed: function(mouse) {
                                    lastPos = Qt.point(mouse.x, mouse.y)
                                }
                                
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        var dx = (mouse.x - lastPos.x)
                                        var dy = (mouse.y - lastPos.y)
                                        imageCropPopup.imageX += dx
                                        imageCropPopup.imageY += dy
                                        lastPos = Qt.point(mouse.x, mouse.y)
                                    }
                                }
                                
                                onWheel: function(wheel) {
                                    var delta = wheel.angleDelta.y / 120
                                    var newScale = imageCropPopup.imageScale + delta * 0.1
                                    if (newScale >= 0.5 && newScale <= 3.0) {
                                        imageCropPopup.imageScale = newScale
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Overlay sombre avec trou rond
                Canvas {
                    anchors.fill: parent
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        
                        ctx.fillStyle = "rgba(0, 0, 0, 0.7)"
                        ctx.fillRect(0, 0, width, height)
                        
                        ctx.globalCompositeOperation = "destination-out"
                        ctx.beginPath()
                        ctx.arc(width/2, height/2, 150, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
                
                // Bordure du cercle
                Rectangle {
                    width: 300
                    height: 300
                    radius: 150
                    anchors.centerIn: parent
                    color: "transparent"
                    border.color: "#FFFFFF"
                    border.width: 3
                }
            }
            
            // Contrôles zoom
            Column {
                spacing: 10
                width: parent.width
                
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Text {
                        text: "Zoom:"
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Slider {
                        id: zoomSlider
                        from: 0.5
                        to: 3.0
                        value: imageCropPopup.imageScale
                        width: 200
                        onValueChanged: imageCropPopup.imageScale = value
                        
                        background: Rectangle {
                            x: zoomSlider.leftPadding
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            width: zoomSlider.availableWidth
                            height: 4
                            radius: 2
                            color: "#333"
                            
                            Rectangle {
                                width: zoomSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#8AB4F8"
                                radius: 2
                            }
                        }
                        
                        handle: Rectangle {
                            x: zoomSlider.leftPadding + zoomSlider.visualPosition * (zoomSlider.availableWidth - width)
                            y: zoomSlider.topPadding + zoomSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: zoomSlider.pressed ? "#CCCCCC" : "#FFFFFF"
                        }
                    }
                    
                    Text {
                        text: Math.round(imageCropPopup.imageScale * 100) + "%"
                        color: "#999999"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            
            // Boutons
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "Choisir fichier"
                    width: 130
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                        border.color: "#555"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var path = app.selectImageFile()
                        if (path) {
                            imageCropPopup.selectedImagePath = "file:///" + path
                            imageCropPopup.imageScale = 1.0
                            imageCropPopup.imageX = 0
                            imageCropPopup.imageY = 0
                        }
                    }
                }
                
                Button {
                    text: "Annuler"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: imageCropPopup.close()
                }
                
                Button {
                    text: "Valider"
                    width: 100
                    height: 40
                    enabled: imageCropPopup.selectedImagePath !== ""
                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? "#00CC00" : "#00AA00") : "#333333"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#FFFFFF" : "#666666"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        userProfilePopup.profileImagePath = imageCropPopup.selectedImagePath
                        
                        // Sauvegarder immédiatement dans le vault
                        if (imageCropPopup.selectedImagePath && window.currentUser) {
                            app.saveProfileImage(window.currentUser, imageCropPopup.selectedImagePath)
                        }
                        
                        imageCropPopup.close()
                    }
                }
            }
        }
    }
    // POPUP GESTION FAVORIS
    Popup {
        id: manageFavoritesPopup
        anchors.centerIn: parent
        width: 600
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        background: Rectangle {
            color: "#1A1A1A"
            radius: 12
            border.color: "#333"
            border.width: 1
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                text: "Gérer les favoris"
                font.pixelSize: 24
                font.bold: true
                color: "#FFFFFF"
            }
            
            Rectangle {
                width: parent.width
                height: parent.height - 100
                color: "#0F0F0F"
                radius: 8
                
                ListView {
                    id: favoritesListView
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    clip: true
                    
                    model: window.favoritePages.length
                    
                    delegate: Rectangle {
                        width: favoritesListView.width
                        height: 50
                        color: favItemMouse.containsMouse ? "#2A2A2A" : "transparent"
                        radius: 6
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                text: window.favoritePages[index].icon
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                text: window.favoritePages[index].name
                                color: "#FFFFFF"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 100
                            }
                            
                            Text {
                                text: "✕"
                                color: "#FF6B6B"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var newFavs = window.favoritePages.slice()
                                        newFavs.splice(index, 1)
                                        window.favoritePages = newFavs
                                    }
                                }
                            }
                        }
                        
                        MouseArea {
                            id: favItemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1
                        }
                    }
                }
            }
            
            Button {
                text: "Fermer"
                width: 120
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle {
                    color: parent.hovered ? "#CCCCCC" : "#FFFFFF"
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "#000000"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: manageFavoritesPopup.close()
            }
        }
    }
    
    // POPUP RENOMMER FAVORI
    Popup {
        id: renameFavoritePopup
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        property int editingIndex: -1
        
        background: Rectangle {
            color: "#1A1A1A"
            radius: 12
            border.color: "#333"
            border.width: 1
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                text: "Renommer le favori"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
            }
            
            TextField {
                id: renameField
                width: parent.width
                height: 40
                color: "#FFFFFF"
                font.pixelSize: 14
                background: Rectangle {
                    color: "#0F0F0F"
                    border.color: renameField.activeFocus ? "#8AB4F8" : "#333"
                    border.width: 2
                    radius: 6
                }
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "Annuler"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: renameFavoritePopup.close()
                }
                
                Button {
                    text: "Valider"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#00CC00" : "#00AA00"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (renameFavoritePopup.editingIndex >= 0 && renameField.text.length > 0) {
                            var newFavs = window.favoritePages.slice()
                            newFavs[renameFavoritePopup.editingIndex].name = renameField.text
                            window.favoritePages = newFavs
                            window.saveFavoritesToVault()
                            renameFavoritePopup.close()
                        }
                    }
                }
            }
        }
    }
    
    // POPUP CRÉER DOSSIER
    Popup {
        id: createFolderPopup
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        background: Rectangle {
            color: "#1A1A1A"
            radius: 12
            border.color: "#333"
            border.width: 1
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                text: "Créer un dossier"
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"
            }
            
            Column {
                spacing: 8
                width: parent.width
                
                Text {
                    text: "Nom du dossier"
                    font.pixelSize: 12
                    color: "#999999"
                }
                
                TextField {
                    id: folderNameField
                    width: parent.width
                    height: 40
                    placeholderText: "Nouveau dossier"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0F0F0F"
                        border.color: folderNameField.activeFocus ? "#8AB4F8" : "#333"
                        border.width: 2
                        radius: 6
                    }
                }
            }
            
            Column {
                spacing: 8
                width: parent.width
                
                Text {
                    text: "Icône"
                    font.pixelSize: 12
                    color: "#999999"
                }
                
                TextField {
                    id: folderIconField
                    width: parent.width
                    height: 40
                    text: "📁"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0F0F0F"
                        border.color: folderIconField.activeFocus ? "#8AB4F8" : "#333"
                        border.width: 2
                        radius: 6
                    }
                }
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "Annuler"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#3A3A3A" : "#2A2A2A"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: createFolderPopup.close()
                }
                
                Button {
                    text: "Créer"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: parent.hovered ? "#00CC00" : "#00AA00"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (folderNameField.text.length > 0) {
                            var newFavs = window.favoritePages.slice()
                            newFavs.push({
                                name: folderNameField.text,
                                icon: folderIconField.text,
                                type: "folder",
                                isFolder: true,
                                children: []
                            })
                            window.favoritePages = newFavs
                            window.saveFavoritesToVault()
                            folderNameField.text = ""
                            folderIconField.text = "📁"
                            createFolderPopup.close()
                        }
                    }
                }
            }
        }
    }
    
    // LOGIN PAGE
    Component {
        id: loginPage
        Rectangle {
            color: "#0A0A0A"
            
            Column {
                anchors.centerIn: parent
                spacing: 25
                width: 400
                
                Image {
                    source: "../../assets/Neosiris.ico"
                    width: 120
                    height: 120
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "NEOSIRIS"
                    font.pixelSize: 42
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                TextField {
                    id: usernameField
                    width: parent.width
                    height: 50
                    placeholderText: "Nom d'utilisateur"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#1A1A1A"
                        border.color: usernameField.activeFocus ? "#FFFFFF" : "#333"
                        border.width: 2
                        radius: 8
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "#1A1A1A"
                    border.color: passwordField.activeFocus ? "#FFFFFF" : "#333"
                    border.width: 2
                    radius: 8
                    
                    Row {
                        anchors.fill: parent
                        
                        TextField {
                            id: passwordField
                            width: parent.width - 50
                            height: parent.height
                            placeholderText: "Mot de passe"
                            echoMode: showPasswordIcon.visible && showPasswordIcon.showPassword ? TextInput.Normal : TextInput.Password
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            leftPadding: 15
                            background: Rectangle { color: "transparent" }
                            onAccepted: loginButton.clicked()
                        }
                        
                        Item {
                            id: showPasswordIcon
                            width: 40
                            height: parent.height
                            visible: passwordField.text.length > 0
                            property bool showPassword: false
                            
                            Rectangle {
                                width: 24
                                height: 24
                                color: "transparent"
                                anchors.centerIn: parent
                                
                                Rectangle {
                                    width: 20
                                    height: 12
                                    color: "transparent"
                                    border.color: showPasswordIcon.showPassword ? "#FFFFFF" : "#666666"
                                    border.width: 1.5
                                    radius: 10
                                    anchors.centerIn: parent
                                    
                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: showPasswordIcon.showPassword ? "#FFFFFF" : "#666666"
                                        anchors.centerIn: parent
                                    }
                                }
                                
                                Rectangle {
                                    width: 26
                                    height: 1.5
                                    color: "#666666"
                                    rotation: 45
                                    anchors.centerIn: parent
                                    visible: !showPasswordIcon.showPassword
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed: showPasswordIcon.showPassword = true
                                onReleased: showPasswordIcon.showPassword = false
                                onCanceled: showPasswordIcon.showPassword = false
                            }
                        }
                    }
                }
                
                Button {
                    id: loginButton
                    text: "Connexion"
                    width: parent.width
                    height: 55
                    background: Rectangle {
                        color: loginButton.hovered ? "#CCCCCC" : "#FFFFFF"
                        radius: 8
                    }
                    contentItem: Text {
                        text: loginButton.text
                        font.pixelSize: 16
                        font.bold: true
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if(app.openVault(usernameField.text, passwordField.text)) {
                            window.vaultOpen = true
                            window.currentUser = usernameField.text
                            if(usernameField.text === "Alex" && passwordField.text === "..8000") {
                                window.isEngineerMode = true
                            }
                            
                            // Charger la photo de profil
                            var savedImage = app.loadProfileImage(window.currentUser)
                            if (savedImage) {
                                userProfilePopup.profileImagePath = savedImage
                            }
                            
                            // Charger les favoris
                            loadFavoritesFromVault()
                            
                            openMenuTab()
                        }
                    }
                }
            }
        }
    }
    
    // MENU PRINCIPAL
    Component {
        id: menuPrincipal
        Rectangle {
            color: "#0A0A0A"
            implicitHeight: 1200
            
            Column {
                anchors.centerIn: parent
                spacing: 50
                
                Image {
                    source: "../../assets/Neosiris.ico"
                    width: 100
                    height: 100
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Sélectionnez votre interface"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Grid {
                    columns: 4
                    rows: 3
                    spacing: 25
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Repeater {
                        model: [
                            {icon: "📊", text: "Tableau de Bord", interface: "dashboard"},
                            {icon: "⚖️", text: "Avocats", interface: "avocat"},
                            {icon: "🏢", text: "Syndic", interface: "syndic"},
                            {icon: "🔧", text: "Expert Technique", interface: "expert_tech"},
                            {icon: "🏥", text: "Expert Santé", interface: "expert_sante"},
                            {icon: "💼", text: "Chargé d'affaires", interface: "charge_affaires"},
                            {icon: "🏛️", text: "Architecte", interface: "architecte"},
                            {icon: "☁️", text: "Stockage Cloud", interface: "stockage_cloud"},
                            {icon: "📧", text: "Mails", interface: "mails"},
                            {icon: "📅", text: "Calendrier", interface: "calendrier"},
                            {icon: "⚙️", text: "Paramètres", interface: "parametres"}
                        ]
                        
                        Rectangle {
                            width: 200
                            height: 200
                            color: interfaceMouse.containsMouse ? "#1A1A1A" : "#0F0F0F"
                            border.color: "#FFFFFF"
                            border.width: 2
                            radius: 12
                            
                            MouseArea {
                                id: interfaceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: navigateToInterface(modelData.interface, modelData.text)
                            }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 15
                                
                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 60
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Text {
                                    text: modelData.text
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // INTERFACE PRINCIPALE
    StackView {
        id: mainStack
        anchors.fill: parent
        initialItem: window.vaultOpen ? mainWorkspace : loginPage
    }
    
    Component {
        id: mainWorkspace
        Rectangle {
            color: "#0A0A0A"
            
            Column {
                anchors.fill: parent
                spacing: 0
                
                // ONGLETS STYLE CHROME
                Rectangle {
                    width: parent.width
                    height: 36
                    color: "#202124"
                    
                    Row {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Logo
                        Rectangle {
                            width: 50
                            height: parent.height
                            color: logoMouse.containsMouse ? "#3C4043" : "transparent"
                            
                            Image {
                                source: "../../assets/Neosiris.ico"
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                id: logoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: navigateToMenu()
                            }
                        }
                        
                        // Onglets
                        Repeater {
                            id: tabsRepeater
                            model: window.openTabs.length
                            
                            Item {
                                width: Math.min(240, Math.max(140, (parent.width - 150) / Math.max(window.openTabs.length, 1)))
                                height: parent.height
                                
                                // Onglet trapézoïdal Chrome
                                Canvas {
                                    id: tabShape
                                    anchors.fill: parent
                                    
                                    property bool isActive: window.activeTabIndex === index
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.reset()
                                        
                                        var w = width
                                        var h = height
                                        var curve = 8
                                        
                                        ctx.fillStyle = isActive ? "#313235" : "#202124"
                                        
                                        ctx.beginPath()
                                        ctx.moveTo(curve, h)
                                        ctx.lineTo(curve/2, curve)
                                        ctx.quadraticCurveTo(curve, 0, curve*2, 0)
                                        ctx.lineTo(w - curve*2, 0)
                                        ctx.quadraticCurveTo(w - curve, 0, w - curve/2, curve)
                                        ctx.lineTo(w - curve, h)
                                        ctx.fill()
                                    }
                                    
                                    Connections {
                                        target: window
                                        function onActiveTabIndexChanged() {
                                            tabShape.requestPaint()
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.rightMargin: 30
                                    onClicked: {
                                        window.activeTabIndex = index
                                        updateCurrentAddress()
                                        window.tabsChanged()
                                    }
                                }
                                
                                Row {
                                    anchors.centerIn: parent
                                    anchors.horizontalCenterOffset: -10
                                    spacing: 8
                                    
                                    Text {
                                        text: window.openTabs[index] ? (window.openTabs[index].icon || "📄") : ""
                                        font.pixelSize: 14
                                    }
                                    
                                    Text {
                                        text: window.openTabs[index] ? window.openTabs[index].name : ""
                                        color: window.activeTabIndex === index ? "#E8EAED" : "#9AA0A6"
                                        font.pixelSize: 13
                                        width: parent.parent.width - 80
                                        elide: Text.ElideRight
                                    }
                                }
                                
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: closeMouse.containsMouse ? "#5F6368" : "transparent"
                                    
                                    Text {
                                        text: "✕"
                                        color: "#9AA0A6"
                                        font.pixelSize: 11
                                        anchors.centerIn: parent
                                    }
                                    
                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: closeTab(index)
                                    }
                                }
                            }
                        }
                        
                        // Bouton +
                        Rectangle {
                            width: 36
                            height: 28
                            radius: 14
                            color: newTabMouse.containsMouse ? "#3C4043" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "+"
                                font.pixelSize: 18
                                color: "#9AA0A6"
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                id: newTabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openMenuTab()
                            }
                        }
                        
                        Item { width: 10; height: 1 }
                    }
                }
                
                // BARRE ADRESSE
                Rectangle {
                    width: parent.width
                    height: 46
                    color: "#313235"
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: backMouse.containsMouse ? "#5F6368" : "transparent"
                                Text { text: "◀"; color: "#9AA0A6"; font.pixelSize: 14; anchors.centerIn: parent }
                                MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                            
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: fwdMouse.containsMouse ? "#5F6368" : "transparent"
                                Text { text: "▶"; color: "#9AA0A6"; font.pixelSize: 14; anchors.centerIn: parent }
                                MouseArea { id: fwdMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                            
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: refMouse.containsMouse ? "#5F6368" : "transparent"
                                Text { text: "⟳"; color: "#9AA0A6"; font.pixelSize: 16; anchors.centerIn: parent }
                                MouseArea { id: refMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width - 220
                            height: 32
                            radius: 16
                            color: "#202124"
                            border.color: addressField.activeFocus ? "#8AB4F8" : "transparent"
                            border.width: 2
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                
                                Text {
                                    text: "🔒"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                TextField {
                                    id: addressField
                                    width: parent.width - 30
                                    height: parent.height
                                    text: window.currentAddress
                                    placeholderText: "Rechercher..."
                                    color: "#E8EAED"
                                    font.pixelSize: 13
                                    verticalAlignment: TextInput.AlignVCenter
                                    background: Rectangle { color: "transparent" }
                                    onAccepted: navigateToAddress(text)
                                }
                            }
                        }
                        
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: starMouse.containsMouse ? "#5F6368" : "transparent"
                                
                                Text { 
                                    text: isCurrentPageInFavorites() ? "⭐" : "☆"
                                    color: isCurrentPageInFavorites() ? "#FFA500" : "#9AA0A6"
                                    font.pixelSize: 14
                                    anchors.centerIn: parent
                                }
                                
                                MouseArea { 
                                    id: starMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: toggleCurrentPageFavorite()
                                }
                            }
                            
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: menuMouse.containsMouse ? "#5F6368" : "transparent"
                                
                                Text { text: "⋮"; color: "#9AA0A6"; font.pixelSize: 20; anchors.centerIn: parent }
                                
                                MouseArea { 
                                    id: menuMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: favoritesManageMenu.popup()
                                }
                                
                                Menu {
                                    id: favoritesManageMenu
                                    x: parent.width - width
                                    y: parent.height + 5
                                    
                                    background: Rectangle {
                                        implicitWidth: 200
                                        color: "#292A2D"
                                        border.color: "#3C4043"
                                        radius: 8
                                    }
                                    
                                    MenuItem {
                                        text: "📁 Nouveau dossier"
                                        height: 40
                                        background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                        contentItem: Text { 
                                            text: parent.text
                                            color: "#E8EAED"
                                            font.pixelSize: 13
                                            leftPadding: 10
                                        }
                                        onClicked: createFolderPopup.open()
                                    }
                                    
                                    MenuItem {
                                        text: "📋 Gérer les favoris"
                                        height: 40
                                        background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                        contentItem: Text { 
                                            text: parent.text
                                            color: "#E8EAED"
                                            font.pixelSize: 13
                                            leftPadding: 10
                                        }
                                        onClicked: manageFavoritesPopup.open()
                                    }
                                }
                            }
                            
                            // PROFIL avec photo
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: userMenuArea.containsMouse ? "#3C4043" : "#2D2E30"
                                border.color: "#555"
                                border.width: 1
                                
                                Canvas {
                                    id: profileCanvas
                                    anchors.fill: parent
                                    visible: userProfilePopup.profileImagePath !== ""
                                    
                                    property var loadedImage: null
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.save()
                                        ctx.clearRect(0, 0, width, height)
                                        
                                        // Clip circulaire
                                        ctx.beginPath()
                                        ctx.arc(width/2, height/2, width/2, 0, Math.PI * 2)
                                        ctx.clip()
                                        
                                        if (loadedImage && loadedImage.status === Image.Ready) {
                                            ctx.drawImage(loadedImage, 0, 0, width, height)
                                        }
                                        
                                        ctx.restore()
                                    }
                                    
                                    Image {
                                        id: profileImageSmall
                                        source: userProfilePopup.profileImagePath
                                        visible: false
                                        onStatusChanged: {
                                            if (status === Image.Ready) {
                                                profileCanvas.loadedImage = profileImageSmall
                                                profileCanvas.requestPaint()
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: window.currentUser.substring(0, 1).toUpperCase()
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#E8EAED"
                                    anchors.centerIn: parent
                                    visible: userProfilePopup.profileImagePath === ""
                                }
                                
                                MouseArea {
                                    id: userMenuArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: userMenu.open()
                                }
                                
                                Menu {
                                    id: userMenu
                                    x: parent.width - width
                                    y: parent.height + 5
                                    
                                    background: Rectangle {
                                        implicitWidth: 200
                                        color: "#292A2D"
                                        border.color: "#3C4043"
                                        radius: 8
                                    }
                                    
                                    MenuItem {
                                        text: "👤 Voir profil"
                                        height: 40
                                        width: parent.width
                                        background: Rectangle {
                                            color: parent.hovered ? "#3C4043" : "transparent"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#E8EAED"
                                            font.pixelSize: 13
                                            leftPadding: 10
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: userProfilePopup.open()
                                    }
                                    
                                    MenuItem {
                                        text: "🔄 Changer utilisateur"
                                        height: 40
                                        width: parent.width
                                        background: Rectangle {
                                            color: parent.hovered ? "#3C4043" : "transparent"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#E8EAED"
                                            font.pixelSize: 13
                                            leftPadding: 10
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            window.vaultOpen = false
                                            window.currentUser = ""
                                            window.isEngineerMode = false
                                            window.openTabs = []
                                            window.activeTabIndex = -1
                                            mainStack.replace(loginPage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // BARRE FAVORIS
                Rectangle {
                    width: parent.width
                    height: 36
                    color: "#313235"
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 70
                        spacing: 4
                        
                        Repeater {
                            model: window.favoritePages
                            
                            Rectangle {
                                id: favItem
                                height: 28
                                width: favContent.width + 16
                                radius: 6
                                color: {
                                    if (dropArea.containsDrag && modelData.isFolder) {
                                        return "#FFA500"  // Orange si survol dossier pendant drag
                                    }
                                    return favMouse.containsMouse ? "#5F6368" : "transparent"
                                }
                                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                
                                property int visualIndex: index
                                property var appRef: appInstance
                                property var favsRef: favoritePages
                                
                                // Drag & Drop
                                Drag.active: favDragHandler.drag.active
                                Drag.source: favItem
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2
                                
                                states: State {
                                    when: favDragHandler.drag.active
                                    ParentChange { target: favItem; parent: window.contentItem }
                                    AnchorChanges { 
                                        target: favItem
                                        anchors.verticalCenter: undefined
                                    }
                                }
                                
                                // Zone de drop
                                DropArea {
                                    id: dropArea
                                    anchors.fill: parent
                                    
                                    onDropped: function(drop) {
                                        if (drop.source !== favItem) {
                                            var sourceIndex = drop.source.visualIndex
                                            var targetIndex = favItem.visualIndex
                                            
                                            if (sourceIndex !== targetIndex) {
                                                var newFavs = favItem.favsRef.slice()
                                                var draggedItem = newFavs[sourceIndex]
                                                
                                                // Si la cible est un dossier et l'élément n'est pas un dossier
                                                if (modelData.isFolder && !draggedItem.isFolder) {
                                                    // Ajouter dans le dossier
                                                    if (!newFavs[targetIndex].children) {
                                                        newFavs[targetIndex].children = []
                                                    }
                                                    newFavs[targetIndex].children.push(draggedItem)
                                                    newFavs.splice(sourceIndex, 1)
                                                } else if (!modelData.isFolder) {
                                                    // Réorganiser normalement (uniquement si cible n'est PAS un dossier)
                                                    var item = newFavs.splice(sourceIndex, 1)[0]
                                                    newFavs.splice(targetIndex, 0, item)
                                                }
                                                
                                                favoritePages = newFavs
                                                
                                                // Sauvegarder via Python
                                                favItem.appRef.saveFavorites(JSON.stringify(newFavs))
                                            }
                                            drop.accept()
                                        }
                                    }
                                }
                                
                                Row {
                                    id: favContent
                                    anchors.centerIn: parent
                                    spacing: 6
                                    
                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 12
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        color: "#E8EAED"
                                        font.pixelSize: 12
                                    }
                                    
                                    Text {
                                        text: modelData.isFolder ? "▼" : ""
                                        color: "#9AA0A6"
                                        font.pixelSize: 8
                                        visible: modelData.isFolder
                                    }
                                }
                                
                                // Drag handler
                                MouseArea {
                                    id: favDragHandler
                                    anchors.fill: parent
                                    drag.target: favItem
                                    drag.threshold: 10
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.ArrowCursor
                                    hoverEnabled: false
                                    z: -1
                                    
                                    onReleased: {
                                        favItem.Drag.drop()
                                        favItem.x = 0
                                        favItem.y = 0
                                    }
                                }
                                
                                // Click handler (superposé)
                                MouseArea {
                                    id: favMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    propagateComposedEvents: true
                                    
                                    onPressed: function(mouse) {
                                        // Propager pour permettre le drag
                                        mouse.accepted = false
                                    }
                                    
                                    onClicked: function(mouse) {
                                        console.log("Favori cliqué:", modelData.name, "isFolder:", modelData.isFolder)
                                        
                                        if (mouse.button === Qt.RightButton) {
                                            favContextMenu.selectedIndex = index
                                            favContextMenu.popup()
                                        } else if (!favDragHandler.drag.active) {
                                            if (modelData.isFolder) {
                                                console.log("Ouverture menu dossier, children:", modelData.children ? modelData.children.length : 0)
                                                folderMenu.popup()
                                            } else if (modelData.type === "menu") {
                                                navigateToMenu()
                                            } else {
                                                navigateToInterface(modelData.type, modelData.name)
                                            }
                                        }
                                    }
                                }
                                
                                Menu {
                                    id: folderMenu
                                    
                                    background: Rectangle {
                                        implicitWidth: 180
                                        color: "#292A2D"
                                        border.color: "#3C4043"
                                        radius: 6
                                    }
                                    
                                    Repeater {
                                        model: modelData.isFolder && modelData.children ? modelData.children : []
                                        
                                        delegate: MenuItem {
                                            required property var modelData
                                            
                                            text: modelData.icon + " " + modelData.name
                                            height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#3C4043" : "transparent"
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#E8EAED"
                                                font.pixelSize: 12
                                                leftPadding: 8
                                            }
                                            onClicked: navigateToInterface(modelData.type, modelData.name)
                                        }
                                    }
                                    
                                    // Message si vide
                                    MenuItem {
                                        text: "📂 Dossier vide"
                                        height: 32
                                        visible: !modelData.children || modelData.children.length === 0
                                        enabled: false
                                        background: Rectangle {
                                            color: "transparent"
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#666666"
                                            font.pixelSize: 12
                                            font.italic: true
                                            leftPadding: 8
                                        }
                                    }
                                }
                            }
                        }
                        
                        Menu {
                            id: favContextMenu
                            property int selectedIndex: -1
                            
                            background: Rectangle {
                                implicitWidth: 180
                                color: "#292A2D"
                                border.color: "#3C4043"
                                radius: 6
                            }
                            
                            MenuItem {
                                text: "✏️ Renommer"
                                height: 32
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text { 
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 12
                                    leftPadding: 8
                                }
                                onClicked: {
                                    if (favContextMenu.selectedIndex >= 0) {
                                        renameFavoritePopup.editingIndex = favContextMenu.selectedIndex
                                        renameField.text = window.favoritePages[favContextMenu.selectedIndex].name
                                        renameFavoritePopup.open()
                                    }
                                }
                            }
                            
                            MenuItem {
                                text: "📁 Nouveau sous-dossier"
                                height: 32
                                visible: favContextMenu.selectedIndex >= 0 && window.favoritePages[favContextMenu.selectedIndex] && window.favoritePages[favContextMenu.selectedIndex].isFolder
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text { 
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 12
                                    leftPadding: 8
                                }
                                onClicked: {
                                    if (favContextMenu.selectedIndex >= 0) {
                                        var newFavs = window.favoritePages.slice()
                                        var parentFolder = newFavs[favContextMenu.selectedIndex]
                                        
                                        if (parentFolder.isFolder) {
                                            if (!parentFolder.children) {
                                                parentFolder.children = []
                                            }
                                            
                                            var subFolderName = "Sous-dossier " + (parentFolder.children.length + 1)
                                            parentFolder.children.push({
                                                name: subFolderName,
                                                icon: "📁",
                                                type: "folder",
                                                isFolder: true,
                                                children: []
                                            })
                                            
                                            window.favoritePages = newFavs
                                            window.saveFavoritesToVault()
                                        }
                                    }
                                }
                            }
                            
                            MenuItem {
                                text: "⬅️ Déplacer à gauche"
                                height: 32
                                visible: favContextMenu.selectedIndex > 0
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text { 
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 12
                                    leftPadding: 8
                                }
                                onClicked: {
                                    if (favContextMenu.selectedIndex > 0) {
                                        var newFavs = window.favoritePages.slice()
                                        var item = newFavs[favContextMenu.selectedIndex]
                                        newFavs[favContextMenu.selectedIndex] = newFavs[favContextMenu.selectedIndex - 1]
                                        newFavs[favContextMenu.selectedIndex - 1] = item
                                        window.favoritePages = newFavs
                                        window.saveFavoritesToVault()
                                    }
                                }
                            }
                            
                            MenuItem {
                                text: "➡️ Déplacer à droite"
                                height: 32
                                visible: favContextMenu.selectedIndex >= 0 && favContextMenu.selectedIndex < window.favoritePages.length - 1
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text { 
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 12
                                    leftPadding: 8
                                }
                                onClicked: {
                                    if (favContextMenu.selectedIndex < window.favoritePages.length - 1) {
                                        var newFavs = window.favoritePages.slice()
                                        var item = newFavs[favContextMenu.selectedIndex]
                                        newFavs[favContextMenu.selectedIndex] = newFavs[favContextMenu.selectedIndex + 1]
                                        newFavs[favContextMenu.selectedIndex + 1] = item
                                        window.favoritePages = newFavs
                                        window.saveFavoritesToVault()
                                    }
                                }
                            }
                            
                            MenuItem {
                                text: "🗑️ Supprimer"
                                height: 32
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text { 
                                    text: parent.text
                                    color: "#FF6B6B"
                                    font.pixelSize: 12
                                    leftPadding: 8
                                }
                                onClicked: {
                                    if (favContextMenu.selectedIndex >= 0) {
                                        var newFavs = window.favoritePages.slice()
                                        newFavs.splice(favContextMenu.selectedIndex, 1)
                                        window.favoritePages = newFavs
                                        window.saveFavoritesToVault()
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    // Bouton Historique (positionné à droite)
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 50
                        height: 28
                        radius: 6
                        color: historyMouse.containsMouse ? "#5F6368" : "transparent"
                        
                        Text {
                            text: "📜"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                        
                        MouseArea {
                            id: historyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: historyMenu.open()
                        }
                        
                        Menu {
                            id: historyMenu
                            x: parent.width - width
                            y: parent.height + 5
                            
                            background: Rectangle {
                                implicitWidth: 300
                                color: "#292A2D"
                                border.color: "#3C4043"
                                radius: 8
                            }
                            
                            MenuItem {
                                text: "📜 Historique de navigation"
                                height: 35
                                enabled: false
                                background: Rectangle { color: "#202124" }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 13
                                    font.bold: true
                                    leftPadding: 10
                                }
                            }
                            
                            MenuSeparator {
                                padding: 0
                                topPadding: 2
                                bottomPadding: 2
                                contentItem: Rectangle {
                                    implicitWidth: 300
                                    implicitHeight: 1
                                    color: "#3C4043"
                                }
                            }
                            
                            MenuItem {
                                text: "🔍 Exporter l'historique"
                                height: 32
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#E8EAED"
                                    font.pixelSize: 12
                                    leftPadding: 10
                                }
                                onClicked: {
                                    console.log("Export historique")
                                    // TODO: Implémenter export
                                }
                            }
                            
                            MenuItem {
                                text: "🗑️ Effacer l'historique"
                                height: 32
                                background: Rectangle { color: parent.hovered ? "#3C4043" : "transparent" }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#FF6B6B"
                                    font.pixelSize: 12
                                    leftPadding: 10
                                }
                                onClicked: {
                                    console.log("Effacer historique")
                                    // TODO: Implémenter clear history
                                }
                            }
                            
                            MenuSeparator {
                                padding: 0
                                topPadding: 2
                                bottomPadding: 2
                                contentItem: Rectangle {
                                    implicitWidth: 300
                                    implicitHeight: 1
                                    color: "#3C4043"
                                }
                            }
                            
                            MenuItem {
                                text: "📄 Historique vide"
                                height: 32
                                enabled: false
                                background: Rectangle { color: "transparent" }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#666666"
                                    font.pixelSize: 12
                                    font.italic: true
                                    leftPadding: 10
                                }
                                // TODO: Remplacer par Repeater avec historique réel
                            }
                        }
                    }
                }
                
                // CONTENU
                Rectangle {
                    width: parent.width
                    height: parent.height - 118
                    color: "#0A0A0A"
                    
                    ScrollView {
                        anchors.fill: parent
                        clip: true
                        
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AlwaysOn
                            width: 12
                            
                            contentItem: Rectangle {
                                implicitWidth: 12
                                radius: 6
                                color: parent.pressed ? "#888888" : (parent.hovered ? "#666666" : "#444444")
                            }
                            
                            background: Rectangle {
                                implicitWidth: 12
                                color: "#1A1A1A"
                            }
                        }
                    
                        Loader {
                            id: contentLoader
                            width: parent.width
                            height: item ? item.implicitHeight : parent.height
                            
                            function reloadContent() {
                                if (window.openTabs.length > 0 && window.activeTabIndex >= 0 && window.activeTabIndex < window.openTabs.length) {
                                    var tab = window.openTabs[window.activeTabIndex]
                                    
                                    if (tab.type === "menu") {
                                        contentLoader.sourceComponent = menuPrincipal
                                        contentLoader.source = ""
                                    } else if (tab.source) {
                                        contentLoader.sourceComponent = null
                                        contentLoader.source = tab.source
                                    } else {
                                        contentLoader.sourceComponent = null
                                        contentLoader.source = ""
                                    }
                                } else {
                                    contentLoader.sourceComponent = null
                                    contentLoader.source = ""
                                }
                            }
                            
                            Component.onCompleted: reloadContent()
                            
                            Connections {
                                target: window
                                function onTabsChanged() {
                                    contentLoader.reloadContent()
                                }
                                function onActiveTabIndexChanged() {
                                    contentLoader.reloadContent()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // FONCTIONS
    function updateCurrentAddress() {
        if (window.openTabs.length > 0 && window.activeTabIndex >= 0 && window.activeTabIndex < window.openTabs.length) {
            var tab = window.openTabs[window.activeTabIndex]
            window.currentAddress = "neosiris://" + tab.type + "/" + tab.name.replace(/ /g, "-").toLowerCase()
        }
    }
    
    function navigateToAddress(address) {
        if (address.startsWith("neosiris://")) {
            var parts = address.replace("neosiris://", "").split("/")
            var pageType = parts[0]
            if (pageType === "menu") {
                navigateToMenu()
            } else {
                var pageName = parts[1] ? parts[1].replace(/-/g, " ") : ""
                navigateToInterface(pageType, pageName)
            }
        }
    }
    
    function navigateToMenu() {
        // Naviguer vers menu dans l'onglet actif
        if (window.openTabs.length > 0 && window.activeTabIndex >= 0) {
            var newTabs = window.openTabs.slice()
            newTabs[window.activeTabIndex] = {
                name: "Menu Principal",
                icon: "🏠",
                type: "menu",
                source: ""
            }
            window.openTabs = newTabs
            updateCurrentAddress()
            window.tabsChanged()
        } else {
            // Pas d'onglet, en créer un
            openMenuTab()
        }
    }
    
    function navigateToInterface(interfaceType, interfaceName) {
        // Naviguer vers interface dans l'onglet actif
        var sourceFile = interfaceType === "avocat" ? "AvocatInterface.qml" : 
                        interfaceType === "syndic" ? "SyndicInterface.qml" :
                        interfaceType === "expert_tech" ? "ExpertTechInterface.qml" :
                        interfaceType === "expert_sante" ? "ExpertSanteInterface.qml" :
                        interfaceType === "charge_affaires" ? "ChargeAffairesInterface.qml" :
                        interfaceType === "architecte" ? "ArchitecteInterface.qml" :
                        interfaceType === "stockage_cloud" ? "StockageCloudInterface.qml" :
                        "CommunicationInterface.qml"
        
        var icon = interfaceType === "avocat" ? "⚖️" :
                  interfaceType === "syndic" ? "🏢" :
                  interfaceType === "expert_tech" ? "🔧" :
                  interfaceType === "expert_sante" ? "🏥" :
                  interfaceType === "charge_affaires" ? "💼" :
                  interfaceType === "architecte" ? "🏛️" :
                  interfaceType === "stockage_cloud" ? "☁️" : "💬"
        
        if (!interfaceName) {
            interfaceName = interfaceType === "avocat" ? "Avocats" :
                           interfaceType === "syndic" ? "Syndic" :
                           interfaceType === "expert_tech" ? "Expert Technique" :
                           interfaceType === "expert_sante" ? "Expert Santé" :
                           interfaceType === "charge_affaires" ? "Chargé d'affaires" :
                           interfaceType === "architecte" ? "Architecte" :
                           interfaceType === "stockage_cloud" ? "Stockage Cloud" : "Communication"
        }
        
        if (window.openTabs.length > 0 && window.activeTabIndex >= 0) {
            // Remplacer onglet actif
            var newTabs = window.openTabs.slice()
            newTabs[window.activeTabIndex] = {
                name: interfaceName,
                icon: icon,
                type: interfaceType,
                source: sourceFile
            }
            window.openTabs = newTabs
            updateCurrentAddress()
            window.tabsChanged()
        } else {
            // Pas d'onglet, en créer un
            openInterfaceTab(interfaceType, interfaceName)
        }
    }
    
    function openMenuTab() {
        var isFirstTab = window.openTabs.length === 0
        var newTabs = window.openTabs.slice()
        newTabs.push({ name: "Menu Principal", icon: "🏠", type: "menu", source: "" })
        window.openTabs = newTabs
        window.activeTabIndex = window.openTabs.length - 1
        updateCurrentAddress()
        window.tabsChanged()
        if (isFirstTab) {
            mainStack.replace(mainWorkspace)
        }
    }
    
    function openInterfaceTab(interfaceType, interfaceName) {
        var sourceFile = interfaceType === "dashboard" ? "DashboardInterface.qml" :
                        interfaceType === "avocat" ? "AvocatInterface.qml" : 
                        interfaceType === "syndic" ? "SyndicInterface.qml" :
                        interfaceType === "expert_tech" ? "ExpertTechInterface.qml" :
                        interfaceType === "expert_sante" ? "ExpertSanteInterface.qml" :
                        interfaceType === "charge_affaires" ? "ChargeAffairesInterface.qml" :
                        interfaceType === "architecte" ? "ArchitecteInterface.qml" :
                        interfaceType === "stockage_cloud" ? "StockageCloudInterface.qml" :
                        interfaceType === "mails" ? "MailsInterface.qml" :
                        interfaceType === "calendrier" ? "CalendrierInterface.qml" :
                        interfaceType === "parametres" ? "ParametresInterface.qml" : ""
        
        var icon = interfaceType === "dashboard" ? "📊" :
                  interfaceType === "avocat" ? "⚖️" :
                  interfaceType === "syndic" ? "🏢" :
                  interfaceType === "expert_tech" ? "🔧" :
                  interfaceType === "expert_sante" ? "🏥" :
                  interfaceType === "charge_affaires" ? "💼" :
                  interfaceType === "architecte" ? "🏛️" :
                  interfaceType === "stockage_cloud" ? "☁️" :
                  interfaceType === "mails" ? "📧" :
                  interfaceType === "calendrier" ? "📅" :
                  interfaceType === "parametres" ? "⚙️" : ""
        
        if (!interfaceName) {
            interfaceName = interfaceType === "dashboard" ? "Tableau de Bord" :
                           interfaceType === "avocat" ? "Avocats" :
                           interfaceType === "syndic" ? "Syndic" :
                           interfaceType === "expert_tech" ? "Expert Technique" :
                           interfaceType === "expert_sante" ? "Expert Santé" :
                           interfaceType === "charge_affaires" ? "Chargé d'affaires" :
                           interfaceType === "architecte" ? "Architecte" :
                           interfaceType === "stockage_cloud" ? "Stockage Cloud" :
                           interfaceType === "mails" ? "Mails" :
                           interfaceType === "calendrier" ? "Calendrier" :
                           interfaceType === "parametres" ? "Paramètres" : ""
        }
        
        var newTabs = window.openTabs.slice()
        newTabs.push({ name: interfaceName, icon: icon, type: interfaceType, source: sourceFile })
        window.openTabs = newTabs
        window.activeTabIndex = window.openTabs.length - 1
        updateCurrentAddress()
        window.tabsChanged()
    }
    
    function closeTab(index) {
        var newTabs = window.openTabs.slice()
        newTabs.splice(index, 1)
        window.openTabs = newTabs
        if (window.openTabs.length === 0) {
            openMenuTab()
        } else if (window.activeTabIndex >= window.openTabs.length) {
            window.activeTabIndex = window.openTabs.length - 1
        } else if (window.activeTabIndex === index && index > 0) {
            window.activeTabIndex = index - 1
        }
        updateCurrentAddress()
        window.tabsChanged()
    }
    
    // FONCTIONS FAVORIS
    function saveFavoritesToVault() {
        try {
            app.saveFavorites(JSON.stringify(window.favoritePages))
        } catch(e) {
            console.log("Erreur sauvegarde favoris:", e)
        }
    }
    
    function loadFavoritesFromVault() {
        try {
            var favs = app.loadFavorites()
            if (favs && favs !== "[]") {
                window.favoritePages = JSON.parse(favs)
            }
        } catch(e) {
            console.log("Erreur chargement favoris:", e)
        }
    }
    
    function isCurrentPageInFavorites() {
        if (window.openTabs.length === 0 || window.activeTabIndex < 0) return false
        var currentTab = window.openTabs[window.activeTabIndex]
        
        for (var i = 0; i < window.favoritePages.length; i++) {
            var fav = window.favoritePages[i]
            if (!fav.isFolder && fav.type === currentTab.type) {
                return true
            }
        }
        return false
    }
    
    function toggleCurrentPageFavorite() {
        if (window.openTabs.length === 0 || window.activeTabIndex < 0) return
        
        var currentTab = window.openTabs[window.activeTabIndex]
        var newFavs = window.favoritePages.slice()
        var found = false
        
        // Vérifier si déjà dans les favoris
        for (var i = 0; i < newFavs.length; i++) {
            if (!newFavs[i].isFolder && newFavs[i].type === currentTab.type) {
                // Supprimer
                newFavs.splice(i, 1)
                found = true
                break
            }
        }
        
        // Si pas trouvé, ajouter
        if (!found) {
            newFavs.push({
                name: currentTab.name,
                icon: currentTab.icon,
                type: currentTab.type,
                isFolder: false
            })
        }
        
        window.favoritePages = newFavs
        window.saveFavoritesToVault()
    }
}
