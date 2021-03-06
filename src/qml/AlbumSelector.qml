import QtQuick 2.1
import MediaCenter 1.0

Item {
    id: albumSelector

    signal chooseCD()
    signal showFilterBar()
    property string absolutePath
    property string album
    property string artist
    property string title
    property int repeating: 0
    property string startsWithFilter

    onStartsWithFilterChanged: {
        var index = albumModel.indexForLetter(startsWithFilter)
        if (index >= 0) {
            gridView.currentIndex = index
        }
    }

    function load() {
        albumModel.closeIndex()
        albumModel.update()
    }

    Text {
        anchors.centerIn: parent
        visible: !gridView.count
        font.pointSize: settings.fontM
        style: Text.Outline
        color: "#fff"
        styleColor: "black"
        text: Backend.indexReady ? "Nenhuma mídia encontrada" : "Atualizando índice de mídias"
    }

    AlbumModel {
        id: albumModel
        genreFilters: Backend.genreFilters
        Component.onCompleted: {
            Backend.indexChanged.connect(load)
            update()
        }

    }

    GridView {
        id: gridView
        focus: true
        anchors.fill: parent
        anchors.leftMargin: (root.width % cellWidth) / 2
        interactive: false
        model: albumModel
        delegate: AlbumDelegate {
            height: GridView.view.cellHeight
            width: GridView.view.cellWidth
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gridView.currentIndex = index
                    showCover()
                }
            }
        }
        cellWidth: Backend.coverSize
        cellHeight: cellWidth * 1.5
        keyNavigationWraps: true
        preferredHighlightBegin: topBackground.height
        preferredHighlightEnd: height
        highlightRangeMode: GridView.StrictlyEnforceRange
        highlightMoveDuration: settings.animations ? 300 : 0
        cacheBuffer: 5000

        onCurrentItemChanged: {
            console.debug("album: " + currentItem.album);
            console.debug("artist: " + currentItem.artist);
            console.debug("absolutePath: " + currentItem.absolutePath);
            albumSelector.album = currentItem.album
            albumSelector.artist = currentItem.artist
            albumSelector.absolutePath = currentItem.absolutePath
        }
        onCountChanged: {
            if (count === 0) {
                albumSelector.album = ""
                albumSelector.artist = ""
                albumSelector.absolutePath = ""
            } else {
                currentIndex = 0
            }
        }
    }

    function countAutoRepeat(event) {
        if (event.isAutoRepeat) {
            if (repeating > 30) {
                showFilterBar()
            } else {
                ++repeating
            }
        } else {
            repeating = 0
        }
        event.accepted = true
    }

    Keys.onLeftPressed: {
        gridView.moveCurrentIndexLeft()
    }

    Keys.onRightPressed: {
        gridView.moveCurrentIndexRight()
    }

    Keys.onDownPressed: {
        gridView.moveCurrentIndexDown()
        countAutoRepeat(event)
    }

    Keys.onUpPressed: {
        gridView.moveCurrentIndexUp()
        countAutoRepeat(event)
    }

    function showCover() {
        if (gridView.currentItem) {
            chooseCD()
        }
    }

    Keys.onReturnPressed: {
        showCover()
        event.accepted = true
    }
    Keys.onEnterPressed: {
        showCover()
        event.accepted = true
    }
}
