// Theme.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme
    
    readonly property color background: "#0A0A0A"
    readonly property color backgroundSecondary: "#1E1E1E"
    readonly property color backgroundTertiary: "#2B2B2B"
    
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#888888"
    readonly property color textTertiary: "#666666"
    
    readonly property color primary: "#2596be"
    readonly property color primaryHover: "#1e7da0"
    readonly property color primaryLight: "#3daad4"
    
    readonly property color success: "#27ae60"
    readonly property color warning: "#f39c12"
    readonly property color danger: "#e74c3c"
    readonly property color info: "#3498db"
    
    readonly property color buttonBackground: primary
    readonly property color buttonBackgroundHover: primaryHover
    readonly property color buttonText: textPrimary
    readonly property color buttonBorder: "#3B3B3B"
    readonly property int buttonRadius: 8
    readonly property int buttonHeight: 40
    
    readonly property color cardBackground: backgroundSecondary
    readonly property color cardBorder: "#3B3B3B"
    readonly property color cardBorderHover: primary
    readonly property int cardRadius: 12
    readonly property int cardBorderWidth: 1
    
    readonly property color inputBackground: backgroundTertiary
    readonly property color inputBorder: "#3B3B3B"
    readonly property color inputBorderFocus: primary
    readonly property color inputText: textPrimary
    readonly property color inputPlaceholder: textSecondary
    readonly property int inputRadius: 8
    readonly property int inputHeight: 40
    
    readonly property color switchBackground: "#3B3B3B"
    readonly property color switchBackgroundActive: primary
    readonly property color switchHandle: "#FFFFFF"
    readonly property int switchHeight: 24
    readonly property int switchWidth: 48
    
    readonly property int iconSizeSmall: 16
    readonly property int iconSizeMedium: 24
    readonly property int iconSizeLarge: 32
    readonly property int iconSizeXLarge: 48
    
    readonly property color scrollbarBackground: "transparent"
    readonly property color scrollbarHandle: "#3B3B3B"
    readonly property color scrollbarHandleHover: "#4B4B4B"
    readonly property int scrollbarWidth: 8
    
    readonly property color hoverOverlay: Qt.rgba(37, 150, 190, 0.1)
    readonly property real hoverOpacity: 0.8
    
    readonly property color shadowColor: Qt.rgba(0, 0, 0, 0.3)
    
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int spacingXLarge: 32
    
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeMedium: 13
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeXLarge: 20
    readonly property int fontSizeTitle: 24
    
    readonly property int transitionDuration: 200
}
