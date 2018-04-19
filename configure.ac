dnl
dnl  This is an example configure.ac that demonstrates how to use the buildsys.
dnl  You should not just copy it, but edit it to fit your needs!
dnl
dnl  To generate the configure script, call:
dnl    aclocal -I m4
dnl    autoconf
dnl

dnl Specify name, version and contact e-mail of the package.
AC_INIT(coregtkgen, 1.0)

dnl Specifies where your sources are.
AC_CONFIG_SRCDIR(src)
AC_CONFIG_AUX_DIR(build-aux)
AC_CONFIG_MACRO_DIR(build-aux/m4)

BUILDSYS_INIT

AC_CHECK_TOOL(OBJFW_CONFIG, objfw-config)
AS_IF([test x"$OBJFW_CONFIG" = x""], [
    AC_MSG_ERROR(You need ObjFW and objfw-config installed!)
])

test x"$OBJC" = x"" && OBJC="$($OBJFW_CONFIG --objc)"

AC_LANG([Objective C])
AC_PROG_OBJC
AC_PROG_OBJCPP
AC_PROG_INSTALL

CPP="$OBJC"
CPPFLAGS="$CPPFLAGS $OBJCPPFLAGS $($OBJFW_CONFIG --cppflags)"
OBJCFLAGS="$OBJCFLAGS -Wall $($OBJFW_CONFIG --objcflags)"
LDFLAGS="$LDFLAGS $($OBJFW_CONFIG --ldflags)"
LIBS="$LIBS $($OBJFW_CONFIG --libs)"

PKG_CHECK_MODULES(gtk3, [gtk+-3.0 >= 3.22], [
    CPPFLAGS="$CPPFLAGS $gtk3_CFLAGS"
    LIBS="$LIBS $gtk3_LIBS"
], [
    AC_MSG_ERROR(You need Gtk+ >= 3.22 installed!)
])

AC_SUBST(CPP)
AC_SUBST(CPPFLAGS)

AC_CONFIG_FILES(buildsys.mk)

AC_OUTPUT
