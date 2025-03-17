pragma Singleton
import QtQuick

QtObject {
    function getForegroundColor() {
        return Application.styleHints.colorScheme === Qt.Dark ? "white" : "black"
    }

    readonly property color foregroundColor: getForegroundColor()
}
