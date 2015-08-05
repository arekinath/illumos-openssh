#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at COPYING
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at COPYING.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
# Copyright (c) 2015, Joyent, Inc.
#

REPO =		arekinath/openssh-portable
NAME =		openssh-portable
TAG =		illumos-6.9p1-r1
URL =		https://github.com/$(REPO)/archive/$(TAG).tar.gz
SRCDIR =	$(NAME)-$(TAG)

BASE =		$(PWD)
DESTDIR =	$(BASE)/proto

ifeq ($(STRAP),strap)
STRAPPROTO =	$(DESTDIR)
else
STRAPPROTO =	$(DESTDIR:proto=proto.strap)
endif

PATH =		$(STRAPPROTO)/usr/bin:/usr/bin:/usr/sbin:/sbin:/opt/local/bin

CFLAGS +=	-I$(DESTDIR)/usr/include -I$(STRAPPROTO)/usr/include -L$(DESTDIR)/usr/lib
CFLAGS +=	-DSET_USE_PAM -DDEPRECATE_SUNSSH_OPT -DKRB5_BUILD_FIX
CFLAGS +=	-DDTRACE_SFTP -DDISABLE_BANNER -DPAM_ENHANCEMENT
CFLAGS +=	-DPAM_BUGFIX -DOPTION_DEFAULT_VALUE -DHAVE_EVP_SHA256
LDFLAGS +=	-L$(DESTDIR)/usr/lib
LDFLAGS +=	-B direct -z nolazyload
LDFLAGS +=	-Wl,-zassert-deflib -Wl,-zfatal-warnings
export CFLAGS
export LDFLAGS

MAKE =		gmake
GCC =		$(DESTDIR)/usr/bin/gcc
GXX =		$(DESTDIR)/usr/bin/g++
CC =		$(GCC)
CXX =		$(GXX)
export CC
export CXX
export GCC
export GXX

GPATCH =	/opt/local/bin/gpatch

CONFARGS =	--libexecdir=/usr/lib/ssh --sbindir=/usr/lib/ssh --sysconfdir=/etc/ssh --bindir=/usr/bin
CONFARGS +=	--with-audit=solaris --with-kerberos5 --with-pam --with-sandbox=no
CONFARGS +=	--with-solaris-contracts --with-tcp-wrappers --with-4in6 --with-xauth=/usr/bin/xauth
CONFARGS +=	--enable-strip=no --without-rpath --disable-lastlog --with-privsep-user=daemon
CONFARGS +=	--without-openssl-header-check

world:		configure
	cd $(SRCDIR) && $(MAKE)

configure:	autoconf
	cd $(SRCDIR) && ./configure $(CONFARGS)

autoconf:	patch
	cd $(SRCDIR) && autoreconf -fi

patch:		$(SRCDIR)
	cd $(SRCDIR) && $(GPATCH) -p1 < ../sunw_ssl.patch && $(GPATCH) -p1 < ../dtrace32.patch

$(SRCDIR):
	curl -LO $(URL) && gtar -zxf $(TAG).tar.gz

install:
	cd $(SRCDIR) && $(MAKE) install

clean:
	rm -fr $(SRCDIR) $(TAG).tar.gz
