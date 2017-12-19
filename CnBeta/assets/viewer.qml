import bb.cascades 1.4
import cn.anpho 1.0
Page {
    property string u
    onUChanged: {
        if (u.length > 0) {
            console.log("Loading " + u)
            netmgr.ajax("GET", u, [], function(b, d) {
                    if (b) {
                        page_description = textEx.getDescription(d);
                        var a = textEx.getContents(d);
                        imp.process(a);
                    }
                })
        }
    }
    id: pageroot
    property int basetextsize: _app.getv("fontsize", "100")
    property string page_title: ""
    property string page_description: ""
    property string page_content: ""
    property string pub_date: ""
    property string source_txt: ""
    attachedObjects: [
        Net {
            id: netmgr
        },
        QtObject {
            id: textEx
            property variant ex_desc: /meta.*?description.*?content=\"(.*?)\"/igm
            property variant ex_content: /<div.*?content[^>]*>([\s\S]*?)<\/div/gim

            property variant clearTags: /<(?!img|!br|!p).*?>/igm //remove all tags except img/br/p
            property variant extractParagraph2split: /<img[^>]*?>/igm

            function getDescription(htmltext) {
                var t = ex_desc.exec(htmltext);
                if (t.length > 1) {
                    return t[1];
                }
            }
            function getContents(htmltext) {
                var t = ex_content.exec(htmltext);
                if (t.length > 1) {
                    var d = t[1];
                    console.log(d);
                    return d;
                } else {
                    return "";
                }
            }

        },
        ComponentDefinition {
            id: para
            Label {
                multiline: true
                textStyle.textAlign: TextAlign.Left
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.fontSizeValue: pageroot.basetextsize
                textStyle.fontSize: FontSize.PercentageValue
                implicitLayoutAnimationsEnabled: false
            }
        },
        ComponentDefinition {
            id: graph
            WebImageView {
                id: wiv
                scalingMethod: ScalingMethod.AspectFit
                horizontalAlignment: HorizontalAlignment.Center
                implicitLayoutAnimationsEnabled: false
                gestureHandlers: TapHandler {
                    onTapped: {
                        _app.viewimage(wiv.getCachedPath())
                    }
                }
                imageSource: "asset:///image_placeholder.png"
            }
        },
        QtObject {
            id: imp
            function process(txt) {
                holder.removeAll();
                //TODO 图片显示不出来

                var removeP = txt.replace(/<p[^>]*?>/igm, "[param]");
                var removeIMG = removeP.replace(/<img.*?src.*?[\'\"]([^\'|^\"]*?)[\'|\"][^>]*?>/igm, function($0, $1, $2) {
                        console.log($1);
                        return "[img]" + $1 + "[param]"
                    })
                var clearALL = removeIMG.replace(/<[^>]*?>/igm, "");
                var paragraphs = clearALL.split("[param]");
                for (var i = 0; i < paragraphs.length; i ++) {
                    var cur = paragraphs[i];
                    if (cur.indexOf("[img]") > -1) {
                        //append image
                        cur = cur.replace("[img]", "");
                        var image2add = graph.createObject(pageroot);
                        image2add.url = cur;
                        holder.add(image2add)
                    } else if (cur.trim().length == 0) {
                        //bypass
                    } else {
                        var text2add = para.createObject(pageroot)
                        text2add.text = "　　" + cur;
                        holder.add(text2add)
                    }
                }
            }

        }
    ]

    actionBarVisibility: ChromeVisibility.Compact
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    ScrollView {
        Container {
            leftPadding: 20.0
            rightPadding: 20.0
            Header {
                title: pub_date
                subtitle: source_txt

            }
            Label {
                text: page_title
                textStyle.fontSize: FontSize.XLarge
                multiline: true
                textStyle.fontWeight: FontWeight.W100
                textStyle.textAlign: TextAlign.Center
                textFit.mode: LabelTextFitMode.Default
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.color: ui.palette.primaryDark
            }

            Label {
                text: "　　" + page_description
                multiline: true
                textStyle.fontSizeValue: pageroot.basetextsize * 0.95
                textStyle.fontSize: FontSize.PercentageValue
                opacity: 0.8
            }
            Divider {
                topMargin: 20.0
                bottomMargin: 20.0
            }
            Container {
                id: holder
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: qsTr("Loading ...")
                    textStyle.textAlign: TextAlign.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.fontWeight: FontWeight.W100

                }
            }
            Divider {
                opacity: 0.1
                topMargin: 150.0

            }
        }
    }
}
