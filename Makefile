# -*- coding: us-ascii-unix -*-

NAME       = harbour-pan-bikes
VERSION    = 1.2.2
RELEASE    = $(NAME)-$(VERSION)
DESTDIR    =
PREFIX     = /usr
DATADIR    = $(DESTDIR)$(PREFIX)/share/$(NAME)
DESKTOPDIR = $(DESTDIR)$(PREFIX)/share/applications
ICONDIR    = $(DESTDIR)$(PREFIX)/share/icons/hicolor
LANGS      = $(basename $(notdir $(wildcard po/*.po)))
LCONVERT   = $(or $(wildcard /usr/lib/qt5/bin/lconvert),\
                  $(wildcard /usr/lib/*/qt5/bin/lconvert))

define install-translation =
    # GNU gettext translations for Python use.
    mkdir -p $(DATADIR)/locale/$(1)/LC_MESSAGES
    msgfmt po/$(1).po -o $(DATADIR)/locale/$(1)/LC_MESSAGES/pan-bikes.mo
    # Qt linguist translations for QML use.
    mkdir -p $(DATADIR)/translations
    $(LCONVERT) -o $(DATADIR)/translations/$(NAME)-$(1).qm po/$(1).po
endef

check:
	pyflakes pan providers

clean:
	rm -rf dist
	rm -rf .cache
	rm -rf */.cache
	rm -rf */*/.cache
	rm -rf */__pycache__
	rm -rf */*/__pycache__
	rm -f po/*~
	rm -f rpm/*.rpm

dist:
	$(MAKE) clean
	mkdir -p dist/$(RELEASE)
	cp -r `cat MANIFEST` dist/$(RELEASE)
	tar -C dist -cJf dist/$(RELEASE).tar.xz $(RELEASE)

install:
	@echo "Installing Python files..."
	mkdir -p $(DATADIR)/pan
	cp pan/*.py $(DATADIR)/pan
	@echo "Installing QML files..."
	mkdir -p $(DATADIR)/qml/icons
	cp qml/pan-bikes.qml $(DATADIR)/qml/$(NAME).qml
	cp qml/[ABCDEFGHIJKLMNOPQRSTUVXYZ]*.qml $(DATADIR)/qml
	cp qml/icons/*.png $(DATADIR)/qml/icons
	@echo "Installing providers..."
	mkdir -p $(DATADIR)/providers
	cp providers/*.json $(DATADIR)/providers
	cp providers/[!_]*.py $(DATADIR)/providers
	cp providers/*.qml $(DATADIR)/providers
	cp providers/README.md $(DATADIR)/providers
	@echo "Installing translations..."
	$(foreach lang,$(LANGS),$(call install-translation,$(lang)))
	@echo "Installing desktop file..."
	mkdir -p $(DESKTOPDIR)
	cp data/$(NAME).desktop $(DESKTOPDIR)
	@echo "Installing icons..."
	mkdir -p $(ICONDIR)/86x86/apps
	mkdir -p $(ICONDIR)/108x108/apps
	mkdir -p $(ICONDIR)/128x128/apps
	mkdir -p $(ICONDIR)/256x256/apps
	cp data/pan-bikes-86.png  $(ICONDIR)/86x86/apps/$(NAME).png
	cp data/pan-bikes-108.png $(ICONDIR)/108x108/apps/$(NAME).png
	cp data/pan-bikes-128.png $(ICONDIR)/128x128/apps/$(NAME).png
	cp data/pan-bikes-256.png $(ICONDIR)/256x256/apps/$(NAME).png

pot:
	tools/update-translations

rpm:
	$(MAKE) dist
	mkdir -p $$HOME/rpmbuild/SOURCES
	cp dist/$(RELEASE).tar.xz $$HOME/rpmbuild/SOURCES
	rm -rf $$HOME/rpmbuild/BUILD/$(RELEASE)
	rpmbuild -ba --nodeps rpm/$(NAME).spec
	cp $$HOME/rpmbuild/RPMS/noarch/$(RELEASE)-*.rpm rpm
	cp $$HOME/rpmbuild/SRPMS/$(RELEASE)-*.rpm rpm

test:
	py.test pan providers

.PHONY: check clean dist install pot rpm test
