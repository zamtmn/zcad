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
