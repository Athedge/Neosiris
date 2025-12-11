import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: dialog
    modal: true
    focus: true
    width: 520
    height: 600
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var profileData: ({})
    signal saved(var profile)

    background: Rectangle {
        radius: 12
        color: "#1E1E1E"
        border.color: "#3B3B3B"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Titre
        Text {
            text: profileData && profileData.id ? "Modifier le profil" : "Nouveau profil"
            font.pixelSize: 22
            font.bold: true
            color: "#FFFFFF"
        }

        // Image / crop
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 260
            radius: 10
            color: "#151515"
            border.color: "#3B3B3B"

            ImageCropper {
                id: cropper
                anchors.fill: parent
                circularMask: true
                imagePath: profileData && profileData.photo ? profileData.photo : ""
            }
        }

        // Champs texte
        TextField {
            id: firstnameField
            Layout.fillWidth: true
            placeholderText: "Prénom"
            text: profileData && profileData.firstname ? profileData.firstname : ""
        }

        TextField {
            id: lastnameField
            Layout.fillWidth: true
            placeholderText: "Nom"
            text: profileData && profileData.lastname ? profileData.lastname : ""
        }

        TextField {
            id: emailField
            Layout.fillWidth: true
            placeholderText: "Email"
            text: profileData && profileData.email ? profileData.email : ""
        }

        TextArea {
            id: notesField
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            placeholderText: "Notes / consignes IA"
            wrapMode: Text.WordWrap
            text: profileData && profileData.notes ? profileData.notes : ""
        }

        // Boutons bas
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Button {
                text: "Annuler"
                Layout.fillWidth: true
                onClicked: dialog.close()
            }

            Button {
                text: "Sauvegarder"
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.hovered ? "#1e7da0" : "#2596be"
                    radius: 8
                }

                onClicked: {
                    var updated = {
                        id: profileData && profileData.id ? profileData.id : Date.now(),
                        firstname: firstnameField.text,
                        lastname: lastnameField.text,
                        email: emailField.text,
                        notes: notesField.text,
                        photo: profileData && profileData.photo ? profileData.photo : ""
                    }

                    dialog.saved(updated)
                    dialog.close()
                }
            }
        }
    }
}
