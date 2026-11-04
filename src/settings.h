#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QString>
#include <QSettings>

/*
 * Tiny QSettings-backed key/value store exposed to QML as "Settings".
 * Used to persist custom breathing patterns and the last selection.
 */
class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString value(const QString &key, const QString &defaultValue = QString()) const {
        QSettings s;
        return s.value(key, defaultValue).toString();
    }

    Q_INVOKABLE void setValue(const QString &key, const QString &value) {
        QSettings s;
        s.setValue(key, value);
    }
};

#endif // SETTINGS_H
