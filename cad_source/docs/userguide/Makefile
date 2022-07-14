.PHONY: pdf html all example getpdftheme
default: all

OSDETECT:=
ifeq ($(OS),Windows_NT)
	OSDETECT:=WIN32
else
	UNAME_S:=$(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSDETECT=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSDETECT:=OSX
	endif
endif
ASCIIDOCTOR_PDF_DIR:=$(shell gem contents asciidoctor-pdf --show-install-dir)
RULASTCOMMIT:=$(shell git log --pretty=tformat:\"%H\" -n1 locale/ru)
RUVERSION:=$(shell git describe --tags  $(RULASTCOMMIT))
PATHDELIM:=
ifeq ($(OSDETECT),WIN32)
	PATHDELIM =\\
else
	PATHDELIM =/
endif

version:
	@echo RULASTCOMMIT: $(RULASTCOMMIT)
	@echo RUVERSION: $(RUVERSION)
	@echo :gitversion: v$(RUVERSION) > locale/ru/gitversion.adoc

all: clean pdf html

styles/default-theme.yml:
	cp $(ASCIIDOCTOR_PDF_DIR)/data/themes/default-theme.yml styles/default-theme.yml

clean:                  
	rm -rf userguide.ru.html
	rm -rf userguide.ru.pdf
	rm -rf formats_examples.pdf
	rm -rf formats_examples.html
cad:
	mkdir cad
../images:
	mkdir $(subst /,$(PATHDELIM),../images)

copyimages: ../images
	cp -r ../../../environment/runtimefiles/common/images/* ../images

pdf: getpdftheme version copyimages
	asciidoctor-pdf -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram userguide.ru.adoc

html: version copyimages                      
	asciidoctor -a stylesheet=styles/stylesheet.css -r asciidoctor-diagram userguide.ru.adoc

example: version styles/default-theme.yml
	asciidoctor-pdf -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram formats_examples.adoc
	asciidoctor -a stylesheet=styles/stylesheet.css -r asciidoctor-diagram formats_examples.adoc

