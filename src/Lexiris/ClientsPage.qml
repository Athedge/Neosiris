// ClientsPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#0A0A0A"
    
    // États de recherche et tri
    property string clientSearchText: ""
    property string dossierSearchText: ""
    property string clientSortBy: "name"
    property string dossierSortBy: "name"
    property int refreshTrigger: 0
    
    // Timer pour forcer refresh
    Timer {
        id: refreshTimer
        interval: 100
        onTriggered: root.refreshTrigger++
    }
    
    Connections {
        target: clientsModule
        function onDataChanged() {
            refreshTimer.start()
        }
    }
    
    // Fonctions JS
    function getFilteredClients() {
        if (!clientsModule) return []
        
        var profiles = clientsModule.getClients()
        console.log("QML getFilteredClients appelé, profils:", profiles.length)
        var filtered = []
        
        for (var i = 0; i < profiles.length; i++) {
            var profile = profiles[i]
            var searchLower = root.clientSearchText.toLowerCase()
            
            if (searchLower === "" ||
                (profile.name && profile.name.toLowerCase().includes(searchLower)) ||
                (profile.firstName && profile.firstName.toLowerCase().includes(searchLower)) ||
                (profile.email && profile.email.toLowerCase().includes(searchLower))) {
                filtered.push(profile)
            }
        }
        
        // Tri
        if (root.clientSortBy === "name") {
            filtered.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.clientSortBy === "date") {
            filtered.sort(function(a, b) {
                return new Date(b.created) - new Date(a.created)
            })
        } else if (root.clientSortBy === "status") {
            filtered.sort(function(a, b) {
                return (b.active ? 1 : 0) - (a.active ? 1 : 0)
            })
        }
        
        return filtered
    }
    
    function getFilteredDossiers() {
        if (!clientsModule) return []
        
        var lawyers = clientsModule.getDossiers()
        var filtered = []
        
        for (var i = 0; i < lawyers.length; i++) {
            var lawyer = lawyers[i]
            var searchLower = root.dossierSearchText.toLowerCase()
            
            if (searchLower === "" ||
                (lawyer.name && lawyer.name.toLowerCase().includes(searchLower)) ||
                (lawyer.firstName && lawyer.firstName.toLowerCase().includes(searchLower)) ||
                (lawyer.email && lawyer.email.toLowerCase().includes(searchLower))) {
                filtered.push(lawyer)
            }
        }
        
        // Tri
        if (root.dossierSortBy === "name") {
            filtered.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.dossierSortBy === "date") {
            filtered.sort(function(a, b) {
                return new Date(b.created) - new Date(a.created)
            })
        } else if (root.dossierSortBy === "status") {
            filtered.sort(function(a, b) {
                return (b.active ? 1 : 0) - (a.active ? 1 : 0)
            })
        }
        
        return filtered
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 30
        
        // Titre principal
        Text {
            text: "👤 Profils"
            font.pixelSize: 32
            font.bold: true
            color: "#FFFFFF"
        }
    
        RowLayout {
            width: parent.width
            spacing: 30
            height: parent.height - 100
            
            // COLONNE RÉDACTEURS
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"
                radius: 12
                border.color: "#3B3B3B"
                border.width: 1
            
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Titre Clients
                    Text {
                        text: {
                            root.refreshTrigger // Force update
                            return "✍️ Clients (" + getFilteredClients().length + ")"
                        }
                        font.pixelSize: 18
                        font.bold: true
                        color: "#FFFFFF"
                        Layout.fillWidth: true
                    }
                    
                    // Ligne de contrôles
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // Barre de recherche
                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            placeholderText: "🔍 Rechercher..."
                            text: root.clientSearchText
                            onTextChanged: root.clientSearchText = text
                            
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 1
                            }
                            
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                        
                        // Tri
                        ComboBox {
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 40
                            model: ["Par nom", "Par date", "Par statut"]
                            currentIndex: 0
                            
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                font.pixelSize: 12
                                color: "#FFFFFF"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                leftPadding: 10
                            }
                            
                            onCurrentIndexChanged: {
                                if (currentIndex === 0) root.clientSortBy = "name"
                                else if (currentIndex === 1) root.clientSortBy = "date"
                                else root.clientSortBy = "status"
                            }
                        }
                        
                        // Import
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: "📥"
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: console.log("Import profiles")
                            
                            ToolTip.visible: hovered
                            ToolTip.text: "Importer"
                            ToolTip.delay: 500
                        }
                        
                        // Ajouter
                        Button {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: "➕"
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                profileEditDialog.profileData = {}
                                profileEditDialog.mode = "add"
                                profileEditDialog.cardType = "client"
                                profileEditDialog.open()
                            }
                            
                            ToolTip.visible: hovered
                            ToolTip.text: "Ajouter"
                            ToolTip.delay: 500
                        }
                    }
                
                // Liste des profils
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    
                    Column {
                        width: parent.parent.width - 20
                        spacing: 10
                        
                        Repeater {
                            model: {
                                root.refreshTrigger // Force update
                                return getFilteredClients()
                            }
                            
                            ProfileCard {
                                width: parent.width
                                profileId: modelData.id
                                profileName: modelData.name
                                profileFirstName: modelData.firstName
                                profileImage: modelData.image
                                isActive: modelData.active !== undefined ? modelData.active : false
                                cardType: "client"
                                
                                onViewClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "view"
                                    profileEditDialog.cardType = "client"
                                    profileEditDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "edit"
                                    profileEditDialog.cardType = "client"
                                    profileEditDialog.open()
                                }
                                
                                onDeleteClicked: {
                                    deleteDialog.itemName = modelData.name
                                    deleteDialog.itemId = modelData.id
                                    deleteDialog.itemType = "client"
                                    deleteDialog.open()
                                }
                                
                                onActiveToggled: function(active) {
                                    if (active) {
                                        // Désactiver tous les autres profils
                                        var allProfiles = clientsModule.getClients()
                                        for (var i = 0; i < allProfiles.length; i++) {
                                            if (allProfiles[i].id !== modelData.id && allProfiles[i].active) {
                                                clientsModule.toggleProfileActive(allProfiles[i].id, false)
                                            }
                                        }
                                    }
                                    clientsModule.toggleProfileActive(modelData.id, active)
                                }
                            }
                        }
                        
                        // Message si vide
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 50
                            text: "Aucun client\n\nCliquez sur 'Ajouter' pour créer votre premier client"
                            font.pixelSize: 14
                            color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            visible: getFilteredClients().length === 0
                        }
                    }
                }
            }
        }
        
        // COLONNE TONS
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1E1E1E"
            radius: 12
            border.color: "#3B3B3B"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Titre Dossiers
                Text {
                    text: {
                        root.refreshTrigger // Force update
                        return "🎭 Dossiers (" + getFilteredDossiers().length + ")"
                    }
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    Layout.fillWidth: true
                }
                
                // Ligne de contrôles
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    // Barre de recherche
                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        placeholderText: "🔍 Rechercher..."
                        text: root.dossierSearchText
                        onTextChanged: root.dossierSearchText = text
                        
                        background: Rectangle {
                            color: "#2B2B2B"
                            radius: 8
                            border.color: parent.activeFocus ? "#2596be" : "#3B3B3B"
                            border.width: 1
                        }
                        
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }
                    
                    // Tri
                    ComboBox {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 40
                        model: ["Par nom", "Par date", "Par statut"]
                        currentIndex: 0
                        
                        background: Rectangle {
                            color: parent.hovered ? "#1e7da0" : "#2596be"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: parent.displayText
                            font.pixelSize: 12
                            color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
                        }
                        
                        onCurrentIndexChanged: {
                            if (currentIndex === 0) root.dossierSortBy = "name"
                            else if (currentIndex === 1) root.dossierSortBy = "date"
                            else root.dossierSortBy = "status"
                        }
                    }
                    
                    // Import
                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        
                        background: Rectangle {
                            color: parent.hovered ? "#1e7da0" : "#2596be"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: "📥"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: console.log("Import lawyers")
                        
                        ToolTip.visible: hovered
                        ToolTip.text: "Importer"
                        ToolTip.delay: 500
                    }
                    
                    // Ajouter
                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        
                        background: Rectangle {
                            color: parent.hovered ? "#1e7da0" : "#2596be"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: "➕"
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            profileEditDialog.profileData = {}
                            profileEditDialog.mode = "add"
                            profileEditDialog.cardType = "dossier"
                            profileEditDialog.open()
                        }
                        
                        ToolTip.visible: hovered
                        ToolTip.text: "Ajouter"
                        ToolTip.delay: 500
                    }
                }
                
                // Liste des avocats
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    
                    Column {
                        width: parent.parent.width - 20
                        spacing: 10
                        
                        Repeater {
                            model: {
                                root.refreshTrigger // Force update
                                return getFilteredDossiers()
                            }
                            
                            ProfileCard {
                                width: parent.width
                                profileId: modelData.id
                                profileName: modelData.name
                                profileFirstName: modelData.title || ""
                                profileImage: modelData.image
                                isActive: modelData.active !== undefined ? modelData.active : false
                                cardType: "dossier"
                                
                                onViewClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "view"
                                    profileEditDialog.cardType = "dossier"
                                    profileEditDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "edit"
                                    profileEditDialog.cardType = "dossier"
                                    profileEditDialog.open()
                                }
                                
                                onDeleteClicked: {
                                    deleteDialog.itemName = modelData.name
                                    deleteDialog.itemId = modelData.id
                                    deleteDialog.itemType = "dossier"
                                    deleteDialog.open()
                                }
                                
                                onActiveToggled: function(active) {
                                    if (active) {
                                        // Désactiver tous les autres dossiers
                                        var allLawyers = clientsModule.getDossiers()
                                        for (var i = 0; i < allLawyers.length; i++) {
                                            if (allLawyers[i].id !== modelData.id && allLawyers[i].active) {
                                                clientsModule.toggleLawyerActive(allLawyers[i].id, false)
                                            }
                                        }
                                    }
                                    clientsModule.toggleLawyerActive(modelData.id, active)
                                }
                                }
                            }
                        }
                        
                        // Message si vide
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 50
                            text: "Aucun dossier\n\nCliquez sur 'Ajouter' pour créer votre premier dossier"
                            font.pixelSize: 14
                            color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            visible: getFilteredDossiers().length === 0
                        }
                    }
                }
            }
        }
    }
    
    // Dialog d'édition
    ProfileEditDialog {
        id: profileEditDialog
        
        onSaved: function(data) {
            if (profileEditDialog.cardType === "client") {
                if (profileEditDialog.mode === "add") {
                    clientsModule.addClient(data)
                } else {
                    clientsModule.updateClient(data)
                }
            } else {
                if (profileEditDialog.mode === "add") {
                    clientsModule.addDossier(data)
                } else {
                    clientsModule.updateDossier(data)
                }
            }
        }
    }
    
    // Dialog de suppression
    Popup {
        id: deleteDialog
        anchors.centerIn: Overlay.overlay
        modal: true
        width: 400
        height: 200
        
        property string itemName: ""
        property string itemId: ""
        property string itemType: "client"
        
        background: Rectangle {
            color: "#1E1E1E"
            radius: 12
            border.color: "#3B3B3B"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            Text {
                text: "🗑 Supprimer"
                font.pixelSize: 18
                font.bold: true
                color: "#FFFFFF"
            }
            
            Text {
                text: "Êtes-vous sûr de vouloir supprimer :\n\n" + deleteDialog.itemName + " ?"
                font.pixelSize: 13
                color: "#FFFFFF"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Annuler"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#3B3B3B" : "transparent"
                        radius: 8
                        border.color: "#3B3B3B"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: deleteDialog.close()
                }
                
                Button {
                    text: "Supprimer"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#c0392b" : "#e74c3c"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (deleteDialog.itemType === "client") {
                            clientsModule.deleteClient(deleteDialog.itemId)
                        } else {
                            clientsModule.deleteDossier(deleteDialog.itemId)
                        }
                        deleteDialog.close()
                    }
                }
            }
        }
    }
}
