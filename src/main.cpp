#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>
#include "settings.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-spiratio");
    app->setOrganizationName("harbour-spiratio");

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("Settings", new Settings(app.data()));
    // Path to the shipped gong sound (outside the qml folder), usable as Audio.source
    view->rootContext()->setContextProperty("gongSource", SailfishApp::pathTo("sounds/gong1.ogg"));
    view->setSource(SailfishApp::pathTo("qml/harbour-spiratio.qml"));
    view->show();

    return app->exec();
}
