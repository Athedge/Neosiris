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
    property string currentPage: "login"
    
    // Raccourcis clavier globaux
    Shortcut {
        sequence: "Ctrl+D"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "dashboard"
                contentStack.replace(dashboardPage)
    }}
    }
    
    Shortcut {
        sequence: "Ctrl+P"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "profiles"
                contentStack.replace(profilesPage)
    }}
    }
    
    Shortcut {
        sequence: "Ctrl+C"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "clients"
                contentStack.replace(clientsPage)
    }}
    }
    
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "dossiers"
                contentStack.replace(dossiersPage)
    }}
    }
    
    Shortcut {
        sequence: "Ctrl+I"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "ia"
                contentStack.replace(iaPage)
    }}
    }
    
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
    
    Shortcut {
        sequence: "F1"
        onActivated: {
            if (window.vaultOpen) {
                window.currentPage = "base"
                contentStack.replace(basePage)
    }}
    }
    
    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: vaultOpen ? mainLayout : loginPage
        
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        }
    }
    
    Component {
        id: loginPage
        Rectangle {
            color: "#0A0A0A"
            Column {
                anchors.centerIn: parent
                spacing: 30
                width: 400
                
                Text {
                    text: "⚖️ NEOSIRIS"
                    font.pixelSize: 56
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Rectangle {
                    width: parent.width
                    height: 350
                    color: "#1E1E1E"
                    radius: 16
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        width: parent.width - 60
                        
                        Text {
                            text: "Connexion"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#FFFFFF"
                        }
                        
                        ComboBox {
                            id: usernameCombo
                            width: parent.width
                            editable: true
                            model: app.getSavedUsers()
                            displayText: editText || currentText
                            
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: usernameCombo.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 2
                            }
                            
                            contentItem: TextInput {
                                leftPadding: 12
                                text: usernameCombo.editText
                                font.pixelSize: 14
                                color: "#FFFFFF"
                                verticalAlignment: Text.AlignVCenter
                                selectByMouse: true
                            }
                            
                            delegate: ItemDelegate {
                                width: usernameCombo.width
                                height: 40
                                
                                contentItem: Text {
                                    text: modelData
                                    font.pixelSize: 14
                                    color: "#FFFFFF"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#3B3B3B" : "#2B2B2B"
    }}
                            
                            popup: Popup {
                                y: usernameCombo.height
                                width: usernameCombo.width
                                height: Math.min(contentItem.implicitHeight, 200)
                                padding: 0
                                
                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: usernameCombo.delegateModel
                                    currentIndex: usernameCombo.highlightedIndex
                                    
                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }
                                
                                background: Rectangle {
                                    color: "#2B2B2B"
                                    radius: 8
                                    border.color: "#3B3B3B"
                                    border.width: 1
    }}
                            
                            Keys.onReturnPressed: passwordField.forceActiveFocus()
                            Keys.onEnterPressed: passwordField.forceActiveFocus()
                        }
                        
                        TextField {
                            id: passwordField
                            width: parent.width
                            placeholderText: "Mot de passe"
                            echoMode: TextInput.Password
                            
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: passwordField.activeFocus ? "#2596be" : "#3B3B3B"
                                border.width: 2
                            }
                            
                            color: "#FFFFFF"
                            leftPadding: 12
                            font.pixelSize: 14
                            
                            Keys.onReturnPressed: loginButton.clicked()
                            Keys.onEnterPressed: loginButton.clicked()
                        }
                        
                        Button {
                            id: loginButton
                            text: "Se connecter"
                            width: parent.width
                            height: 45
                            
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                var username = usernameCombo.editText || usernameCombo.currentText
                                var password = passwordField.text
                                
                                if (username && password) {
                                    loadingScreen.show()
                                    
                                    // Donner le temps à l'UI de se rafraîchir
                                    Qt.callLater(function() {
                                        if (app.openVault(username, password)) {
                                            window.vaultOpen = true
                                            pageStack.replace(mainLayout)
                                        } else {
                                            loadingScreen.visible = false
                                        }
                                    })
                                }
                            }
                        }
                        
                        Text {
                            text: "Première connexion ? Entrez un nom d'utilisateur et mot de passe pour créer votre vault."
                            font.pixelSize: 11
                            color: "#666666"
                            wrapMode: Text.WordWrap
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: mainLayout
        Rectangle {
            color: "#0A0A0A"
            
            Row {
                anchors.fill: parent
                
                // Sidebar
                Rectangle {
                    width: 220
                    height: parent.height
                    color: "#1E1E1E"
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "⚖️ NEOSIRIS"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#FFFFFF"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#3B3B3B"
                        }
                        
                        Repeater {
                            model: [
                                {icon: "📊", text: "Tableau de bord", page: "dashboard", shortcut: "Ctrl+D"},
                                {icon: "👤", text: "Profils", page: "profiles", shortcut: "Ctrl+P"},
                                {icon: "👥", text: "Clients", page: "clients", shortcut: "Ctrl+C"},
                                {icon: "⚔️", text: "Adversaires", page: "adversaires", shortcut: "Ctrl+A"},
                                {icon: "📄", text: "Pièces", page: "pieces", shortcut: "Ctrl+E"},
                                {icon: "🤖", text: "Assistant IA", page: "ia", shortcut: "Ctrl+I"},
                                {icon: "📚", text: "Base juridique", page: "base", shortcut: "F1"}
                            ]
                            
                            Button {
                                width: parent.width
                                height: 45
                                
                                background: Rectangle {
                                    color: window.currentPage === modelData.page ? "#2596be" : (parent.hovered ? "#2B2B2B" : "transparent")
                                    radius: 8
                                }
                                
                                contentItem: Row {
                                    spacing: 10
                                    leftPadding: 12
                                    
                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: modelData.text
                                        font.pixelSize: 13
                                        color: "#FFFFFF"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                onClicked: {
                                    window.currentPage = modelData.page
                                    switch(modelData.page) {
                                        case "dashboard": contentStack.replace(dashboardPage); break;
                                        case "profiles": contentStack.replace(profilesPage); break;
                                        case "clients": contentStack.replace(clientsPage); break;
                                        case "adversaires": contentStack.replace(adversairesPage); break;
                                        case "pieces": contentStack.replace(piecesPage); break;
                                        case "ia": contentStack.replace(iaPage); break;
                                        case "base": contentStack.replace(basePage); break;
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#3B3B3B"
                        }
                        
                        Button {
                            width: parent.width
                            height: 40
                            
                            background: Rectangle {
                                color: parent.hovered ? "#8B0000" : "#A52A2A"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: "🔒 Verrouiller"
                                font.pixelSize: 13
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                app.closeVault()
                                window.vaultOpen = false
                                window.currentPage = "login"
                                pageStack.replace(loginPage)
                            }
                        }
                    }
                }
                
                // Content Area
                StackView {
                    id: contentStack
                    width: parent.width - 220
                    height: parent.height
                    initialItem: dashboardPage
                    
                    replaceEnter: Transition {
                        PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                    }
                    replaceExit: Transition {
                        PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
                    }
                }
            }
        }
    }
    
    // Dashboard Page
    Component {
        id: dashboardPage
        Rectangle {
            color: "#0A0A0A"
            
            property int currentTab: 0
            
            Column {
                anchors.fill: parent
                spacing: 0
                
                // Header avec icône, titre et onglets
                Rectangle {
                    width: parent.width
                    height: 140
                    color: "#1E1E1E"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Titre et actions
                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "transparent"
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20
                                
                                // Icône et titre
                                Row {
                                    spacing: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Rectangle {
                                        width: 60
                                        height: 60
                                        radius: 12
                                        color: "#FFFFFF"
                                        
                                        Text {
                                            text: "📊"
                                            font.pixelSize: 32
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 5
                                        
                                        Text {
                                            text: "Tableau de bord"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: "#FFFFFF"
                                        }
                                        
                                        Text {
                                            text: "Vue d'ensemble et statistiques"
                                            font.pixelSize: 13
                                            color: "#888888"
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Onglets
                        Rectangle {
                            width: parent.width
                            height: 60
                            color: "transparent"
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 30
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5
                                
                                Repeater {
                                    model: ["Vue d'ensemble", "Statistiques", "Activité", "Performances", "Backups", "RGPD", "Licences"]
                                    
                                    Button {
                                        height: 45
                                        
                                        background: Rectangle {
                                            color: currentTab === index ? "#2596be" : (parent.hovered ? "#252525" : "transparent")
                                            radius: 8
                                        }
                                        
                                        contentItem: Text {
                                            text: modelData
                                            font.pixelSize: 13
                                            font.bold: currentTab === index
                                            color: "#FFFFFF"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 20
                                            rightPadding: 20
                                        }
                                        
                                        onClicked: currentTab = index
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Contenu selon l'onglet
                Rectangle {
                    id: dashboardContent
                    width: parent.width
                    height: parent.height - 140
                    color: "#0A0A0A"
                    
                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 30
                        contentHeight: contentColumn.height
                        clip: true
                        
                        Column {
                            id: contentColumn
                            width: parent.width
                            spacing: 25
                            
                            // Vue d'ensemble
                            Column {
                                visible: currentTab === 0
                                width: parent.width
                                spacing: 25
                                
                                // Stats principales
                                Grid {
                                    width: parent.width
                                    columns: 3
                                    spacing: 20
                                    
                                    Repeater {
                                        model: {
                                            var stats = app.getAppStats()
                                            return [
                                                {title: "Profils", value: stats.profiles, icon: "👤", color: "#FFFFFF", tooltip: "Nombre total de profils"},
                                                {title: "Clients", value: stats.clients, icon: "👥", color: "#FFFFFF", tooltip: "Nombre total de clients"},
                                                {title: "Dossiers", value: stats.dossiers, icon: "📁", color: "#FFFFFF", tooltip: "Nombre total de dossiers"},
                                                {title: "Adversaires", value: stats.adversaires, icon: "⚔️", color: "#FFFFFF", tooltip: "Nombre total d'adversaires"},
                                                {title: "Missions Std", value: stats.missions_std, icon: "📋", color: "#FFFFFF", tooltip: "Missions standard"},
                                                {title: "Missions Premium", value: stats.missions_prm, icon: "⭐", color: "#FFFFFF", tooltip: "Missions premium"}
                                            ]
                                        }
                                        
                                        Rectangle {
                                            width: (parent.width - 40) / 3
                                            height: 130
                                            color: "#1E1E1E"
                                            radius: 12
                                            border.color: "#3B3B3B"
                                            border.width: 1
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                
                                                onEntered: parent.border.color = modelData.color
                                                onExited: parent.border.color = "#3B3B3B"
                                                
                                                ToolTip {
                                                    visible: parent.containsMouse
                                                    text: modelData.tooltip
                                                    delay: 500
                                                }
                                            }
                                            
                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 12
                                                
                                                Text {
                                                    text: modelData.icon
                                                    font.pixelSize: 36
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                                
                                                Text {
                                                    text: modelData.value
                                                    font.pixelSize: 32
                                                    font.bold: true
                                                    color: modelData.color
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                                
                                                Text {
                                                    text: modelData.title
                                                    font.pixelSize: 13
                                                    color: "#888888"
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Row: Vault + Activité
                                Row {
                                    width: parent.width
                                    spacing: 20
                                    
                                    Rectangle {
                                        width: (parent.width - 20) / 2
                                        height: 220
                                        color: "#1E1E1E"
                                        radius: 12
                                        border.color: "#3B3B3B"
                                        border.width: 1
                                        
                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 25
                                            spacing: 20
                                            
                                            Row {
                                                spacing: 12
                                                Text { text: "💾"; font.pixelSize: 24 }
                                                Text { text: "Coffre-fort"; font.pixelSize: 20; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            Grid {
                                                width: parent.width
                                                columns: 2
                                                columnSpacing: 25
                                                rowSpacing: 18
                                                
                                                Column {
                                                    spacing: 6
                                                    Text { text: "Taille totale"; font.pixelSize: 11; color: "#888888" }
                                                    Text { text: app.getVaultSize(); font.pixelSize: 18; font.bold: true; color: "#FFFFFF" }
                                                }
                                                
                                                Column {
                                                    spacing: 6
                                                    Text { text: "Fichiers chiffrés"; font.pixelSize: 11; color: "#888888" }
                                                    Text { text: app.getVaultFilesCount(); font.pixelSize: 18; font.bold: true; color: "#FFFFFF" }
                                                }
                                                
                                                Column {
                                                    spacing: 6
                                                    Text { text: "Dernier backup"; font.pixelSize: 11; color: "#888888" }
                                                    Text { text: app.getLastBackupDate(); font.pixelSize: 18; font.bold: true; color: "#FFFFFF" }
                                                }
                                                
                                                Column {
                                                    spacing: 6
                                                    Text { text: "Activité (30j)"; font.pixelSize: 11; color: "#888888" }
                                                    Text { text: app.getAppStats().recent_activity || 0; font.pixelSize: 18; font.bold: true; color: "#FFFFFF" }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: (parent.width - 20) / 2
                                        height: 220
                                        color: "#1E1E1E"
                                        radius: 12
                                        border.color: "#3B3B3B"
                                        border.width: 1
                                        
                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 25
                                            spacing: 15
                                            
                                            Row {
                                                spacing: 12
                                                Text { text: "📝"; font.pixelSize: 24 }
                                                Text { text: "Activité récente"; font.pixelSize: 20; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            ListView {
                                                width: parent.width
                                                height: 140
                                                clip: true
                                                spacing: 8
                                                model: app.getRecentActivity(5)
                                                
                                                delegate: Row {
                                                    spacing: 12
                                                    width: parent.width
                                                    Text { text: modelData.icon || "•"; font.pixelSize: 16; color: "#FFFFFF" }
                                                    Text { 
                                                        text: {
                                                            if (modelData.timestamp) {
                                                                var date = new Date(modelData.timestamp)
                                                                return Qt.formatDateTime(date, "dd/MM hh:mm")
                                                            }
                                                            return ""
                                                        }
                                                        font.pixelSize: 11
                                                        color: "#666666"
                                                        width: 65
                                                    }
                                                    Text { text: modelData.action || ""; font.pixelSize: 13; color: "#FFFFFF"; width: 120; elide: Text.ElideRight }
                                                    Text { text: modelData.details || ""; font.pixelSize: 12; color: "#888888"; width: parent.width - 240; elide: Text.ElideRight }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Statistiques
                            Column {
                                visible: currentTab === 1
                                width: parent.width
                                spacing: 25
                                
                                Rectangle {
                                    width: parent.width
                                    height: 160
                                    color: "#1E1E1E"
                                    radius: 12
                                    border.color: "#3B3B3B"
                                    border.width: 1
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 25
                                        spacing: 20
                                        
                                        Row {
                                            spacing: 12
                                            Text { text: "📁"; font.pixelSize: 24 }
                                            Text { text: "Dossiers et Missions"; font.pixelSize: 20; font.bold: true; color: "#FFFFFF" }
                                        }
                                        
                                        Row {
                                            width: parent.width
                                            spacing: 50
                                            
                                            Column {
                                                spacing: 6
                                                Text { text: "Dossiers ouverts"; font.pixelSize: 11; color: "#888888" }
                                                Text { text: app.getAppStats().dossiers_ouverts || 0; font.pixelSize: 28; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            Column {
                                                spacing: 6
                                                Text { text: "Dossiers fermés"; font.pixelSize: 11; color: "#888888" }
                                                Text { text: app.getAppStats().dossiers_fermes || 0; font.pixelSize: 28; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            Column {
                                                spacing: 6
                                                Text { text: "Total dossiers"; font.pixelSize: 11; color: "#888888" }
                                                Text { text: app.getAppStats().dossiers || 0; font.pixelSize: 28; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            Rectangle { width: 1; height: 70; color: "#3B3B3B" }
                                            
                                            Column {
                                                spacing: 6
                                                Text { text: "Missions en cours"; font.pixelSize: 11; color: "#888888" }
                                                Text { text: app.getAppStats().missions_en_cours || 0; font.pixelSize: 28; font.bold: true; color: "#FFFFFF" }
                                            }
                                            
                                            Column {
                                                spacing: 6
                                                Text { text: "Missions terminées"; font.pixelSize: 11; color: "#888888" }
                                                Text { text: app.getAppStats().missions_terminees || 0; font.pixelSize: 28; font.bold: true; color: "#FFFFFF" }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Activité
                            Column {
                                visible: currentTab === 2
                                width: parent.width
                                spacing: 20
                                
                                Text {
                                    text: "Journal d'activité complet"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                                
                                Rectangle {
                                    width: parent.width
                                    height: 500
                                    color: "#1E1E1E"
                                    radius: 12
                                    border.color: "#3B3B3B"
                                    border.width: 1
                                    
                                    ListView {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        clip: true
                                        spacing: 10
                                        model: app.getRecentActivity(50)
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 35
                                            color: index % 2 === 0 ? "#252525" : "transparent"
                                            radius: 6
                                            
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 15
                                                
                                                Text { text: modelData.icon || "•"; font.pixelSize: 18; color: "#FFFFFF"; width: 25 }
                                                Text { 
                                                    text: {
                                                        if (modelData.timestamp) {
                                                            var date = new Date(modelData.timestamp)
                                                            return Qt.formatDateTime(date, "dd/MM/yyyy hh:mm:ss")
                                                        }
                                                        return ""
                                                    }
                                                    font.pixelSize: 11
                                                    font.family: "Courier"
                                                    color: "#666666"
                                                    width: 130
                                                }
                                                Text { text: modelData.action || ""; font.pixelSize: 13; color: "#FFFFFF"; width: 140; elide: Text.ElideRight }
                                                Text { text: modelData.details || ""; font.pixelSize: 12; color: "#888888"; width: parent.width - 450; elide: Text.ElideRight }
                                                Text { text: modelData.user || ""; font.pixelSize: 11; color: "#666666"; width: 100 }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Performances
                            Column {
                                visible: currentTab === 3
                                width: parent.width
                                spacing: 20
                                
                                Text {
                                    text: "Informations système et performances"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                                
                                // Info système
                                Rectangle {
                                    width: parent.width
                                    height: 600
                                    color: "#1E1E1E"
                                    radius: 12
                                    border.color: "#3B3B3B"
                                    border.width: 1
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 25
                                        spacing: 20
                                        
                                        Row {
                                            spacing: 12
                                            Text { text: "💻"; font.pixelSize: 24 }
                                            Text { text: "Configuration système"; font.pixelSize: 20; font.bold: true; color: "#FFFFFF" }
                                        }
                                        
                                        ScrollView {
                                            id: systemScrollView
                                            width: parent.width
                                            height: 520
                                            clip: true
                                            
                                            Flow {
                                                id: systemFlow
                                                width: systemScrollView.width - 20
                                                spacing: 20
                                                
                                                // OS
                                                Rectangle {
                                                    width: 380
                                                    height: 120
                                                    color: "#252525"
                                                    radius: 10
                                                    
                                                    Column {
                                                        anchors.fill: parent
                                                        anchors.margins: 15
                                                        spacing: 10
                                                        
                                                        Row {
                                                            spacing: 10
                                                            
                                                            Rectangle {
                                                                width: 45
                                                                height: 45
                                                                radius: 8
                                                                color: "#2596be"
                                                                Text { text: "🖥️"; font.pixelSize: 24; anchors.centerIn: parent }
                                                            }
                                                            
                                                            Column {
                                                                spacing: 3
                                                                
                                                                Text { text: "Système"; font.pixelSize: 10; color: "#888888" }
                                                                Text {
                                                                    property var sysInfo: app.getSystemInfo()
                                                                    text: (sysInfo.os ? sysInfo.os.system + " " + sysInfo.os.release : "N/A")
                                                                    font.pixelSize: 13
                                                                    font.bold: true
                                                                    color: "#FFFFFF"
                                                                }
                                                            }
                                                        }
                                                        
                                                        Text {
                                                            property var sysInfo: app.getSystemInfo()
                                                            text: (sysInfo.os ? sysInfo.os.version : "")
                                                            font.pixelSize: 9
                                                            color: "#666666"
                                                            wrapMode: Text.WordWrap
                                                            width: parent.width
                                                            maximumLineCount: 2
                                                            elide: Text.ElideRight
                                                        }
                                                    }
                                                }
                                                
                                                // CPU
                                                Rectangle {
                                                    width: 380
                                                    height: 120
                                                    color: "#252525"
                                                    radius: 10
                                                    
                                                    Column {
                                                        anchors.fill: parent
                                                        anchors.margins: 15
                                                        spacing: 10
                                                        
                                                        Row {
                                                            spacing: 10
                                                            
                                                            Rectangle {
                                                                width: 45
                                                                height: 45
                                                                radius: 8
                                                                color: "#2596be"
                                                                Text { text: "🧠"; font.pixelSize: 24; anchors.centerIn: parent }
                                                            }
                                                            
                                                            Column {
                                                                spacing: 3
                                                                
                                                                Text { text: "Processeur"; font.pixelSize: 10; color: "#888888" }
                                                                Text {
                                                                    property var sysInfo: app.getSystemInfo()
                                                                    text: (sysInfo.cpu ? sysInfo.cpu.name : "N/A")
                                                                    font.pixelSize: 13
                                                                    font.bold: true
                                                                    color: "#FFFFFF"
                                                                    wrapMode: Text.WordWrap
                                                                    width: 150
                                                                    maximumLineCount: 2
                                                                    elide: Text.ElideRight
                                                                }
                                                            }
                                                        }
                                                        
                                                        Text {
                                                            property var sysInfo: app.getSystemInfo()
                                                            text: (sysInfo.cpu ? sysInfo.cpu.physical_cores + " coeurs / " + sysInfo.cpu.logical_cores + " threads" : "")
                                                            font.pixelSize: 9
                                                            color: "#666666"
                                                        }
                                                    }
                                                }
                                                
                                                // RAM
                                                Rectangle {
                                                    width: 380
                                                    height: 120
                                                    color: "#252525"
                                                    radius: 10
                                                    
                                                    Column {
                                                        anchors.fill: parent
                                                        anchors.margins: 15
                                                        spacing: 10
                                                        
                                                        Row {
                                                            spacing: 10
                                                            
                                                            Rectangle {
                                                                width: 45
                                                                height: 45
                                                                radius: 8
                                                                color: "#2596be"
                                                                Text { text: "💾"; font.pixelSize: 24; anchors.centerIn: parent }
                                                            }
                                                            
                                                            Column {
                                                                spacing: 3
                                                                
                                                                Text { text: "Mémoire RAM"; font.pixelSize: 10; color: "#888888" }
                                                                Text {
                                                                    property var sysInfo: app.getSystemInfo()
                                                                    text: (sysInfo.ram ? sysInfo.ram.total : "N/A")
                                                                    font.pixelSize: 13
                                                                    font.bold: true
                                                                    color: "#FFFFFF"
                                                                }
                                                            }
                                                        }
                                                        
                                                        Text {
                                                            property var sysInfo: app.getSystemInfo()
                                                            text: (sysInfo.ram ? sysInfo.ram.type : "")
                                                            font.pixelSize: 9
                                                            color: "#666666"
                                                        }
                                                    }
                                                }
                                                
                                                // GPUs (iGPU + dédié)
                                                Repeater {
                                                    model: {
                                                        var sysInfo = app.getSystemInfo()
                                                        return sysInfo.gpus || []
                                                    }
                                                    
                                                    Rectangle {
                                                        width: 380
                                                        height: 120
                                                        color: "#252525"
                                                        radius: 10
                                                        
                                                        Column {
                                                            anchors.fill: parent
                                                            anchors.margins: 15
                                                            spacing: 10
                                                            
                                                            Row {
                                                                spacing: 10
                                                                
                                                                Rectangle {
                                                                    width: 45
                                                                    height: 45
                                                                    radius: 8
                                                                    color: "#2596be"
                                                                    Text { text: "⚙️"; font.pixelSize: 24; anchors.centerIn: parent }
                                                                }
                                                                
                                                                Column {
                                                                    spacing: 3
                                                                    
                                                                    Text { 
                                                                        text: {
                                                                            var sysInfo = app.getSystemInfo()
                                                                            var gpus = sysInfo.gpus || []
                                                                            return index === 0 ? "GPU Principal" : "GPU Secondaire"
                                                                        }
                                                                        font.pixelSize: 10
                                                                        color: "#888888"
                                                                    }
                                                                    Text {
                                                                        text: modelData.name || "Non détecté"
                                                                        font.pixelSize: 13
                                                                        font.bold: true
                                                                        color: "#FFFFFF"
                                                                        wrapMode: Text.WordWrap
                                                                        width: 260
                                                                        maximumLineCount: 2
                                                                        elide: Text.ElideRight
                                                                    }
                                                                }
                                                            }
                                                            
                                                            Text {
                                                                text: (modelData.driver ? "Driver: " + modelData.driver : "") + (modelData.memory && modelData.memory !== "N/A" ? " | VRAM: " + modelData.memory : "")
                                                                font.pixelSize: 9
                                                                color: "#666666"
                                                                elide: Text.ElideRight
                                                                width: parent.width
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // Python
                                                Rectangle {
                                                    width: 380
                                                    height: 120
                                                    color: "#252525"
                                                    radius: 10
                                                    
                                                    Column {
                                                        anchors.fill: parent
                                                        anchors.margins: 15
                                                        spacing: 10
                                                        
                                                        Row {
                                                            spacing: 10
                                                            
                                                            Rectangle {
                                                                width: 45
                                                                height: 45
                                                                radius: 8
                                                                color: "#2596be"
                                                                Text { text: "🐍"; font.pixelSize: 24; anchors.centerIn: parent }
                                                            }
                                                            
                                                            Column {
                                                                spacing: 3
                                                                
                                                                Text { text: "Python Runtime"; font.pixelSize: 10; color: "#888888" }
                                                                Text {
                                                                    property var sysInfo: app.getSystemInfo()
                                                                    text: (sysInfo.python ? sysInfo.python.implementation : "N/A")
                                                                    font.pixelSize: 13
                                                                    font.bold: true
                                                                    color: "#FFFFFF"
                                                                }
                                                            }
                                                        }
                                                        
                                                        Text {
                                                            property var sysInfo: app.getSystemInfo()
                                                            text: (sysInfo.python ? "Version " + sysInfo.python.version : "")
                                                            font.pixelSize: 9
                                                            color: "#666666"
                                                        }
                                                    }
                                                }
                                                
                                                // Disques
                                                Repeater {
                                                    model: {
                                                        var sysInfo = app.getSystemInfo()
                                                        return sysInfo.disks || []
                                                    }
                                                    
                                                    Rectangle {
                                                        width: 380
                                                        height: 120
                                                        color: "#252525"
                                                        radius: 10
                                                        
                                                        Column {
                                                            anchors.fill: parent
                                                            anchors.margins: 15
                                                            spacing: 10
                                                            
                                                            Row {
                                                                spacing: 10
                                                                
                                                                Rectangle {
                                                                    width: 45
                                                                    height: 45
                                                                    radius: 8
                                                                    color: "#2596be"
                                                                    Text { text: "💿"; font.pixelSize: 24; anchors.centerIn: parent }
                                                                }
                                                                
                                                                Column {
                                                                    spacing: 3
                                                                    
                                                                    Text { text: "Disque " + modelData.mountpoint; font.pixelSize: 10; color: "#888888"; elide: Text.ElideRight; width: 150 }
                                                                    Text {
                                                                        text: modelData.total || "N/A"
                                                                        font.pixelSize: 13
                                                                        font.bold: true
                                                                        color: "#FFFFFF"
                                                                    }
                                                                }
                                                            }
                                                            
                                                            Text {
                                                                text: (modelData.type || "HDD") + " - " + (modelData.free || "N/A") + " libre"
                                                                font.pixelSize: 9
                                                                color: "#666666"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Graphiques de performance en temps réel
                                Text {
                                    text: "📊 Monitoring en temps réel"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                                
                                Row {
                                    width: parent.width
                                    spacing: 20
                                    
                                    // Timer pour rafraîchir les données
                                    Timer {
                                        interval: 1000
                                        running: currentTab === 3
                                        repeat: true
                                        onTriggered: {
                                            // Force refresh des graphiques
                                            cpuChart.historyData = null
                                            ramChart.historyData = null
                                            gpuChart.historyData = null
                                            
                                            var history = app.getPerformanceHistory()
                                            if (history.length > 0) {
                                                cpuChart.historyData = history[0].cpu
                                                ramChart.historyData = history[0].ram
                                                gpuChart.historyData = history[0].gpu
                                            }
                                        }
                                    }
                                    
                                    // Graphique CPU
                                    PerformanceChart {
                                        id: cpuChart
                                        width: (parent.width - 40) / 3
                                        height: 200
                                        title: "CPU"
                                    }
                                    
                                    // Graphique RAM
                                    PerformanceChart {
                                        id: ramChart
                                        width: (parent.width - 40) / 3
                                        height: 200
                                        title: "RAM"
                                    }
                                    
                                    // Graphique GPU
                                    PerformanceChart {
                                        id: gpuChart
                                        width: (parent.width - 40) / 3
                                        height: 200
                                        title: "GPU"
                                    }
                                }
                            }
                                                
                            // Backups
                            Column {
                                visible: currentTab === 4
                                width: parent.width
                                spacing: 20
                                
                                Row {
                                    width: parent.width
                                    spacing: 20
                                    
                                    Text {
                                        text: "Sauvegardes disponibles"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                    
                                    Button {
                                        text: "➕ Nouvelle sauvegarde"
                                        height: 40
                                        
                                        background: Rectangle {
                                            color: parent.hovered ? "#1e7da0" : "#2596be"
                                            radius: 8
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#FFFFFF"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 15
                                            rightPadding: 15
                                        }
                                        
                                        onClicked: app.createBackup()
                                    }
                                }
                                
                                ListView {
                                    width: parent.width
                                    height: 400
                                    clip: true
                                    spacing: 10
                                    model: app.listBackups()
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 80
                                        color: "#1E1E1E"
                                        radius: 12
                                        border.color: "#3B3B3B"
                                        border.width: 1
                                        
                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 20
                                            spacing: 20
                                            
                                            Text {
                                                text: "💾"
                                                font.pixelSize: 32
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 5
                                                
                                                Text {
                                                    text: modelData.name || ""
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    color: "#FFFFFF"
                                                }
                                                
                                                Text {
                                                    text: new Date(modelData.date * 1000).toLocaleString()
                                                    font.pixelSize: 12
                                                    color: "#888888"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // RGPD
                            Column {
                                visible: currentTab === 5
                                width: parent.width
                                spacing: 25
                                
                                Text {
                                    text: "🔒 Conformité RGPD"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                                
                                // Résumé RGPD
                                Rectangle {
                                    width: parent.width
                                    height: 150
                                    color: "#1E1E1E"
                                    radius: 12
                                    border.color: "#3B3B3B"
                                    border.width: 1
                                    
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 30
                                        spacing: 40
                                        
                                        Column {
                                            spacing: 10
                                            
                                            Text {
                                                text: "🗄️ Données personnelles"
                                                font.pixelSize: 16
                                                color: "#888888"
                                            }
                                            
                                            Text {
                                                text: {
                                                    var stats = app.getAppStats()
                                                    return (stats.clients + stats.profiles + stats.adversaires) + " enregistrements"
                                                }
                                                font.pixelSize: 28
                                                font.bold: true
                                                color: "#FFFFFF"
                                            }
                                        }
                                        
                                        Column {
                                            spacing: 10
                                            
                                            Text {
                                                text: "🔐 Chiffrement"
                                                font.pixelSize: 16
                                                color: "#888888"
                                            }
                                            
                                            Text {
                                                text: "AES-256-GCM"
                                                font.pixelSize: 28
                                                font.bold: true
                                                color: "#FFFFFF"
                                            }
                                        }
                                        
                                        Column {
                                            spacing: 10
                                            
                                            Text {
                                                text: "📅 Dernier audit"
                                                font.pixelSize: 16
                                                color: "#888888"
                                            }
                                            
                                            Text {
                                                text: new Date().toLocaleDateString()
                                                font.pixelSize: 28
                                                font.bold: true
                                                color: "#FFFFFF"
                                            }
                                        }
                                    }
                                }
                                
                                // Principes RGPD
                                Grid {
                                    width: parent.width
                                    columns: 2
                                    spacing: 20
                                    
                                    Repeater {
                                        model: [
                                            {icon: "✅", title: "Licéité du traitement", desc: "Traitement des données avec consentement"},
                                            {icon: "🎯", title: "Limitation des finalités", desc: "Données collectées pour des fins spécifiques"},
                                            {icon: "📊", title: "Minimisation", desc: "Seules les données nécessaires sont collectées"},
                                            {icon: "✔️", title: "Exactitude", desc: "Données maintenues à jour et exactes"},
                                            {icon: "⏱️", title: "Conservation limitée", desc: "Données conservées le temps nécessaire"},
                                            {icon: "🔒", title: "Sécurité", desc: "Protection par chiffrement AES-256-GCM"}
                                        ]
                                        
                                        Rectangle {
                                            width: (parent.width - 20) / 2
                                            height: 120
                                            color: "#1E1E1E"
                                            radius: 12
                                            border.color: "#3B3B3B"
                                            border.width: 1
                                            
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 20
                                                spacing: 15
                                                
                                                Text {
                                                    text: modelData.icon
                                                    font.pixelSize: 32
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                
                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 8
                                                    width: parent.width - 60
                                                    
                                                    Text {
                                                        text: modelData.title
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                        color: "#FFFFFF"
                                                        wrapMode: Text.WordWrap
                                                        width: parent.width
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.desc
                                                        font.pixelSize: 12
                                                        color: "#888888"
                                                        wrapMode: Text.WordWrap
                                                        width: parent.width
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Actions RGPD
                                Row {
                                    width: parent.width
                                    spacing: 15
                                    
                                    Button {
                                        height: 50
                                        
                                        background: Rectangle {
                                            color: parent.hovered ? "#1e7da0" : "#2596be"
                                            radius: 8
                                        }
                                        
                                        contentItem: Text {
                                            text: "📄 Exporter mes données"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#FFFFFF"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 15
                                            rightPadding: 15
                                        }
                                        
                                        onClicked: console.log("Export RGPD")
                                    }
                                    
                                    Button {
                                        height: 50
                                        
                                        background: Rectangle {
                                            color: parent.hovered ? "#c0392b" : "#e74c3c"
                                            radius: 8
                                        }
                                        
                                        contentItem: Text {
                                            text: "🗑️ Supprimer toutes mes données"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#FFFFFF"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 15
                                            rightPadding: 15
                                        }
                                        
                                        onClicked: console.log("Suppression RGPD")
                                    }
                                }
                            }
                            
                            // Licences
                            Column {
                                visible: currentTab === 6
                                width: parent.width
                                spacing: 25
                                
                                Text {
                                    text: "🔑 Gestion des Licences"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                                
                                // Licence actuelle
                                Rectangle {
                                    width: parent.width
                                    height: 200
                                    color: "#1E1E1E"
                                    radius: 12
                                    border.color: "#3B3B3B"
                                    border.width: 1
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 30
                                        spacing: 20
                                        
                                        Row {
                                            width: parent.width
                                            spacing: 15
                                            
                                            Text {
                                                text: "📜"
                                                font.pixelSize: 48
                                            }
                                            
                                            Column {
                                                spacing: 8
                                                
                                                Text {
                                                    text: "Licence actuelle"
                                                    font.pixelSize: 14
                                                    color: "#888888"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        var info = app.getLicenseInfo()
                                                        return info.type.toUpperCase() || "NON ACTIVÉE"
                                                    }
                                                    font.pixelSize: 24
                                                    font.bold: true
                                                    color: "#FFFFFF"
                                                }
                                            }
                                        }
                                        
                                        Row {
                                            width: parent.width
                                            spacing: 40
                                            
                                            Column {
                                                spacing: 5
                                                
                                                Text {
                                                    text: "Expire le"
                                                    font.pixelSize: 12
                                                    color: "#888888"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        var info = app.getLicenseInfo()
                                                        return info.expiry_date || "N/A"
                                                    }
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: "#FFFFFF"
                                                }
                                            }
                                            
                                            Column {
                                                spacing: 5
                                                
                                                Text {
                                                    text: "Jours restants"
                                                    font.pixelSize: 12
                                                    color: "#888888"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        var info = app.getLicenseInfo()
                                                        return info.days_remaining !== undefined ? info.days_remaining.toString() : "0"
                                                    }
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: {
                                                        var info = app.getLicenseInfo()
                                                        if (info.days_remaining <= 0) return "#e74c3c"
                                                        return "#FFFFFF"
                                                    }
                                                }
                                            }
                                            
                                            Column {
                                                spacing: 5
                                                
                                                Text {
                                                    text: "Machine ID"
                                                    font.pixelSize: 12
                                                    color: "#888888"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        var info = app.getLicenseInfo()
                                                        return info.machine_id || "N/A"
                                                    }
                                                    font.pixelSize: 11
                                                    font.family: "Courier"
                                                    color: "#888888"
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Types de licences
                                Grid {
                                    width: parent.width
                                    columns: 2
                                    spacing: 20
                                    
                                    Repeater {
                                        model: [
                                            {type: "Trial", icon: "🆓", color: "#FFFFFF", features: ["15 jours", "Fonctions de base", "1 utilisateur"]},
                                            {type: "Standard", icon: "📋", color: "#FFFFFF", features: ["Toutes les fonctions", "Support par email", "3 utilisateurs"]},
                                            {type: "Premium", icon: "⭐", color: "#FFFFFF", features: ["Fonctions avancées", "Support prioritaire", "10 utilisateurs"]},
                                            {type: "Enterprise", icon: "🏢", color: "#FFFFFF", features: ["Toutes les fonctions", "Support 24/7", "Utilisateurs illimités"]}
                                        ]
                                        
                                        Rectangle {
                                            width: (parent.width - 20) / 2
                                            height: 180
                                            color: "#1E1E1E"
                                            radius: 12
                                            border.color: {
                                                var info = app.getLicenseInfo()
                                                return info.type.toLowerCase() === modelData.type.toLowerCase() ? modelData.color : "#3B3B3B"
                                            }
                                            border.width: {
                                                var info = app.getLicenseInfo()
                                                return info.type.toLowerCase() === modelData.type.toLowerCase() ? 2 : 1
                                            }
                                            
                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: 20
                                                spacing: 15
                                                
                                                Row {
                                                    spacing: 10
                                                    
                                                    Text {
                                                        text: modelData.icon
                                                        font.pixelSize: 32
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.type
                                                        font.pixelSize: 18
                                                        font.bold: true
                                                        color: modelData.color
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                                
                                                Column {
                                                    spacing: 8
                                                    
                                                    Repeater {
                                                        model: modelData.features
                                                        
                                                        Row {
                                                            spacing: 8
                                                            
                                                            Text {
                                                                text: "✓"
                                                                font.pixelSize: 12
                                                                color: "#FFFFFF"
                                                            }
                                                            
                                                            Text {
                                                                text: modelData
                                                                font.pixelSize: 12
                                                                color: "#888888"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Actions
                                Button {
                                    height: 50
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? "#1e7da0" : "#2596be"
                                        radius: 8
                                    }
                                    
                                    contentItem: Text {
                                        text: "🔑 Activer une licence"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 20
                                        rightPadding: 20
                                    }
                                    
                                    onClicked: console.log("Activation licence")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Profiles Page
    Component {
        id: profilesPage
        ProfilesPage {
        }
    }
    
    // Clients Page
    Component {
        id: clientsPage
        ClientsPage {
        }
    }
    
    // Adversaires Page
    Component {
        id: adversairesPage
        AdversairesPage {
        }
    }
    
    // Pièces Page
    Component {
        id: piecesPage
        PiecesPage {
        }
    }
    
    // IA Page
    Component {
        id: iaPage
        Rectangle {
            color: "#0A0A0A"
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "🤖 Assistant IA"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#FFFFFF"
                }
                
                Rectangle {
                    width: parent.width
                    height: 400
                    color: "#1E1E1E"
                    radius: 12
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        TextArea {
                            id: iaQuestion
                            width: parent.width
                            height: 100
                            placeholderText: "Posez votre question juridique..."
                            color: "#FFFFFF"
                            
                            background: Rectangle {
                                color: "#2B2B2B"
                                radius: 8
                                border.color: "#3B3B3B"
                            }
                        }
                        
                        Button {
                            text: "Envoyer"
                            width: 120
                            height: 40
                            
                            background: Rectangle {
                                color: parent.hovered ? "#1e7da0" : "#2596be"
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                iaResponse.text = app.askIA(iaQuestion.text)
                            }
                        }
                        
                        Text {
                            id: iaResponse
                            width: parent.width
                            wrapMode: Text.WordWrap
                            color: "#FFFFFF"
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
    
    // Base Page
    Component {
        id: basePage
        Rectangle {
            color: "#0A0A0A"
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "📚 Base Juridique"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#FFFFFF"
                }
                
                Text {
                    text: "Page Base Juridique - En développement"
                    font.pixelSize: 16
                    color: "#888888"
                }
            }
        }
    }
    
    // Loading Screen
    Rectangle {
        id: loadingScreen
        anchors.fill: parent
        color: "#1e1e1e"
        visible: false
        z: 999
        
        property int progress: 0
        property string message: ""
        
        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 300
            radius: 20
            color: "#2d2d2d"
            border.color: "#3d3d3d"
            border.width: 1
            
            Column {
                anchors.centerIn: parent
                spacing: 30
                width: parent.width - 80
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔐"
                    font.pixelSize: 64
                }
                
                Text {
                    id: loadingText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: loadingScreen.message
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.family: "Segoe UI"
                }
                
                Rectangle {
                    width: parent.width
                    height: 8
                    radius: 4
                    color: "#3d3d3d"
                    
                    Rectangle {
                        id: progressBar
                        width: parent.width * (loadingScreen.progress / 100)
                        height: parent.height
                        radius: 4
                        color: "#FFFFFF"
                        
                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: loadingScreen.progress + "%"
                    color: "#888888"
                    font.pixelSize: 14
                    font.family: "Segoe UI"
                }
            }
        }
        
        Connections {
            target: app
            function onLoadingProgress(prog, msg) {
                loadingScreen.progress = prog
                loadingScreen.message = msg
                
                if (prog >= 100) {
                    hideTimer.start()
                }
            }
        }
        
        Timer {
            id: hideTimer
            interval: 500
            onTriggered: {
                loadingScreen.visible = false
                loadingScreen.progress = 0
                loadingScreen.message = ""
            }
        }
        
        function show() {
            loadingScreen.visible = true
            loadingScreen.progress = 0
            loadingScreen.message = "Initialisation..."
        }
    }
}
