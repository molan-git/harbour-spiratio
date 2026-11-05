#ifndef SOUNDPLAYER_H
#define SOUNDPLAYER_H

#include <QObject>
#include <QSoundEffect>

class SoundPlayer : public QObject {
    Q_OBJECT
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
    explicit SoundPlayer(QObject *parent = nullptr) : QObject(parent) {}

    qreal volume() const { return m_effect.volume(); }
    void setVolume(qreal v) { m_effect.setVolume(v); emit volumeChanged(); }

    Q_INVOKABLE void play(const QString &name) {
        m_effect.stop();
        m_effect.setSource(QUrl::fromLocalFile(
            "/usr/share/harbour-spiratio/sounds/" + name + ".wav"));
        m_effect.play();
    }

    Q_INVOKABLE void stop() { m_effect.stop(); }

signals:
    void volumeChanged();

private:
    QSoundEffect m_effect;
};

#endif
