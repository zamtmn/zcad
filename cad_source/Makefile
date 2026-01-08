.PHONY: crutch_before_compilation
default: crutch_before_compilation

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

crutch_before_compilation:
ifeq ($(OSDETECT),WIN32)
	@echo Makefile.crutch_before_compilation Note: Workaround for https://gitlab.com/freepascal.org/fpc/source/-/issues/39387
else
	@echo Makefile.crutch_before_compilation Note: Workaround for https://gitlab.com/freepascal.org/fpc/source/-/issues/39387
endif
#	rm -rf ../lib/x86_64-win64/uzeparser.*
#	rm -rf ../lib/i386-win32/uzeparser.*
#	rm -rf ../lib/x86_64-linux/uzeparser.*
#	rm -rf ../lib/i386-linux/uzeparser.*
	rm -rf ../lib/x86_64-win64/uzcextdrschconnector.*
	rm -rf ../lib/i386-win32/uzcextdrschconnector.*
	rm -rf ../lib/x86_64-linux/uzcextdrschconnector.*
	rm -rf ../lib/i386-linux/uzcextdrschconnector.*

rmsrcbackups:
	rm -rf components/metadarkstyle/src/backup/*
	rm -rf components/metadarkstyle/src/backup
	rm -rf components/metadarkstyle/examples/defaultallowdark/backup/*
	rm -rf components/metadarkstyle/examples/defaultallowdark/backup
	rm -rf components/zcontainers/backup/*
	rm -rf components/zcontainers/backup
	rm -rf components/zbaseutils/backup/*
	rm -rf components/zbaseutils/backup
	rm -rf components/zbaseutilsgui/backup/*
	rm -rf components/zbaseutilsgui/backup
	rm -rf components/zbaseutilsgui/examples/simpleapp/backup/*
	rm -rf components/zbaseutilsgui/examples/simpleapp/backup
	rm -rf components/zcontrols/backup/*
	rm -rf components/zcontrols/backup
	rm -rf components/zmacros/src/backup/*
	rm -rf components/zmacros/src/backup
	rm -rf components/zmath/backup/*
	rm -rf components/zmath/backup
	rm -rf components/zobjectinspector/backup/*
	rm -rf components/zobjectinspector/backup
	rm -rf components/zscriptbase/backup/*
	rm -rf components/zscriptbase/backup
	rm -rf components/zscript/backup/*
	rm -rf components/zscript/backup
	rm -rf components/ztoolbars/src/backup/*
	rm -rf components/ztoolbars/src/backup
	rm -rf components/zundostack/backup/*
	rm -rf components/zundostack/backup
	rm -rf components/fpdwg/backup/*
	rm -rf components/fpdwg/backup
	rm -rf components/zreaders/src/backup/*
	rm -rf components/zreaders/src/backup
	rm -rf components/fphunspell/src/backup/*
	rm -rf components/fphunspell/src/backup$
	rm -rf backup/*
	rm -rf backup
	rm -rf other/backup
	rm -rf simplecad/backup
	rm -rf zcad/backup
	rm -rf zcad/commands/backup
	rm -rf zcad/core/backup
	rm -rf zcad/core/drawings/backup
	rm -rf zcad/core/undostack/backup
	rm -rf zcad/core/utils/backup
	rm -rf zcad/devicebase/backup
	rm -rf zcad/electrotech/backup
	rm -rf zcad/entities/backup
	rm -rf zcad/gui/backup
	rm -rf zcad/gui/forms/backup
	rm -rf zcad/gui/odjectinspector/backup
	rm -rf zcad/lclmod/backup
	rm -rf zcad/register/backup
	rm -rf zcad/velec/backup
	rm -rf zengine/backup
	rm -rf zengine/containers/backup
	rm -rf zengine/core/backup
	rm -rf zengine/core/drawings/backup
	rm -rf zengine/core/entities/backup
	rm -rf zengine/core/objects/backup
	rm -rf zengine/core/utils/backup
	rm -rf zengine/fileformats/backup
	rm -rf zengine/fonts/backup
	rm -rf zengine/misc/backup
	rm -rf zengine/styles/backup
	rm -rf zengine/tests/backup
	rm -rf zengine/zgl/backup
	rm -rf zengine/zgl/drawers/backup

rmpkgslibs:
	rm -rf components/metadarkstyle/lib/*
	rm -rf components/zcontainers/lib/*
	rm -rf components/zbaseutils/lib/*
	rm -rf components/zbaseutilsgui/lib/*
	rm -rf components/zcontrols/lib/*
	rm -rf components/zmacros/lib/*
	rm -rf components/zmath/lib/*
	rm -rf components/zobjectinspector/lib/*
	rm -rf components/zscriptbase/lib/*
	rm -rf components/zscript/lib/*
	rm -rf components/ztoolbars/lib/*
	rm -rf components/zundostack/lib/*
	rm -rf components/fpdwg/lib/*
	rm -rf components/fpspreadsheet/lib/*
	rm -rf components/fpspreadsheet/source/common/lib/*
	rm -rf components/fpspreadsheet/source/visual/lib/*
	rm -rf components/lape/package/lib/*
	rm -rf components/zreaders/lib/*
	rm -rf components/fphunspell/lib/*
	rm -rf simplecad/lib/*
	rm -rf other/agraphlaz/lazarus/lib/*
	rm -rf ../lib/*
	rm -rf components/metadarkstyle/lib
	rm -rf components/zcontainers/lib
	rm -rf components/zbaseutils/lib
	rm -rf components/zbaseutilsgui/lib
	rm -rf components/zcontrols/lib
	rm -rf components/zmacros/lib
	rm -rf components/zmath/lib
	rm -rf components/zobjectinspector/lib
	rm -rf components/zscriptbase/lib
	rm -rf components/zscript/lib
	rm -rf components/ztoolbars/lib
	rm -rf components/zundostack/lib
	rm -rf components/fpdwg/lib
	rm -rf components/fpspreadsheet/lib
	rm -rf components/fpspreadsheet/source/common/lib
	rm -rf components/fpspreadsheet/source/visual/lib
	rm -rf components/lape/package/lib
	rm -rf components/zreaders/lib
	rm -rf components/fphunspell/lib
	rm -rf components/zunits/lib
	rm -rf simplecad/lib
	rm -rf other/agraphlaz/lazarus/lib
#	rm -rf ../lib

