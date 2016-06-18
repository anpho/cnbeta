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

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

using namespace bb::cascades;
using namespace bb::system;
ApplicationUI::ApplicationUI() :
        QObject()
{
    // prepare the localization
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);
    m_pInvokeManager = new InvokeManager(this);
    networkmgr = new QNetworkAccessManager();
    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this,
            SLOT(onSystemLanguageChanged()));
    // This is only available in Debug builds
    Q_ASSERT(res);
    // Since the variable is not used in the app, this is added to avoid a
    // compiler warning
    Q_UNUSED(res);

    // initial load
    onSystemLanguageChanged();

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("_app", this);
    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    Application::instance()->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("CnBeta_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

void ApplicationUI::get(const QString endpoint)
{
    QUrl edp(endpoint);
    QNetworkRequest req(edp);
    req.setRawHeader(QString("User-Agent").toLatin1(),
            QString(
                    "Mozilla/5.0 (Linux; U; Android 2.3; en-us; SAMSUNG-SGH-I717 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1").toLatin1());
    req.setRawHeader(QString("Referer").toLatin1(), QString("http://www.cnbeta.com").toLatin1());
    req.setRawHeader(QString("Accept-Language").toLatin1(),
            QString("zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4").toLatin1());

//    QHttpMultiPart *multipart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
//    QHttpPart contentPart;
//    contentPart.setHeader(QNetworkRequest::ContentDispositionHeader,
//            QVariant("form-data; name=json"));
//    contentPart.setHeader(QNetworkRequest::ContentTypeHeader,
//            QVariant("text/plain; charset=unicode"));
//    contentPart.setBody(content.toUtf8());
//    multipart->append(contentPart);

    reply = networkmgr->get(req);
//    multipart->setParent(reply);

    connect(reply, SIGNAL(finished()), this, SLOT(onArticleCreated()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this,
            SLOT(onErrorOcurred(QNetworkReply::NetworkError)));
}

void ApplicationUI::onArticleCreated()
{
    QString data = (QString) reply->readAll();
    qDebug() << data;
    if ((data.indexOf("article") > 0)) {
        emit returned(true, data);
    } else {
        emit returned(false, data);
    }
    disconnect(reply);
    reply->deleteLater();
}
void ApplicationUI::onErrorOcurred(QNetworkReply::NetworkError error)
{
    qDebug() << error;
    emit returned(false, QString(error));
}

QString ApplicationUI::getv(const QString &objectName, const QString &defaultValue)
{
    QSettings settings;
    if (settings.value(objectName).isNull()) {
        return defaultValue;
    }
    qDebug() << "[SETTINGS]" << objectName << " is " << settings.value(objectName).toString();
    return settings.value(objectName).toString();
}

void ApplicationUI::setv(const QString &objectName, const QString &inputValue)
{
    QSettings settings;
    settings.setValue(objectName, QVariant(inputValue));
    qDebug() << "[SETTINGS]" << objectName << " set to " << inputValue;
}

void ApplicationUI::viewimage(QString path)
{
    // invoke the system image viewer
    InvokeRequest request;
    // Set the URI
    request.setUri(path);
    request.setTarget("sys.pictures.card.previewer");
    request.setAction("bb.action.VIEW");
    // Send the invocation request
    InvokeTargetReply *cardreply = m_pInvokeManager->invoke(request);
    Q_UNUSED(cardreply);
}
