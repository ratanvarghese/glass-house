#Output names
BINNAME=glass-house-bin
SCRIPTNAME=glass-house-s

#Luajit
LJ=luajit
LJFLAGS=-b

#Combining all lua files
COMBINE=$(LJ) tools/combine.lua
BODYFILES=lib/*.lua src/*.lua ui/*.lua

#Output directory
OUTDIR=out
MKDIR=mkdir -p

#Assembling script
SHEBANG='\#!/usr/bin/env luajit'
MINI=$(LJ) tools/diet.lua
MINIFLAGS=--quiet --maximum -o
MAKEH=$(LJ) tools/makeh.lua

#Building binary
CC=cc
LIBLJ=-lluajit-5.1
#LIBLJ=-l:libluajit-5.1.a #Target systems don't have luajit installed?
LDLIBS=$(LIBLJ) -ldl -lm
INCLUDELJ=-I/usr/include/luajit-2.1
CINCLUDES=$(INCLUDELJ) -Iout
CFLAGS=-rdynamic $(LDLIBS) $(CINCLUDES)

.PHONY: dirs

all: dirs bin script

dirs: $(OUTDIR)
bin: $(OUTDIR)/$(BINNAME)
script: $(OUTDIR)/$(SCRIPTNAME)

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

$(OUTDIR)/body.lua: dirs $(BODYFILES)
	$(COMBINE) $(BODYFILES) > $(OUTDIR)/body.lua

$(OUTDIR)/mini.lua: dirs $(OUTDIR)/body.lua
	$(MINI) $(OUTDIR)/body.lua $(MINIFLAGS) $(OUTDIR)/mini.lua

$(OUTDIR)/body.h: dirs $(OUTDIR)/mini.lua
	$(MAKEH) $(OUTDIR)/mini.lua > $(OUTDIR)/body.h

$(OUTDIR)/$(BINNAME): dirs $(OUTDIR)/body.h
	$(CC) src/wrapper.c $(CFLAGS) -o $(OUTDIR)/$(BINNAME)

$(OUTDIR)/$(SCRIPTNAME): dirs $(OUTDIR)/mini.lua
	echo $(SHEBANG) > $(OUTDIR)/$(SCRIPTNAME)
	cat $(OUTDIR)/mini.lua >> $(OUTDIR)/$(SCRIPTNAME)
	chmod +x $(OUTDIR)/$(SCRIPTNAME)

clean:
	rm -rf $(OUTDIR)/*
