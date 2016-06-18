import bb.cascades 1.4
import bb.system 1.2

Page {
    property NavigationPane nav
    /*
     * Refer main.cpp to see how to apply this on app boot up.
     */
    property string themestring: "%1?primaryColor=0x%2&amp;primaryBase=0x%3"
    function savetheme() {
        var primarycolor = Color.toHexString(Application.themeSupport.theme.colorTheme.primary).substring(3, 9)
        var primarybase = Color.toHexString(Application.themeSupport.theme.colorTheme.primaryBase).substring(3, 9)
        var style = Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "dark" : "bright"
        var theme = themestring.arg(style).arg(primarycolor).arg(primarybase)
        _app.setv("theme", theme)
    }
    onCreationCompleted: {
        /*
         * it needs some time for themeSupport to apply, so just connect to the signal in order to save the latest color schemes.
         * here I dismissed the argument of this signal ( not registered in Cascades )
         */
        Application.themeSupport.themeChanged.connect(savetheme)
    }
    attachedObjects: [
        SystemToast {
            id: sst
            position: SystemUiPosition.BottomCenter

        }
    ]
    titleBar: TitleBar {
        title: qsTr("SETTINGS")
        dismissAction: ActionItem {
            title: qsTr("CLOSE")
            onTriggered: {
                nav.pop();
            }
        }
    }
    ScrollView {
        Container {
            Header {
                title: qsTr("UI SETTINGS")
            }
            Container {
                topPadding: 20.0
                leftPadding: 20.0
                rightPadding: 20.0
                bottomPadding: 20.0
                Label {
                    text: qsTr("Visual Theme")
                    bottomMargin: 20.0
                    textStyle.fontWeight: FontWeight.W100
                    textStyle.fontSize: FontSize.Large
                }
                Label {
                    text: qsTr("Choose your theme below, Dark theme is better for OLED devices.")
                    multiline: true
                    textStyle.fontWeight: FontWeight.W100
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }

                    Label {
                        text: qsTr("App Theme:")
                        implicitLayoutAnimationsEnabled: false
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        verticalAlignment: VerticalAlignment.Center
                    }
                    SegmentedControl {
                        options: [
                            Option {
                                text: qsTr("BRIGHT")
                                value: VisualStyle.Bright
                                selected: VisualStyle.Bright == Application.themeSupport.theme.colorTheme.style
                                description: "bright"

                            },
                            Option {
                                text: qsTr("DARK")
                                value: VisualStyle.Dark
                                selected: VisualStyle.Dark == Application.themeSupport.theme.colorTheme.style
                                description: "dark"
                            }
                        ]
                        onSelectedOptionChanged: {
                            Application.themeSupport.setVisualStyle(selectedOption.value)
                        }
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Right
                        implicitLayoutAnimationsEnabled: false
                        preferredWidth: 1.0
                    }

                }

            }
            Container {
                topPadding: 20.0
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 20.0
                Label {
                    text: qsTr("Theme Color:")
                }
                ListView {
                    preferredHeight: ui.du(12)
                    dataModel: XmlDataModel {
                        id: xdm
                        source: "asset:///colors.xml"
                    }
                    leftPadding: 20.0
                    rightPadding: 20.0
                    topPadding: 20.0
                    bottomPadding: 20.0
                    layout: StackListLayout {
                        orientation: LayoutOrientation.LeftToRight
                        headerMode: ListHeaderMode.None

                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            Container {
                                preferredHeight: ui.du(8)
                                preferredWidth: ui.du(8)
                                background: Color.create(ListItemData.color)
                                topMargin: ui.du(1.0)
                                leftMargin: ui.du(1.0)
                                rightMargin: ui.du(1.0)
                                bottomMargin: ui.du(1.0)
                            }
                        }
                    ]
                    onTriggered: {
                        var _color = xdm.data(indexPath).color
                        Application.themeSupport.setPrimaryColor(Color.create(_color))
                        Application.themeSupport.setPrimaryColor(Color.create(_color))
                    }
                    implicitLayoutAnimationsEnabled: false
                    scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                    bufferedScrollingEnabled: true
                }
            }
            Header {
                title: qsTr("FONT SIZE")
            }
            Container {
                leftPadding: 20.0
                rightPadding: 20.0
                topPadding: 20
                bottomPadding: 20.0
                Label {
                    multiline: true
                    text: qsTr("Adjust the font size of display text.")
                    textStyle.fontWeight: FontWeight.W100
                }
                Label {
                    multiline: true
                    text: qsTr("If you want to adjust the overall text size of this app, please use System Settings / Display Settings / Font Size.")
                    textStyle.fontWeight: FontWeight.W100
                }
            }
            Container {
                leftPadding: 20.0
                
                rightPadding: 20.0
                topPadding: 20.0
                bottomPadding: 20.0
                Container {
                    background: ui.palette.plainBase
                    topPadding: 20.0
                    leftPadding: 20.0
                    bottomPadding: 20.0
                    rightPadding: 20.0
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: "信任这种东西有时候挺奇怪的，就是那种你在我背后开了一枪，我依然觉得是枪走了火的感觉。by 暖小团"
                        multiline: true
                        textFormat: TextFormat.Plain
                        textStyle.fontSize: FontSize.PercentageValue
                        textStyle.fontSizeValue: textslider.value
                        horizontalAlignment: HorizontalAlignment.Fill
                        textFit.mode: LabelTextFitMode.FitToBounds
                        textStyle.textAlign: TextAlign.Center
                        textStyle.color: ui.palette.primary
                    }
                }
                Slider {
                    horizontalAlignment: HorizontalAlignment.Center
                    fromValue: 80
                    toValue: 200
                    value: _app.getv("fontsize", "100")
                    id: textslider
                    onValueChanged: {
                        _app.setv("fontsize", Math.round(value))
                    }
                }
                Button {
                    horizontalAlignment: HorizontalAlignment.Center
                    text: qsTr("DEFAULT")
                    appearance: ControlAppearance.Default
                    onClicked: {
                        textslider.value = 100;
                    }
                }
            }
        }
    }
}
