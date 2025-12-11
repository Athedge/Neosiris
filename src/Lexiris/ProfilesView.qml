// ProfilesView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: Theme.background
    
    // États pour la recherche et le tri
    property string profileSearchText: ""
    property string toneSearchText: ""
    property string profileSortBy: "name" // "name", "date", "active"
    property string toneSortBy: "name"
    
    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacingLarge
        
        // Colonne PROFILS
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header Profils
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Theme.backgroundSecondary
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Titre et bouton ajouter
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingXLarge
                                spacing: Theme.spacingLarge
                                
                                Rectangle {
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 60
                                    radius: Theme.cardRadius
                                    color: Theme.primary
                                    
                                    Text {
                                        text: "👤"
                                        font.pixelSize: Theme.iconSizeLarge
                                        anchors.centerIn: parent
                                    }
                                }
                                
                                ColumnLayout {
                                    spacing: 4
                                    
                                    Text {
                                        text: "Profils"
                                        font.pixelSize: Theme.fontSizeTitle
                                        font.bold: true
                                        color: Theme.textPrimary
                                    }
                                    
                                    Text {
                                        text: profileListView.count + " profil(s)"
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.textSecondary
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    Layout.preferredHeight: 50
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? Theme.buttonBackgroundHover : Theme.buttonBackground
                                        radius: Theme.buttonRadius
                                    }
                                    
                                    contentItem: RowLayout {
                                        spacing: Theme.spacingSmall
                                        
                                        Text {
                                            text: "➕"
                                            font.pixelSize: 18
                                        }
                                        
                                        Text {
                                            text: "Ajouter"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.bold: true
                                            color: Theme.buttonText
                                            leftPadding: Theme.spacingSmall
                                            rightPadding: Theme.spacingMedium
                                        }
                                    }
                                    
                                    onClicked: {
                                        profileDialog.mode = "add"
                                        profileDialog.itemType = "profile"
                                        profileDialog.itemData = {}
                                        profileDialog.open()
                                    }
                                }
                            }
                        }
                        
                        // Barre de recherche et filtres
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            color: "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingXLarge
                                anchors.rightMargin: Theme.spacingXLarge
                                anchors.bottomMargin: Theme.spacingMedium
                                spacing: Theme.spacingMedium
                                
                                // Recherche
                                TextField {
                                    id: profileSearchField
                                    Layout.fillWidth: true
                                    placeholderText: "🔍 Rechercher un profil..."
                                    
                                    background: Rectangle {
                                        color: Theme.inputBackground
                                        radius: Theme.inputRadius
                                        border.color: parent.activeFocus ? Theme.inputBorderFocus : Theme.inputBorder
                                        border.width: 2
                                    }
                                    
                                    color: Theme.inputText
                                    font.pixelSize: Theme.fontSizeMedium
                                    leftPadding: Theme.spacingMedium
                                    height: Theme.inputHeight
                                    
                                    onTextChanged: root.profileSearchText = text
                                }
                                
                                // Tri
                                ComboBox {
                                    id: profileSortCombo
                                    Layout.preferredWidth: 150
                                    model: ["Par nom", "Par date", "Par statut"]
                                    
                                    background: Rectangle {
                                        color: Theme.inputBackground
                                        radius: Theme.inputRadius
                                        border.color: Theme.inputBorder
                                        border.width: 2
                                    }
                                    
                                    contentItem: Text {
                                        leftPadding: Theme.spacingMedium
                                        text: parent.displayText
                                        color: Theme.inputText
                                        font.pixelSize: Theme.fontSizeMedium
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        if (currentIndex === 0) root.profileSortBy = "name"
                                        else if (currentIndex === 1) root.profileSortBy = "date"
                                        else root.profileSortBy = "active"
                                    }
                                }
                                
                                // Importer
                                Button {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: Theme.inputHeight
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? Theme.success : "transparent"
                                        radius: Theme.buttonRadius
                                        border.color: Theme.success
                                        border.width: 2
                                    }
                                    
                                    contentItem: Text {
                                        text: "📥 Import"
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: parent.parent.hovered ? Theme.buttonText : Theme.success
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: console.log("Import profils")
                                }
                            }
                        }
                    }
                }
                
                // Liste des profils
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.background
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingLarge
                        clip: true
                        
                        ScrollBar.vertical: ScrollBar {
                            width: Theme.scrollbarWidth
                            
                            background: Rectangle {
                                color: Theme.scrollbarBackground
                            }
                            
                            contentItem: Rectangle {
                                radius: Theme.scrollbarWidth / 2
                                color: parent.hovered ? Theme.scrollbarHandleHover : Theme.scrollbarHandle
                            }
                        }
                        
                        ListView {
                            id: profileListView
                            width: parent.width
                            spacing: Theme.spacingMedium
                            model: getFilteredProfiles()
                            
                            delegate: ProfileItem {
                                itemId: modelData.id
                                itemName: modelData.name + (modelData.firstName ? " " + modelData.firstName : "")
                                itemSubtitle: modelData.email || ""
                                imagePath: modelData.image || ""
                                isActive: modelData.active || false
                                itemType: "profile"
                                
                                onViewClicked: {
                                    profileDialog.mode = "view"
                                    profileDialog.itemType = "profile"
                                    profileDialog.itemData = modelData
                                    profileDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileDialog.mode = "edit"
                                    profileDialog.itemType = "profile"
                                    profileDialog.itemData = modelData
                                    profileDialog.open()
                                }
                                
                                onExportClicked: {
                                    profilesModule.exportProfile(modelData.id)
                                }
                                
                                onActiveToggled: function(active) {
                                    profilesModule.toggleProfileActive(modelData.id, active)
                                }
                            }
                            
                            // Message si vide
                            Text {
                                anchors.centerIn: parent
                                text: root.profileSearchText !== "" ? 
                                      "Aucun profil trouvé" : 
                                      "Aucun profil\n\nCliquez sur 'Ajouter' pour créer votre premier profil"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                                visible: profileListView.count === 0
                            }
                        }
                    }
                }
            }
        }
        
        // Séparateur vertical
        Rectangle {
            Layout.preferredWidth: 2
            Layout.fillHeight: true
            color: Theme.cardBorder
        }
        
        // Colonne TONS
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header Tons
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: Theme.backgroundSecondary
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Titre et bouton ajouter
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingXLarge
                                spacing: Theme.spacingLarge
                                
                                Rectangle {
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 60
                                    radius: Theme.cardRadius
                                    color: Theme.warning
                                    
                                    Text {
                                        text: "✍️"
                                        font.pixelSize: Theme.iconSizeLarge
                                        anchors.centerIn: parent
                                    }
                                }
                                
                                ColumnLayout {
                                    spacing: 4
                                    
                                    Text {
                                        text: "Tons"
                                        font.pixelSize: Theme.fontSizeTitle
                                        font.bold: true
                                        color: Theme.textPrimary
                                    }
                                    
                                    Text {
                                        text: toneListView.count + " ton(s)"
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.textSecondary
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    Layout.preferredHeight: 50
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? Qt.darker(Theme.warning, 1.2) : Theme.warning
                                        radius: Theme.buttonRadius
                                    }
                                    
                                    contentItem: RowLayout {
                                        spacing: Theme.spacingSmall
                                        
                                        Text {
                                            text: "➕"
                                            font.pixelSize: 18
                                        }
                                        
                                        Text {
                                            text: "Ajouter"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.bold: true
                                            color: Theme.buttonText
                                            leftPadding: Theme.spacingSmall
                                            rightPadding: Theme.spacingMedium
                                        }
                                    }
                                    
                                    onClicked: {
                                        profileDialog.mode = "add"
                                        profileDialog.itemType = "tone"
                                        profileDialog.itemData = {}
                                        profileDialog.open()
                                    }
                                }
                            }
                        }
                        
                        // Barre de recherche et filtres
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            color: "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingXLarge
                                anchors.rightMargin: Theme.spacingXLarge
                                anchors.bottomMargin: Theme.spacingMedium
                                spacing: Theme.spacingMedium
                                
                                // Recherche
                                TextField {
                                    id: toneSearchField
                                    Layout.fillWidth: true
                                    placeholderText: "🔍 Rechercher un ton..."
                                    
                                    background: Rectangle {
                                        color: Theme.inputBackground
                                        radius: Theme.inputRadius
                                        border.color: parent.activeFocus ? Theme.inputBorderFocus : Theme.inputBorder
                                        border.width: 2
                                    }
                                    
                                    color: Theme.inputText
                                    font.pixelSize: Theme.fontSizeMedium
                                    leftPadding: Theme.spacingMedium
                                    height: Theme.inputHeight
                                    
                                    onTextChanged: root.toneSearchText = text
                                }
                                
                                // Tri
                                ComboBox {
                                    id: toneSortCombo
                                    Layout.preferredWidth: 150
                                    model: ["Par nom", "Par date", "Par statut"]
                                    
                                    background: Rectangle {
                                        color: Theme.inputBackground
                                        radius: Theme.inputRadius
                                        border.color: Theme.inputBorder
                                        border.width: 2
                                    }
                                    
                                    contentItem: Text {
                                        leftPadding: Theme.spacingMedium
                                        text: parent.displayText
                                        color: Theme.inputText
                                        font.pixelSize: Theme.fontSizeMedium
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        if (currentIndex === 0) root.toneSortBy = "name"
                                        else if (currentIndex === 1) root.toneSortBy = "date"
                                        else root.toneSortBy = "active"
                                    }
                                }
                                
                                // Importer
                                Button {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: Theme.inputHeight
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? Theme.success : "transparent"
                                        radius: Theme.buttonRadius
                                        border.color: Theme.success
                                        border.width: 2
                                    }
                                    
                                    contentItem: Text {
                                        text: "📥 Import"
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: parent.parent.hovered ? Theme.buttonText : Theme.success
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: console.log("Import tons")
                                }
                            }
                        }
                    }
                }
                
                // Liste des tons
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.background
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingLarge
                        clip: true
                        
                        ScrollBar.vertical: ScrollBar {
                            width: Theme.scrollbarWidth
                            
                            background: Rectangle {
                                color: Theme.scrollbarBackground
                            }
                            
                            contentItem: Rectangle {
                                radius: Theme.scrollbarWidth / 2
                                color: parent.hovered ? Theme.scrollbarHandleHover : Theme.scrollbarHandle
                            }
                        }
                        
                        ListView {
                            id: toneListView
                            width: parent.width
                            spacing: Theme.spacingMedium
                            model: getFilteredTones()
                            
                            delegate: ProfileItem {
                                itemId: modelData.id
                                itemName: modelData.name
                                itemSubtitle: modelData.toneType || ""
                                imagePath: modelData.image || ""
                                isActive: modelData.active || false
                                itemType: "tone"
                                
                                onViewClicked: {
                                    profileDialog.mode = "view"
                                    profileDialog.itemType = "tone"
                                    profileDialog.itemData = modelData
                                    profileDialog.open()
                                }
                                
                                onEditClicked: {
                                    profileDialog.mode = "edit"
                                    profileDialog.itemType = "tone"
                                    profileDialog.itemData = modelData
                                    profileDialog.open()
                                }
                                
                                onExportClicked: {
                                    profilesModule.exportTone(modelData.id)
                                }
                                
                                onActiveToggled: function(active) {
                                    profilesModule.toggleToneActive(modelData.id, active)
                                }
                            }
                            
                            // Message si vide
                            Text {
                                anchors.centerIn: parent
                                text: root.toneSearchText !== "" ? 
                                      "Aucun ton trouvé" : 
                                      "Aucun ton\n\nCliquez sur 'Ajouter' pour créer votre premier ton"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                                visible: toneListView.count === 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialog réutilisable
    ProfileDialog {
        id: profileDialog
        
        onSaved: function(data) {
            if (itemType === "profile") {
                if (mode === "add") {
                    profilesModule.addProfile(data)
                } else {
                    profilesModule.updateProfile(data)
                }
            } else {
                if (mode === "add") {
                    profilesModule.addTone(data)
                } else {
                    profilesModule.updateTone(data)
                }
            }
        }
    }
    
    // Fonctions de filtrage
    function getFilteredProfiles() {
        var profiles = profilesModule.getProfiles()
        
        // Filtrer par recherche
        if (root.profileSearchText !== "") {
            profiles = profiles.filter(function(p) {
                var searchLower = root.profileSearchText.toLowerCase()
                return (p.name && p.name.toLowerCase().includes(searchLower)) ||
                       (p.firstName && p.firstName.toLowerCase().includes(searchLower)) ||
                       (p.email && p.email.toLowerCase().includes(searchLower))
            })
        }
        
        // Trier
        if (root.profileSortBy === "name") {
            profiles.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.profileSortBy === "active") {
            profiles.sort(function(a, b) {
                return (b.active ? 1 : 0) - (a.active ? 1 : 0)
            })
        }
        
        return profiles
    }
    
    function getFilteredTones() {
        var tones = profilesModule.getTones()
        
        // Filtrer par recherche
        if (root.toneSearchText !== "") {
            tones = tones.filter(function(t) {
                var searchLower = root.toneSearchText.toLowerCase()
                return (t.name && t.name.toLowerCase().includes(searchLower)) ||
                       (t.toneType && t.toneType.toLowerCase().includes(searchLower))
            })
        }
        
        // Trier
        if (root.toneSortBy === "name") {
            tones.sort(function(a, b) {
                return (a.name || "").localeCompare(b.name || "")
            })
        } else if (root.toneSortBy === "active") {
            tones.sort(function(a, b) {
                return (b.active ? 1 : 0) - (a.active ? 1 : 0)
            })
        }
        
        return tones
    }
}
