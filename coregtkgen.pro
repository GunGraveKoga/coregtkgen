TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

INCLUDEPATH += "C:/msys64/mingw32/i686-w64-mingw32/include"
INCLUDEPATH += "C:/msys64/mingw32/include"
INCLUDEPATH += "C:/msys64/mingw32/include/gtk-3.0"
INCLUDEPATH += "C:/msys64/mingw32/include/cairo"
INCLUDEPATH += "C:/msys64/mingw32/include/pango-1.0"
INCLUDEPATH += "C:/msys64/mingw32/include/atk-1.0"
INCLUDEPATH += "C:/msys64/mingw32/include/pixman-1"
INCLUDEPATH += "C:/msys64/mingw32/include/freetype2"
INCLUDEPATH += "C:/msys64/mingw32/include/libpng16"
INCLUDEPATH += "C:/msys64/mingw32/include/harfbuzz"
INCLUDEPATH += "C:/msys64/mingw32/include/glib-2.0"
INCLUDEPATH += "C:/msys64/mingw32/lib/glib-2.0/include"
INCLUDEPATH += "C:/msys64/mingw32/include/harfbuzz"
INCLUDEPATH += "C:/msys64/mingw32/include/gdk-pixbuf-2.0"

INCLUDEPATH += $$PWD/src

DEFINES += gnu_printf=__printf__


LIBS += -lgtk-3 -lgdk-3 -lgdi32 -limm32 -lshell32 \
 -lole32 -lwinmm -ldwmapi -lsetupapi -lcfgmgr32 -lz \
 -lpangowin32-1.0 -lpangocairo-1.0 -lpango-1.0 -latk-1.0 \
 -lcairo-gobject -lcairo -lgdk_pixbuf-2.0 -lgio-2.0 -lgobject-2.0 \
 -lglib-2.0 -lintl

HEADERS += \ 
    src/Gir2Objc.h \
    src/Generator/CGTKClass.h \
    src/Generator/CGTKClassWriter.h \
    src/Generator/CGTKMethod.h \
    src/Generator/CGTKParameter.h \
    src/Generator/CGTKUtil.h \
    src/GIR/GIRApi.h \
    src/GIR/GIRArray.h \
    src/GIR/GIRBase.h \
    src/GIR/GIRClass.h \
    src/GIR/GIRConstant.h \
    src/GIR/GIRConstructor.h \
    src/GIR/GIRDoc.h \
    src/GIR/GIREnumeration.h \
    src/GIR/GIRField.h \
    src/GIR/GIRFunction.h \
    src/GIR/GIRImplements.h \
    src/GIR/GIRInterface.h \
    src/GIR/GIRMember.h \
    src/GIR/GIRMethod.h \
    src/GIR/GIRNamespace.h \
    src/GIR/GIRParameter.h \
    src/GIR/GIRPrerequisite.h \
    src/GIR/GIRProperty.h \
    src/GIR/GIRReturnValue.h \
    src/GIR/GIRType.h \
    src/GIR/GIRVarargs.h \
    src/GIR/GIRVirtualMethod.h \
    src/XMLReader/XMLReader.h

SOURCES += src/main.m \
  src/XMLReader/XMLReader.m \
  src/GIR/GIRApi.m \
  src/GIR/GIRArray.m \
  src/GIR/GIRBase.m \
  src/GIR/GIRClass.m \
  src/GIR/GIRConstant.m \
  src/GIR/GIRConstructor.m \
  src/GIR/GIRDoc.m \
  src/GIR/GIREnumeration.m \
  src/GIR/GIRField.m \
  src/GIR/GIRFunction.m \
  src/GIR/GIRImplements.m \
  src/GIR/GIRInterface.m \
  src/GIR/GIRParameter.m \
  src/GIR/GIRProperty.m \
  src/GIR/GIRMember.m \
  src/GIR/GIRMethod.m \
  src/GIR/GIRNamespace.m \
  src/GIR/GIRPrerequisite.m \
  src/GIR/GIRReturnValue.m \
  src/GIR/GIRType.m \
  src/GIR/GIRVarargs.m \
  src/GIR/GIRVirtualMethod.m \
  src/Generator/CGTKClassWriter.m \
  src/Generator/CGTKClass.m \
  src/Generator/CGTKMethod.m \
  src/Generator/CGTKParameter.m \
  src/Generator/CGTKUtil.m \
  src/Gir2Objc.m

DISTFILES += \
    src/Config/convert_type.map \
    src/Config/extra_imports.map \
    src/Config/extra_methods.map \
    src/Config/global_conf.map \
    src/Config/license.txt \
    src/Config/swap_types.map \
    src/BaseClasses/CGTK.h \
    src/BaseClasses/CGTKBase.h \
    src/BaseClasses/CGTKBaseBuilder.h \
    src/BaseClasses/CGTKCallbackData.h \
    src/BaseClasses/CGTKSignalConnector.h \
    src/BaseClasses/CGTKSignalData.h \
    src/BaseClasses/CGTKTypeWrapper.h \
    src/BaseClasses/CGTK.m \
    src/BaseClasses/CGTKBase.m \
    src/BaseClasses/CGTKBaseBuilder.m \
    src/BaseClasses/CGTKCallbackData.m \
    src/BaseClasses/CGTKSignalConnector.m \
    src/BaseClasses/CGTKSignalData.m \
    src/BaseClasses/CGTKTypeWrapper.m \
