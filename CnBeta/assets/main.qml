/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import cn.anpho 1.0
import bb.system 1.2

NavigationPane {
    id: navroot
    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                var settingspage = Qt.createComponent("settings.qml").createObject(navroot);
                settingspage.nav = navroot;
                navroot.push(settingspage)
            }
        }
        helpAction: HelpActionItem {
            onTriggered: {
                var aboutpage = Qt.createComponent("about.qml").createObject(navroot);
                navroot.push(aboutpage)
            }
        }
    }
    Page {
        id: pageroot
        property int basetextsize: _app.getv("fontsize", "100")
        titleBar: TitleBar {
            // Localized text with the dynamic translation and locale updates support
            title: qsTr("CnBeta for BlackBerry 10") + Retranslate.onLocaleOrLanguageChanged
        }
        onCreationCompleted: {
            _app.returned.connect(appendData)
        }
        property bool loading: false
        function appendData(success, resp) {
            loading = false
            if (success) {
                var dobj = JSON.parse(resp);
                if (dobj.state == "success") {
                    var listitems = dobj.result.list;
                    console.log(listitems.length)
                    adm.append(listitems);
                } else {
                    errormsg(dobj.message)
                }
            } else {
                errormsg(resp)
            }
        }
        function errormsg(msg) {
            ssd.err = msg;
            ssd.show();
        }
        attachedObjects: [
            SystemToast {
                id: sst
            },
            Net {
                id: net
            },
            SystemDialog {
                id: ssd
                property string err
                title: qsTr("ERROR")
                body: qsTr("Error fetching data, Server response is [%1], please check your internet connection.").arg(err)
                includeRememberMe: false
                confirmButton.label: qsTr("Reload")
                cancelButton.label: qsTr("Cancel")
                customButton.label: qsTr("Exit App")
                customButton.enabled: true
                confirmButton.enabled: true
                cancelButton.enabled: true
                onFinished: {
                    switch (value) {
                        case SystemUiResult.ConfirmButtonSelection:
                            lv_main.resetData()
                            break;
                        case SystemUiResult.CustomButtonSelection:
                            Application.requestExit()
                            break;
                    }
                }
            }
        ]
        ListView {
            id: lv_main
            dataModel: ArrayDataModel {
                id: adm
            }
            property int page: 1
            property string endpoint: "http://www.cnbeta.com/home/more"

            function resetData() {
                adm.clear();
                pageroot.loading = false;
                page = 1;
                load()
            }
            function load() {
                if (pageroot.loading) {
                    return
                }

                var params = [ "type=all" ];
                params.push("page=" + page);
                var endp = endpoint + "?" + params.join("&");
                pageroot.loading = true;
                _app.get(endp);
            }
            scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
            leftPadding: 20.0
            rightPadding: 20.0
            bottomPadding: 50.0
            horizontalAlignment: HorizontalAlignment.Fill
            scrollRole: ScrollRole.Main
            onCreationCompleted: {
                resetData()
            }
            onTriggered: {
                var selected = adm.data(indexPath);
                var urltoopen = selected.url_show;
                var wbv = Qt.createComponent("viewer.qml").createObject(navroot);
                wbv.u = urltoopen;
                wbv.source_txt = selected.source
                wbv.page_description = selected.hometext.replace(/<.*?>/ig, "")
                wbv.page_title = selected.title.replace(/<.*?>/ig, "")
                wbv.pub_date = selected.inputtime
                navroot.push(wbv);
            }
            attachedObjects: [
                ListScrollStateHandler {
                    onScrollingChanged: {
                        if (scrolling && atEnd) {
                            lv_main.page ++;
                            lv_main.load()
                        }
                    }
                }
            ]
            property int font_size: pageroot.basetextsize
            listItemComponents: [
                ListItemComponent {
                    id: lcroot
                    Container {
                        id: croot
                        Label {
                            text: ListItemData.source
                            textStyle.fontSize: FontSize.XXSmall
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontStyle: FontStyle.Italic
                            textStyle.textAlign: TextAlign.Right
                            verticalAlignment: VerticalAlignment.Bottom
                            horizontalAlignment: HorizontalAlignment.Right

                        }
                        Divider {
                        }

                        Label {
                            text: ListItemData.title.replace(/<.*?>/ig, "")
                            multiline: true
                            textStyle.fontSize: FontSize.XLarge
                            textStyle.color: ui.palette.primary
                            verticalAlignment: VerticalAlignment.Top
                            horizontalAlignment: HorizontalAlignment.Fill
                        }

                        Label {
                            text: ListItemData.hometext.replace(/<.*?>/ig, "")
                            textFormat: TextFormat.Html
                            multiline: true
                            textStyle.fontSizeValue: croot.ListItem.view.font_size * 0.95
                            textStyle.fontSize: FontSize.PercentageValue
                            bottomMargin: 10.0
                            textStyle.textAlign: TextAlign.Justify
                        }
                    }
                }
            ]
        }
    }

    onPopTransitionEnded: {
        // Destroy the popped Page once the back transition has ended.
        page.destroy();
        pageroot.basetextsize = _app.getv("fontsize", "100");
    }
}
