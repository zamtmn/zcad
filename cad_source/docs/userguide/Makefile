.PHONY: pdf html all
default: all

all: clean pdf html

clean:                  
	rm -rf userguide.ru.html
	rm -rf userguide.ru.pdf
pdf:                      
	asciidoctor-pdf.bat -r asciidoctor-diagram userguide.ru.adoc

html:                      
	asciidoctor.bat -r asciidoctor-diagram userguide.ru.adoc
