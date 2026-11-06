#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QString>
#include <QSettings>
#include <QStandardPaths>
#include <QCoreApplication>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = nullptr) : QObject(parent) {
        QString path = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)
                       + "/" + QCoreApplication::applicationName() + ".conf";
        m_settings = new QSettings(path, QSettings::NativeFormat, this);
    }

    Q_INVOKABLE QString value(const QString &key, const QString &defaultValue = QString()) const {
        return m_settings->value(key, defaultValue).toString();
    }

    Q_INVOKABLE void setValue(const QString &key, const QString &value) {
        m_settings->setValue(key, value);
        m_settings->sync();
    }

private:
    QSettings *m_settings;
};

#endif // SETTINGS_H
