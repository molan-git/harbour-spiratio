#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QScopedPointer>
#include "settings.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    // ← no setApplicationName / setOrganizationName needed,
    //   SailfishApp already sets them from the .desktop file

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("Settings", new Settings(app.data()));

    view->setSource(SailfishApp::pathTo("qml/harbour-spiratio.qml"));
    view->show();

    return app->exec();
}
