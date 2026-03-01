.PHONY: pdf html all example getpdftheme
default: all

PATHDELIM:=/
ifeq ($(OS),Windows_NT)
	PATHDELIM:=\\
endif
PATHDELIM:=$(strip $(PATHDELIM))

ASCIIDOCTOR_PDF_DIR:=$(shell gem contents asciidoctor-pdf --show-install-dir)
RULASTCOMMIT:=$(shell git log --pretty=tformat:\"%H\" -n1 locale/ru)
RUVERSION:=$(shell git describe --tags  $(RULASTCOMMIT))

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
	cp -r ../../../environment/runtimefiles/AllCPU-AllOS/common/data/images/* ../images

pdf: getpdftheme version copyimages
	asciidoctor-pdf -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram userguide.ru.adoc

html: version copyimages                      
	asciidoctor -a stylesheet=styles/stylesheet.css -r asciidoctor-multipage -b multipage_html5 -r asciidoctor-diagram userguide.ru.adoc

example: version styles/default-theme.yml
	asciidoctor-pdf -a pdf-themesdir=styles -a pdf-theme=zcadd -r asciidoctor-diagram formats_examples.adoc
	asciidoctor -a stylesheet=styles/stylesheet.css -r asciidoctor-diagram formats_examples.adoc

ruspell:
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC userguide.ru.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\attributes.adoc 
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\customization.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\for_developers.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\general_information.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\getting_started.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\_elements\commandsummary.adoc 
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\customization\command_line_swith.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\customization\directory_structure.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\customization\options.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\for_developers\building_from_sources.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\for_developers\documentation.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\for_developers\localization.adoc 
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\general_information\disclaimer.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\general_information\license.adoc 
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\getting_started\instalation.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\getting_started\launch.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\getting_started\system_requirements.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\3dpoly.adoc 
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\about.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\arc.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\bedit.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\cam_reset.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\cancel.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\circle.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\commandsummaryfree.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\copy.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\copybase.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\copyclip.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\cutclip.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dataexport.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dataimport.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\devdefsync.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dockingoptions.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dwgclose.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dwgnew.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dwgnext.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\dwgprev.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\erase.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\extdradd.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\extdralllist.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\extdrentslist.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\extdrremove.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\layer.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\load.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\loadactions.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\loadlayout.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\loadmenus.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\loadpalettes.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\loadtoolbars.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\matchprop.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\merge.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\mergeblocks.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\mirror.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\move.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\rotate.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\saveas.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\savelayout.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\saveoptions.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\updatepo.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\varsed.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\varsedbd.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\varsedsel.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands\varslink.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities\device.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities_extensions\extdrlayercontrol.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities_extensions\extdrsmarttextent.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities_extensions\extdrvariables.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\commands.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\entities_extensions.adoc
	hunspell -l -d ru_RU,en_US,zc_ZC,ad_OC locale\ru\working_with_program\user_interface.adoc 
