.PHONY: checkallvars checkvars clean zcadenv zcadelectrotechenv version zcad zcadelectrotech afterzcadelectrotechbuild cleanzcad cleanzcadelectrotech installpkgstolaz zcadelectrotechpdfuseguide rmpkgslibs tests
default: cleanzcad

OSDETECT:=
ifeq ($(OS),Windows_NT)
	OSDETECT:=WIN32
else
	UNAME_S:=$(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSDETECT:=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSDETECT:=OSX
	endif
endif

ZCVERSION:=
ifeq ($(wildcard .git),)
	ifeq ($(OSDETECT),WIN32)
		ZCVERSION:=$(shell type cad_source\zcadversion.notgit)
	else
		ZCVERSION:=$(shell cat cad_source/zcadversion.notgit)
	endif

else
	ZCVERSION:=$(shell git describe --tags) $(shell git symbolic-ref --short HEAD)
endif

QZCVERSION:='$(ZCVERSION)'

CPUDETECT:=
ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		CPUDETECT:=AMD64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		CPUDETECT:=IA32
	endif
else
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CPUDETECT:=AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CPUDETECT:=IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CPUDETECT:=ARM
	endif
endif

BUILDMODE:=default

BUILDPREFIX:=cad

INSTALLPREFIX:=NeedReplaceToDistribPath
ifeq ($(OSDETECT),WIN32)
	INSTALLPREFIX:=C:\Program Files\zcad
else
	ifeq ($(OSDETECT),LINUX)
		INSTALLPREFIX:=/var/lib/zcad
	else
		ifeq ($(OSDETECT),OSX)
			INSTALLPREFIX:=/var/lib/zcad
		else
			INSTALLPREFIX:=/var/lib/zcad
		endif
	endif
endif

PATHDELIM:=/
ifeq ($(OSDETECT),WIN32)
	PATHDELIM:=\\
endif
PATHDELIM:=$(strip $(PATHDELIM))

PCP:=
ifeq ($(OSDETECT),WIN32)
	PCP:=$(LOCALAPPDATA)\lazarus
else
	ifeq ($(OSDETECT),LINUX)
		PCP:='~/.lazarus'
	else
		ifeq ($(OSDETECT),OSX)
			PCP:=~/.lazarus
		else
			PCP:=~/.lazarus
		endif
	endif
endif

LP:=
ifeq ($(OSDETECT),WIN32)
	LP:=C:\lazarus
else
	ifeq ($(OSDETECT),LINUX)
		LP:=/usr/bin
	else
		ifeq ($(OSDETECT),OSX)
			LP:=~/lazarus
		else
			LP:=~/lazarus
		endif
	endif
endif

LAZBUILD:=$(LP)$(PATHDELIM)lazbuild

ZP:=$(if $(wildcard $(LAZBUILD)),$(shell $(LAZBUILD) --pcp=$(PCP) cad_source$(PATHDELIM)zcad.lpi --get-expand-text=$$\(ProjPath\)..$(PATHDELIM)$(BUILDPREFIX)$(PATHDELIM)bin$(PATHDELIM)$$\(TargetCPU\)-$$\(TargetOS\)),$())

checkallvars: checkvars 
	@echo OSDETECT=$(OSDETECT)
	@echo CPUDETECT=$(CPUDETECT)

checkvars:              
	@echo PCP=$(PCP)
	@echo LP=$(LP)
	@echo ZP=$(ZP)
	@echo INSTALLPREFIX=$(INSTALLPREFIX)

clean:                  
	rm -rf cad_source/autogenerated/*
	rm -rf cad_source/autogenerated
	rm -rf $(BUILDPREFIX)/*
	rm -rf $(BUILDPREFIX)
	rm -rf lib/*
	rm -rf errors/*.bak
	rm -rf errors/*.dbpas

updatezcadenv: checkvars      
	rm -rf $(BUILDPREFIX)/data/blocks
	rm -rf $(BUILDPREFIX)/cfg/components
	rm -rf $(BUILDPREFIX)/cfg/configs
	rm -rf $(BUILDPREFIX)/data/examples
	rm -rf $(BUILDPREFIX)/data/fonts
	rm -rf $(BUILDPREFIX)/data/images
	rm -rf $(BUILDPREFIX)/data/languages
	rm -rf $(BUILDPREFIX)/cfg/menu
	rm -rf $(BUILDPREFIX)/data/programdb
	rm -rf $(BUILDPREFIX)/data/template
	cp -r environment/runtimefiles/common/* $(BUILDPREFIX)
	cp -r environment/runtimefiles/zcad/* $(BUILDPREFIX)

updatezcadelectrotechenv: checkvars      
	rm -rf $(BUILDPREFIX)/data/blocks
	rm -rf $(BUILDPREFIX)/cfg/components
	rm -rf $(BUILDPREFIX)/cfg/configs
	rm -rf $(BUILDPREFIX)/data/examples
	rm -rf $(BUILDPREFIX)/data/fonts
	rm -rf $(BUILDPREFIX)/data/images
	rm -rf $(BUILDPREFIX)/data/languages
	rm -rf $(BUILDPREFIX)/cfg/menu
	rm -rf $(BUILDPREFIX)/data/programdb
	rm -rf $(BUILDPREFIX)/data/template
	cp -r environment/runtimefiles/common/* $(BUILDPREFIX)
	cp -r environment/runtimefiles/zcadelectrotech/* $(BUILDPREFIX)

zcadenv: checkvars      
	mkdir $(BUILDPREFIX)
	mkdir $(subst /,$(PATHDELIM),cad_source/autogenerated)
	cp -r environment/runtimefiles/common/* $(BUILDPREFIX)
	cp -r environment/runtimefiles/zcad/* $(BUILDPREFIX)
	echo create_file>cad_source/autogenerated/buildmode.inc
	rm -r cad_source/autogenerated/buildmode.inc

replaceinstallprefix:
ifeq ($(OSDETECT),WIN32)
	powershell -ex bypass -c "(Get-Content -Path '$(BUILDPREFIX)\cfg\configs\config.xml') -replace 'NeedReplaceToDistribPath','$(INSTALLPREFIX)' | Set-Content -Path '$(BUILDPREFIX)\cfg\configs\config.xml'"
else
	sed -i "s/NeedReplaceToDistribPath/$(shell printf '%s' "$(INSTALLPREFIX)" | sed 's/[]\/$*.^[]/\\&/g')/g" $(BUILDPREFIX)/cfg/configs/config.xml
endif

zcadelectrotechenv: checkvars 
	mkdir $(BUILDPREFIX)
	mkdir $(subst /,$(PATHDELIM),cad_source/autogenerated)
	cp -r environment/runtimefiles/common/* $(BUILDPREFIX)
	cp -r environment/runtimefiles/zcadelectrotech/* $(BUILDPREFIX)
	echo create_file>cad_source/autogenerated/buildmode.inc
	rm -r cad_source/autogenerated/buildmode.inc

version:
	echo ZCAD Version: $(ZCVERSION)
	echo quoted ZCAD Version: $(QZCVERSION)
#	@echo $(QZCVERSION) > cad_source/zcadversion.inc
ifeq ($(OSDETECT),WIN32)
	cmd.exe "/C echo '$(ZCVERSION)' > cad_source/zcadversion.inc"
else
	echo \'$(ZCVERSION)\' > cad_source/zcadversion.inc
endif
	@echo $(ZCVERSION) > cad_source/zcadversion.txt

ifneq ($(wildcard .git),)
ifeq ($(OSDETECT),WIN32)
	$(shell git describe --tags --abbrev=0 > cad_source\zcadversion.notgit)
else
	$(shell git describe --tags --abbrev=0 > cat cad_source/zcadversion.notgit)
endif
endif

zcad: checkvars version       
	$(LAZBUILD) --pcp=$(PCP) cad_source/utils/typeexporter.lpi
	environment/typeexporter/typeexporter pathprefix=cad_source/ outputfile=$(BUILDPREFIX)/data/rtl/system.pas processfiles=environment/typeexporter/zcad.files
	$(LAZBUILD) --pcp=$(PCP) --bm=$(BUILDMODE) cad_source/zcad.lpi

zcadelectrotech: checkvars version
	$(LAZBUILD) --pcp=$(PCP) cad_source/utils/typeexporter.lpi
	environment/typeexporter/typeexporter pathprefix=cad_source/ outputfile=$(BUILDPREFIX)/data/rtl/system.pas processfiles=environment/typeexporter/zcad.files+environment/typeexporter/zcadelectrotech.files define=ELECTROTECH
	$(LAZBUILD) --pcp=$(PCP) --bm=$(BUILDMODE) cad_source/zcad.lpi

afterzcadelectrotechbuild: checkallvars version
	$(ZP)/zcad nosplash runscript $(BUILDPREFIX)/cfg/components/afterbuild.cmd
$(BUILDPREFIX):
	mkdir $(BUILDPREFIX)
$(BUILDPREFIX)/data:
	mkdir $(subst /,$(PATHDELIM),$(BUILDPREFIX)/data)
$(BUILDPREFIX)/data/help: $(BUILDPREFIX) $(BUILDPREFIX)/data
	mkdir $(subst /,$(PATHDELIM),$(BUILDPREFIX)/data/help)
$(BUILDPREFIX)/data/help/locale: $(BUILDPREFIX) $(BUILDPREFIX)/data $(BUILDPREFIX)/data/help
	mkdir $(subst /,$(PATHDELIM),$(BUILDPREFIX)/data/help/locale)
$(BUILDPREFIX)/data/help/locale/ru: $(BUILDPREFIX) $(BUILDPREFIX)/data $(BUILDPREFIX)/data/help $(BUILDPREFIX)/data/help/locale
	mkdir $(subst /,$(PATHDELIM),$(BUILDPREFIX)/data/help/locale/ru)
$(BUILDPREFIX)/data/help/locale/ru/_images: $(BUILDPREFIX) $(BUILDPREFIX)/data $(BUILDPREFIX)/data/help $(BUILDPREFIX)/data/help/locale $(BUILDPREFIX)/data/help/locale/ru
	mkdir $(subst /,$(PATHDELIM),$(BUILDPREFIX)/data/help/locale/ru/_images)

documentation: checkvars $(BUILDPREFIX) $(BUILDPREFIX)/data $(BUILDPREFIX)/data/help $(BUILDPREFIX)/data/help/locale $(BUILDPREFIX)/data/help/locale/ru $(BUILDPREFIX)/data/help/locale/ru/_images
	$(MAKE) -C cad_source/docs/userguide all
	cp cad_source/docs/userguide/*.html $(BUILDPREFIX)/data/help
	cp cad_source/docs/userguide/*.pdf $(BUILDPREFIX)/data/help
	cp -r cad_source/docs/userguide/locale/ru/_images/* $(BUILDPREFIX)/data/help/locale/ru/_images

rmsrcbackups:
	$(MAKE) -C cad_source/ rmsrcbackups

rmpkgslibs:
	$(MAKE) -C cad_source/ rmpkgslibs

tests: checkvars
	$(MAKE) -C cad_source/components/zcontainers/tests LP=$(LP) PCP=$(PCP) clean all
	$(MAKE) -C cad_source/zengine/tests LP=$(LP) PCP=$(PCP) clean all

updatelocalizedpofiles: checkvars
	cp $(BUILDPREFIX)/data/languages/rtzcad.po $(BUILDPREFIX)/data/languages/rtzcad.pot
	$(LP)$(PATHDELIM)tools$(PATHDELIM)updatepofiles $(BUILDPREFIX)/data/languages/rtzcad.pot
	rm -rf $(BUILDPREFIX)/data/languages/rtzcad.pot
	cp $(LP)$(PATHDELIM)lcl/languages/*.po $(BUILDPREFIX)/data/languages
	cp $(LP)$(PATHDELIM)components/anchordocking/languages/*.po $(BUILDPREFIX)/data/languages

cleanzcad: clean zcadenv replaceinstallprefix zcad

cleanzcadelectrotech: clean zcadelectrotechenv replaceinstallprefix zcadelectrotech

submodulesinitupdate:
ifeq ($(OSDETECT),WIN32)
	$(error Submodules not found. Try "git submodule update --init --recursive")
endif
	git submodule update --init --recursive
cad_source/components/fpdwg/fpdwg.lpk:
	${MAKE} submodulesinitupdate
cad_source/other/agraphlaz/lazarus/ag_graph.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/metadarkstyle/metadarkstyle.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/zmacros/zmacros.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/ztoolbars/ztoolbars.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/fpspreadsheet/laz_fpspreadsheet.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/lape/package/lape.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/zreaders/zreaders.lpk:
	${MAKE} submodulesinitupdate
cad_source/components/callstack_memprofiler/source/callstack_memprofiler.pas:
	${MAKE} submodulesinitupdate
cad_source/components/fphunspell/fphunspell.lpk:
	${MAKE} submodulesinitupdate

checksubmodules: cad_source/components/fpdwg/fpdwg.lpk cad_source/other/agraphlaz/lazarus/ag_graph.lpk cad_source/components/metadarkstyle/metadarkstyle.lpk cad_source/components/zmacros/zmacros.lpk cad_source/components/ztoolbars/ztoolbars.lpk cad_source/components/fpspreadsheet/laz_fpspreadsheet.lpk cad_source/components/lape/package/lape.lpk cad_source/components/zreaders/zreaders.lpk cad_source/components/callstack_memprofiler/source/callstack_memprofiler.pas cad_source/components/fphunspell/fphunspell.lpk
	@echo All submodules found!

installpkgstolaz: checkvars checksubmodules rmpkgslibs
ifneq ($(OSDETECT),OSX)
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)other$(PATHDELIM)agraphlaz$(PATHDELIM)lazarus$(PATHDELIM)ag_graph.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)other$(PATHDELIM)agraphlaz$(PATHDELIM)lazarus$(PATHDELIM)ag_math.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)other$(PATHDELIM)agraphlaz$(PATHDELIM)lazarus$(PATHDELIM)ag_vectors.lpk
endif
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)other$(PATHDELIM)uniqueinstance$(PATHDELIM)uniqueinstance_package.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)metadarkstyle$(PATHDELIM)metadarkstyle.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zcontainers$(PATHDELIM)zcontainers.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zbaseutils$(PATHDELIM)zbaseutils.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zbaseutilsgui$(PATHDELIM)zbaseutilsgui.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zebase$(PATHDELIM)zebase.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zcontrols$(PATHDELIM)zcontrols.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zmacros$(PATHDELIM)zmacros.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zmath$(PATHDELIM)zmath.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zobjectinspector$(PATHDELIM)zobjectinspector.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zscriptbase$(PATHDELIM)zscriptbase.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zscript$(PATHDELIM)zscript.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)ztoolbars$(PATHDELIM)ztoolbars.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zundostack$(PATHDELIM)zundostack.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)fpdwg$(PATHDELIM)fpdwg.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)fpspreadsheet$(PATHDELIM)laz_fpspreadsheet_visual_dsgn.lpk
	$(LAZBUILD) --pcp=$(PCP) cad_source$(PATHDELIM)components$(PATHDELIM)lape$(PATHDELIM)package$(PATHDELIM)lape.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)zreaders$(PATHDELIM)zreaders.lpk
	$(LAZBUILD) --pcp=$(PCP) --add-package cad_source$(PATHDELIM)components$(PATHDELIM)fphunspell$(PATHDELIM)fphunspell.lpk
#	$(LAZBUILD) --pcp=$(PCP) --build-ide=""
