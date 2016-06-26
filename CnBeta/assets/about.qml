import bb.cascades 1.4

Page {
    titleBar: TitleBar {
        title: qsTr("ABOUT")

    }
    ScrollView {
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            leftPadding: 20.0
            rightPadding: 20.0
            Header {
                title: qsTr("APP")
            }
            Label {
                multiline: true
                text: qsTr("This is an app client for cnbeta.com, but I'm not related to cnbeta.com. Enjoy!")
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontSize: FontSize.Medium
                textStyle.fontWeight: FontWeight.W100
                textStyle.textAlign: TextAlign.Center
            }
            Header {
                title: qsTr("DEVELOPED BY")
            }
            Label {
                multiline: true
                text: qsTr("Merrick Zhang ( anphorea@gmail.com )")
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontSize: FontSize.Medium
                textStyle.fontWeight: FontWeight.W100
            }
            Header {
                title: qsTr("KNOWN BUGS")
            }
            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Left
                textStyle.fontSize: FontSize.Small
                text: qsTr("1.   Videos are not supported.")
                textStyle.fontWeight: FontWeight.W100
            }
            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Left
                textStyle.fontSize: FontSize.Small
                text: qsTr("2.   Raw text process may produces bad paragraphs.")
                textStyle.fontWeight: FontWeight.W100
            }
            Label {
                multiline: true
                horizontalAlignment: HorizontalAlignment.Left
                textStyle.fontSize: FontSize.Small
                text: qsTr("3.   No HTML Link.")
                textStyle.fontWeight: FontWeight.W100
            }
            Label {
                multiline: true
                text: qsTr("ALL CONTENT RIGHTS RESERVED BY CNBETA.COM")
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontSize: FontSize.XXSmall
                textStyle.fontWeight: FontWeight.W100
            }
        }
    }
}
