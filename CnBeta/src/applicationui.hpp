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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <QNetworkReply>

#include <bb/system/InvokeManager>
#include <bb/cascades/InvokeQuery>
#include <bb/cascades/Invocation>
namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI();
    Q_INVOKABLE void get(const QString endpoint);
    Q_SIGNAL void returned(bool success,QString resp);
    Q_INVOKABLE static void setv(const QString &objectName, const QString &inputValue);
    Q_INVOKABLE static QString getv(const QString &objectName, const QString &defaultValue);
    Q_INVOKABLE void viewimage(QString path);
    virtual ~ApplicationUI() {};

private slots:
    void onArticleCreated();
    void onErrorOcurred(QNetworkReply::NetworkError error);
    void onSystemLanguageChanged();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    QNetworkReply *reply;
    QNetworkAccessManager *networkmgr;
    bb::system::InvokeManager* m_pInvokeManager;
};

#endif /* ApplicationUI_HPP_ */
