// ProfilesPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#0A0A0A"
    
    // États de recherche et tri
    property string profileSearchText: ""
    property string lawyerSearchText: ""
    property string profileSortBy: "name"
    property string lawyerSortBy: "name"
    property int refreshTrigger: 0
    
    // Timer pour forcer refresh
    Timer {
        id: refreshTimer
        interval: 100
        onTriggered: root.refreshTrigger++
    }
    
    Connections {
        target: profilesModule
        function onDataChanged() {
            refreshTimer.start()
        }
    }
    
    // Fonctions JS
    function getFilteredProfiles() {
        if (!profilesModule) return []
        
        var profiles = profilesModule.getProfiles()
        console.log("QML getFilteredProfiles appelé, profils:", profiles.length)
        var filtered = []
        
        for (var i = 0; i < profiles.length; i++) {
            var profile = profiles[i]
            var searchLower = root.profileSearchText.toLowerCase()
            
            if (searchLower === "" ||
                (profile.name && profile.name.toLowerCase().includes(searchLower)) ||
                (profile.firstName && profile.firstName.toLowerCase().includes(searchLower)) ||
                (profile.email && profile.email.toLowerCase().includes(searchLower))) {
                filtered.push(profile)
            }
        }
        
        // Tri
        if (root.profileSortBy === "name") {
            filtered.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.profileSortBy === "date") {
            filtered.sort(function(a, b) {
                return new Date(b.created) - new Date(a.created)
            })
        } else if (root.profileSortBy === "status") {
            filtered.sort(function(a, b) {
                return (b.active ? 1 : 0) - (a.active ? 1 : 0)
            })
        }
        
        return filtered
    }
    
    function getFilteredLawyers() {
        if (!profilesModule) return []
        
        var lawyers = profilesModule.getLawyers()
        var filtered = []
        
        for (var i = 0; i < lawyers.length; i++) {
            var lawyer = lawyers[i]
            var searchLower = root.lawyerSearchText.toLowerCase()
            
            if (searchLower === "" ||
                (lawyer.name && lawyer.name.toLowerCase().includes(searchLower)) ||
                (lawyer.firstName && lawyer.firstName.toLowerCase().includes(searchLower)) ||
                (lawyer.email && lawyer.email.toLowerCase().includes(searchLower))) {
                filtered.push(lawyer)
            }
        }
        
        // Tri
        if (root.lawyerSortBy === "name") {
            filtered.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.lawyerSortBy === "date") {
            filtered.sort(function(a, b) {
                return new Date(b.created) - new Date(a.created)
            })
        } else if (root.lawyerSortBy === "status") {
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
                    
                    // Titre Rédacteurs
                    Text {
                        text: {
                            root.refreshTrigger // Force update
                            return "✍️ Rédacteurs (" + getFilteredProfiles().length + ")"
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
                            text: root.profileSearchText
                            onTextChanged: root.profileSearchText = text
                            
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
                                if (currentIndex === 0) root.profileSortBy = "name"
                                else if (currentIndex === 1) root.profileSortBy = "date"
                                else root.profileSortBy = "status"
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
                                profileEditDialog.cardType = "profile"
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
                                return getFilteredProfiles()
                            }
                            
                            ProfileCard {
                                width: parent.width
                                profileId: modelData.id
                                profileName: modelData.name
                                profileFirstName: modelData.firstName
                                profileImage: modelData.image
                                isActive: modelData.active !== undefined ? modelData.active : false
                                cardType: "profile"
                                
                                onViewClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "view"
                                    profileEditDialog.cardType = "profile"
                                    profileEditDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "edit"
                                    profileEditDialog.cardType = "profile"
                                    profileEditDialog.open()
                                }
                                
                                onDeleteClicked: {
                                    deleteDialog.itemName = modelData.name
                                    deleteDialog.itemId = modelData.id
                                    deleteDialog.itemType = "profile"
                                    deleteDialog.open()
                                }
                                
                                onActiveToggled: function(active) {
                                    if (active) {
                                        // Désactiver tous les autres profils
                                        var allProfiles = profilesModule.getProfiles()
                                        for (var i = 0; i < allProfiles.length; i++) {
                                            if (allProfiles[i].id !== modelData.id && allProfiles[i].active) {
                                                profilesModule.toggleProfileActive(allProfiles[i].id, false)
                                            }
                                        }
                                    }
                                    profilesModule.toggleProfileActive(modelData.id, active)
                                }
                            }
                        }
                        
                        // Message si vide
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 50
                            text: "Aucun rédacteur\n\nCliquez sur 'Ajouter' pour créer votre premier rédacteur"
                            font.pixelSize: 14
                            color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            visible: getFilteredProfiles().length === 0
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
                
                // Titre Tons
                Text {
                    text: {
                        root.refreshTrigger // Force update
                        return "🎭 Tons (" + getFilteredLawyers().length + ")"
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
                        text: root.lawyerSearchText
                        onTextChanged: root.lawyerSearchText = text
                        
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
                            if (currentIndex === 0) root.lawyerSortBy = "name"
                            else if (currentIndex === 1) root.lawyerSortBy = "date"
                            else root.lawyerSortBy = "status"
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
                            profileEditDialog.cardType = "lawyer"
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
                                return getFilteredLawyers()
                            }
                            
                            ProfileCard {
                                width: parent.width
                                profileId: modelData.id
                                profileName: modelData.name
                                profileFirstName: modelData.title || ""
                                profileImage: modelData.image
                                isActive: modelData.active !== undefined ? modelData.active : false
                                cardType: "lawyer"
                                
                                onViewClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "view"
                                    profileEditDialog.cardType = "lawyer"
                                    profileEditDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileEditDialog.profileData = modelData
                                    profileEditDialog.mode = "edit"
                                    profileEditDialog.cardType = "lawyer"
                                    profileEditDialog.open()
                                }
                                
                                onDeleteClicked: {
                                    deleteDialog.itemName = modelData.name
                                    deleteDialog.itemId = modelData.id
                                    deleteDialog.itemType = "lawyer"
                                    deleteDialog.open()
                                }
                                
                                onActiveToggled: function(active) {
                                    if (active) {
                                        // Désactiver tous les autres tons
                                        var allLawyers = profilesModule.getLawyers()
                                        for (var i = 0; i < allLawyers.length; i++) {
                                            if (allLawyers[i].id !== modelData.id && allLawyers[i].active) {
                                                profilesModule.toggleLawyerActive(allLawyers[i].id, false)
                                            }
                                        }
                                    }
                                    profilesModule.toggleLawyerActive(modelData.id, active)
                                }
                                }
                            }
                        }
                        
                        // Message si vide
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 50
                            text: "Aucun ton\n\nCliquez sur 'Ajouter' pour créer votre premier ton"
                            font.pixelSize: 14
                            color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            visible: getFilteredLawyers().length === 0
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
            if (profileEditDialog.cardType === "profile") {
                if (profileEditDialog.mode === "add") {
                    profilesModule.addProfile(data)
                } else {
                    profilesModule.updateProfile(data)
                }
            } else {
                if (profileEditDialog.mode === "add") {
                    profilesModule.addLawyer(data)
                } else {
                    profilesModule.updateLawyer(data)
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
        property string itemType: "profile"
        
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
                        if (deleteDialog.itemType === "profile") {
                            profilesModule.deleteProfile(deleteDialog.itemId)
                        } else {
                            profilesModule.deleteLawyer(deleteDialog.itemId)
                        }
                        deleteDialog.close()
                    }
                }
            }
        }
    }
}
