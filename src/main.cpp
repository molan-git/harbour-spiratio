#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>
#include "settings.h"
#include "soundplayer.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-spiratio");
    app->setOrganizationName("harbour-spiratio");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("Settings", new Settings(app.data()));
    view->rootContext()->setContextProperty("soundPlayer", new SoundPlayer(app.data()));

    view->setSource(SailfishApp::pathTo("qml/harbour-spiratio.qml"));
    view->show();

    return app->exec();
}
