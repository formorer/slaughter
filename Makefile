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
VERSION     = 1.7
BASE        = slaughter


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


install: clean
	mkdir -p $(prefix)/usr/share/perl5/ || true
	cp lib/Slaughter.pm $(prefix)/usr/share/perl5/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter || true
	cp lib/Slaughter/*.pm  $(prefix)/usr/share/perl5/Slaughter/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter/API || true
	cp lib/Slaughter/API/*.pm  $(prefix)/usr/share/perl5/Slaughter/API/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter/Transport || true
	cp lib/Slaughter/Transport/*.pm  $(prefix)/usr/share/perl5/Slaughter/Transport/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter/Info || true
	cp lib/Slaughter/Info/*.pm  $(prefix)/usr/share/perl5/Slaughter/Info/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter/Packages/ || true
	cp lib/Slaughter/Packages/*.pm  $(prefix)/usr/share/perl5/Slaughter/Packages/
	mkdir $(prefix)/sbin/ || true
	cp ./bin/slaughter         $(prefix)/sbin/
	mkdir -p $(prefix)/etc/slaughter || true


uninstall:
	rm -f  $(prefix)/usr/share/perl5/Slaughter.pm
	rm -rf $(prefix)/usr/share/perl5/Slaughter/
	rm -f  $(prefix)/sbin/slaughter
	rm -rf $(prefix)/etc/slaughter


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


