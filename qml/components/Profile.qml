/*
    Copyright (C) 2020 Sebastian J. Wolf

    This file is part of Fernweh.

    Fernweh is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Fernweh is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fernweh. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "../pages"
import "../js/functions.js" as Functions

Item {

    id: profileItem
    height: parent.height
    width: parent.width
    visible: profileModel ? true : false
    opacity: profileModel ? 1 : 0
    Behavior on opacity { NumberAnimation {} }

    function scrollDown() {
        profileTimelineListView.flick(0, - parent.height);
    }
    function scrollUp() {
        profileTimelineListView.flick(0, parent.height);
    }
    function pageDown() {
        profileTimelineListView.flick(0, - parent.height * 2);
    }
    function pageUp() {
        profileTimelineListView.flick(0, parent.height * 2);
    }
    function scrollToTop() {
        profileTimelineListView.scrollToTop();
    }
    function scrollToBottom() {
        profileTimelineListView.scrollToBottom();
    }

    property variant profileModel;
    property variant profileTimeline;
    property bool loadingError : false;
    property string componentFontSize: ( flickrAccount.getFontSize() === "fernweh" ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall) ;
    property string iconFontSize: ( flickrAccount.getFontSize() === "fernweh" ? Theme.fontSizeSmall : Theme.fontSizeMedium) ;

    Component.onCompleted: {
        console.log("Profile component initialized for " + profileModel.person.id + ": " + profileModel.person.realname._content);
        //twitterApi.userTimeline(profileModel.screen_name);
    }

    onProfileModelChanged: {
        profileTimeline = null;
        twitterApi.userTimeline(profileModel.screen_name);
    }

    AppNotification {
        id: notification
    }

    Connections {
        target: flickrAccount
        onFontSizeChanged: {
            if (fontSize === "fernweh") {
                componentFontSize = Theme.fontSizeExtraSmall;
                iconFontSize = Theme.fontSizeSmall;
            } else {
                componentFontSize = Theme.fontSizeSmall;
                iconFontSize = Theme.fontSizeMedium;
            }
        }
    }

//    Connections {
//        target: twitterApi
//        onUserTimelineSuccessful: {
//            if (!profileTimeline) {
//                console.log("Timeline updated for user " + profileModel.screen_name)
//                profileTimeline = result;
//            }
//        }
//        onUserTimelineError: {
//            if (!profileTimeline) {
//                loadingError = true;
//                notification.show(errorMessage);
//            }
//        }
//    }

    Component {
        id: profileListHeaderComponent
        Column {
            id: profileElementsColumn

            height: profilePicturesRow.height + profileHeader.height + profileItemColumn.height + ( 2 * Theme.paddingMedium )
            width: parent.width
            spacing: Theme.paddingMedium

            ProfileHeader {
                id: profileHeader
                profileModel: profileItem.profileModel
                width: parent.width
            }

            Column {
                id: profileItemColumn
                width: parent.width
                spacing: Theme.paddingMedium

                Row {
                    id: profileDetailsRow
                    spacing: Theme.paddingMedium
                    width: parent.width - ( 2 * Theme.horizontalPageMargin )
                    visible: profileModel.person.description._content ? true : false
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id: profileDescriptionText
                        text: profileModel.person.description._content
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            pixelSize: componentFontSize
                            italic: true
                        }
                        color: Theme.primaryColor
                        wrapMode: Text.Wrap
                        width: parent.width
                        textFormat: Text.StyledText
                    }
                }

                Row {
                    id: profilePicturesRow
                    width: parent.width - ( 2 * Theme.horizontalPageMargin )
                    spacing: Theme.paddingMedium
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id: profilePicturesCountText
                        text: qsTr("%1 Photos").arg(Number(profileModel.person.photos.count._content).toLocaleString(Qt.locale(), "f", 0))
                        font.pixelSize: componentFontSize
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.primaryColor
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                }

                Row {
                    id: profileJoinedRow
                    spacing: Theme.paddingMedium
                    width: parent.width - ( 2 * Theme.horizontalPageMargin )
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id: profileJoinedText
                        text: qsTr("Joined in %1").arg(Functions.getDateFromTimestamp(profileModel.person.photos.firstdate._content).toLocaleDateString(Qt.locale(), "MMMM yyyy"))
                        font.pixelSize: componentFontSize
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.primaryColor
                        wrapMode: Text.NoWrap
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }


                Row {
                    id: profileLocationRow
                    spacing: Theme.paddingMedium
                    width: parent.width - ( 2 * Theme.horizontalPageMargin )
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        visible: profileModel.person.profileurl._content ? true : false
                        width: parent.width
                        spacing: Theme.paddingSmall
                        Image {
                            id: profileUrlImage
                            source: "image://theme/icon-m-link"
                            width: iconFontSize
                            height: iconFontSize
                        }
                        Text {
                            id: profileUrlText
                            text: profileModel.person.profileurl._content ? ("<a href=\"" + profileModel.person.profileurl._content + "\">" + profileModel.person.profileurl._content + "</a>") : ""
                            font.pixelSize: componentFontSize
                            color: Theme.primaryColor
                            wrapMode: Text.NoWrap
                            anchors.verticalCenter: parent.verticalCenter
                            onLinkActivated: Qt.openUrlExternally(profileModel.person.profileurl._content)
                            linkColor: Theme.highlightColor
                            elide: Text.ElideRight
                            width: parent.width - profileUrlImage.width - Theme.paddingSmall
                        }
                    }
                }

                Separator {
                    id: profileSeparator
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Qt.AlignHCenter
                }
            }

        }

    }


    Item {
        id: profileTimelineLoadingIndicator
        visible: profileTimeline || profileItem.loadingError ? false : true
        Behavior on opacity { NumberAnimation {} }
        opacity: profileTimeline ? 0 : 1

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            id: profileTimelineLoadingOverlay
            color: "black"
            opacity: 0.4
            width: parent.width
            height: parent.height
            visible: profileTimelineLoadingIndicator.visible
        }

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            running: profileTimelineLoadingIndicator.visible
            size: BusyIndicatorSize.Large
        }
    }

    SilicaListView {
        id: profileTimelineListView

        header: profileListHeaderComponent

        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        clip: true

        model: profileTimeline
//        delegate: Tweet {
//            tweetModel: modelData
//        }
        VerticalScrollDecorator {}
    }



}