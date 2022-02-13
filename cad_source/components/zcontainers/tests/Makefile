.PHONY: clean all checkallvars checkvars 
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

CPUDETECT:=
ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		CPUDETECT=AMD64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		CPUDETECT=IA32
	endif
else
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CPUDETECT=AMD64
	endif
		ifneq ($(filter %86,$(UNAME_P)),)
	CPUDETECT=IA32
		endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CPUDETECT=ARM
	endif
endif

PATHDELIM:=
ifeq ($(OSDETECT),WIN32)
	PATHDELIM =\\
else
	PATHDELIM =/
endif


PCP:=
ifeq ($(OSDETECT),WIN32)
	PCP=$(LOCALAPPDATA)\lazarus
else
	ifeq ($(OSDETECT),LINUX)
		PCP='~/.lazarus'
	else
		ifeq ($(OSDETECT),OSX)
			PCP=~/.lazarus
		else
			PCP=~/.lazarus
		endif

	endif
endif

LP:=
ifeq ($(OSDETECT),WIN32)
	LP =C:\lazarus
else
	ifeq ($(OSDETECT),LINUX)
		LP=~/lazarus
	else
		ifeq ($(OSDETECT),OSX)
			PCP=~/lazarus
		else
			PCP=~/lazarus
		endif

	endif
endif

checkallvars: checkvars 
	@echo OSDETECT=$(OSDETECT)
	@echo CPUDETECT=$(CPUDETECT)

checkvars:              
	@echo PCP=$(PCP)
	@echo LP=$(LP)

clean:                  
	rm -rf lib/*
	rm -rf lib

all: checkvars
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) testzcontainers.lpr