.PHONY: pdf html all example getpdftheme
default: all

ASCIIDOCTOR_PDF_DIR:=$(shell gem contents asciidoctor-pdf --show-install-dir)

all: clean pdf html

getpdftheme:
	cp $(ASCIIDOCTOR_PDF_DIR)/data/themes/default-theme.yml styles/default-theme.yml

clean:                  
	rm -rf userguide.ru.html
	rm -rf userguide.ru.pdf
	rm -rf formats_examples.pdf
	rm -rf formats_examples.html
pdf: getpdftheme
	asciidoctor-pdf.bat -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram userguide.ru.adoc

html:                      
	asciidoctor.bat -a stylesheet=styles/stylesheet.css -r asciidoctor-diagram userguide.ru.adoc

example: getpdftheme
	asciidoctor-pdf.bat -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram formats_examples.adoc
	asciidoctor.bat -a stylesheet=styles/stylesheet.css -r asciidoctor-diagram formats_examples.adoc

