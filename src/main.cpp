#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>
#include <QSoundEffect>
#include "settings.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-spiratio");
    app->setOrganizationName("harbour-spiratio");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("Settings", new Settings(app.data()));

    QSoundEffect *gong = new QSoundEffect(app.data());
    gong->setSource(SailfishApp::pathTo("sounds/gong1.wav"));
    view->rootContext()->setContextProperty("gong", gong);

    view->setSource(SailfishApp::pathTo("qml/harbour-spiratio.qml"));
    view->show();

    return app->exec();
}
