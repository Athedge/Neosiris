// PerformanceChart.qml
import QtQuick 2.15

Rectangle {
    id: root
    
    property string title: "Chart"
    property var historyData: []
    
    color: "#252525"
    radius: 8
    
    Timer {
        id: refreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            canvas.requestPaint()
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5
        
        // Titre
        Text {
            text: root.title
            font.pixelSize: 12
            font.bold: true
            color: "#FFFFFF"
        }
        
        // Légendes
        Row {
            spacing: 15
            
            Row {
                spacing: 5
                Rectangle { width: 12; height: 12; radius: 6; color: "#FFFFFF" }
                Text { text: "Système"; font.pixelSize: 9; color: "#888888" }
            }
            
            Row {
                spacing: 5
                Rectangle { width: 12; height: 12; radius: 6; color: "#2596be" }
                Text { text: "Application"; font.pixelSize: 9; color: "#888888" }
            }
        }
        
        // Canvas pour le graphique
        Canvas {
            id: canvas
            width: parent.width
            height: parent.height - 50
            
            Connections {
                target: root
                function onHistoryDataChanged() {
                    canvas.requestPaint()
                }
            }
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if (!root.historyData || root.historyData.length === 0) {
                    // Placeholder
                    ctx.fillStyle = "#666666"
                    ctx.font = "10px sans-serif"
                    ctx.fillText("En attente de données...", width/2 - 60, height/2)
                    return
                }
                
                var data = root.historyData
                var maxPoints = 60
                var pointWidth = width / maxPoints
                
                // Grille
                ctx.strokeStyle = "#3B3B3B"
                ctx.lineWidth = 1
                for (var i = 0; i <= 4; i++) {
                    var y = (height / 4) * i
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
                
                // Courbe Système (BLANC)
                if (data.length > 0) {
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    
                    for (var i = 0; i < data.length; i++) {
                        var x = i * pointWidth
                        var value = data[i].system || 0
                        var y = height - (value / 100) * height
                        
                        if (i === 0) {
                            ctx.moveTo(x, y)
                        } else {
                            ctx.lineTo(x, y)
                        }
                    }
                    ctx.stroke()
                    
                    // Courbe Application (BLEU)
                    ctx.strokeStyle = "#2596be"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    
                    for (var i = 0; i < data.length; i++) {
                        var x = i * pointWidth
                        var value = data[i].process || 0
                        var y = height - (value / 100) * height
                        
                        if (i === 0) {
                            ctx.moveTo(x, y)
                        } else {
                            ctx.lineTo(x, y)
                        }
                    }
                    ctx.stroke()
                }
                
                // Valeurs actuelles
                if (data.length > 0) {
                    var lastData = data[data.length - 1]
                    ctx.fillStyle = "#FFFFFF"
                    ctx.font = "bold 16px sans-serif"
                    ctx.fillText(Math.round(lastData.system || 0) + "%", 10, 25)
                    
                    ctx.fillStyle = "#2596be"
                    ctx.font = "10px sans-serif"
                    ctx.fillText("App: " + Math.round(lastData.process || 0) + "%", 10, 40)
                }
            }
        }
    }
}
