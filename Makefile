

clean:
	@find . -name '*~' -delete
	@find . -name '*.bak' -delete
	@find . -name '*.tdy' -delete
	@find . -name '*.log' -delete
	@[ -d ./debian/slaughter-client ] && rm -rf ./debian/slaughter-client
	@ rm -f ./debian/files ./debian/*.substvars


tidy:
	perltidy ./bin/slaughter $$(find . -name '*.pm' -print)


install: clean
	mkdir -p $(prefix)/usr/share/perl5/ || true
	cp lib/Slaughter.pm $(prefix)/usr/share/perl5/
	mkdir -p $(prefix)/usr/share/perl5/Slaughter || true
	cp lib/Slaughter/*.pm  $(prefix)/usr/share/perl5/Slaughter/
	mkdir $(prefix)/sbin/ || true
	cp ./bin/slaughter $(prefix)/sbin/
	mkdir -p $(prefix)/etc/slaughter || true


uninstall:
	rm -f  $(prefix)/usr/share/perl5/Slaughter.pm
	rm -rf $(prefix)/usr/share/perl5/Slaughter/
	rm -f  $(prefix)/sbin/slaughter
	rm -rf $(prefix)/etc/slaughter
