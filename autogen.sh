#!/bin/sh
aclocal -I build-aux/m4 || exit 1
autoconf -i || exit 1
