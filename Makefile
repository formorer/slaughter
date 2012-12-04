#
#  Makefile for 'slaughter'.
#
# Steve
# --
#


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = ${TMP}
VERSION     = 2.0
BASE        = slaughter

#
#  Where we install the modules we provide, the binaries, and the config directory.
#
BIN_PREFIX  = /sbin
ETC_PREFIX  = /etc

#
#  We install to /usr/share/perl5 if it exists.  Otherwise to wherever
# the perl 'sitelib' value points.
#
#  NOTE: We deliberately avoided using "ifeq" - it isn't portable.
#
LIB_PREFIX=`test -d /usr/share/perl5 && echo /usr/share/perl5 || perl -MConfig -e 'print $$Config{'sitelib'}'`




clean:
	-find . -name '*~' -delete
	-find . -name '*.bak' -delete
	-find . -name '*.tdy' -delete
	-find . -name '*.log' -delete
	-rm -f ./debian/files ./debian/*.substvars
	-if [ -d ./debian/slaughter2-client ] ; then rm -rf ./debian/slaughter2-client; fi
	-if [ -d ./html ] ; then rm -rf ./html; fi
	-rm ./slaughter.1 || true


tidy:
	perltidy ./bin/slaughter $$(find . -name '*.pm' -print) || true


test-install:
	@echo "We'll install into: $(LIB_PREFIX)"


install: clean
	mkdir -p $(LIB_PREFIX) || true
	cp lib/Slaughter.pm ${LIB_PREFIX}/

	mkdir -p $(LIB_PREFIX)/Slaughter || true
	cp lib/Slaughter/*.pm ${LIB_PREFIX}/Slaughter/

	mkdir -p $(LIB_PREFIX)/Slaughter/API || true
	cp lib/Slaughter/API/*.pm ${LIB_PREFIX}/Slaughter/API/

	mkdir -p $(LIB_PREFIX)/Slaughter/Info || true
	cp lib/Slaughter/Info/*.pm ${LIB_PREFIX}/Slaughter/Info/

	mkdir -p $(LIB_PREFIX)/Slaughter/Transport || true
	cp lib/Slaughter/Transport/*.pm ${LIB_PREFIX}/Slaughter/Transport/

	mkdir -p $(LIB_PREFIX)/Slaughter/Packages || true
	cp lib/Slaughter/Packages/*.pm ${LIB_PREFIX}/Slaughter/Packages/

	mkdir -p $(BIN_PREFIX) || true
	cp ./bin/slaughter $(BIN_PREFIX)/

	mkdir -p $(ETC_PREFIX) || true


uninstall:
	rm -f  $(LIB_PREFIX)/Slaughter.pm
	rm -rf $(LIB_PREFIX)/Slaughter/
	rm -f  $(BIN_PREFIX)/slaughter
	rm -rf $(ETC_PREFIX)/slaughter


release: tidy clean pod
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/debian
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/skx
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/.hg*
	perl -pi -e "s/__UNRELEASED__/$(VERSION)/g" $(DIST_PREFIX)/$(BASE)-$(VERSION)/bin/slaughter
	cd $(DIST_PREFIX) && tar -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign $(BASE)-$(VERSION).tar.gz
	echo $(VERSION) > .version


test:
	prove --shuffle t/




#
#  Anything below here is only useful if you're working with the remote
# mercurial repository - because the ./skx/ directory is not bundled with
# the tarball releases.
#


pod:
	./skx/make-pod ./html


skx-test:
	[ -d skx/ ] && for i in skx/test-*; do $$i ; done


skx-sync-examples:
	[ -d skx/ ] && ./skx/sync-examples


