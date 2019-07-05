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

#Building binary
CC=cc
LIBLJ=-lluajit-5.1
#LIBLJ=-l:libluajit-5.1.a #Target systems don't have luajit installed?
LDLIBS=$(LIBLJ) -ldl -lm
INCLUDELJ=-I/usr/include/luajit-2.1
CINCLUDES=$(INCLUDELJ) -Iout
CFLAGS=-rdynamic $(LDLIBS) $(CINCLUDES)

#Assembling script
SHEBANG='\#!/usr/bin/env luajit'
MINI=luasrcdiet
MINIFLAGS=--quiet --maximum -o
#MINI=cp #Don't have luasrcdiet, and don't care about minification?
#MINIFLAGS=

.PHONY: dirs

all: dirs bin script

dirs: $(OUTDIR)
bin: $(OUTDIR)/$(BINNAME)
script: $(OUTDIR)/$(SCRIPTNAME)

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

$(OUTDIR)/body.lua: dirs $(BODYFILES)
	$(COMBINE) $(BODYFILES) > $(OUTDIR)/body.lua

$(OUTDIR)/body.h: dirs $(OUTDIR)/body.lua
	$(LJ) $(LJFLAGS) $(OUTDIR)/body.lua $(OUTDIR)/body.h

$(OUTDIR)/$(BINNAME): dirs $(OUTDIR)/body.h
	$(CC) src/wrapper.c $(CFLAGS) -o $(OUTDIR)/$(BINNAME)

$(OUTDIR)/mini.lua: dirs $(OUTDIR)/body.lua
	$(MINI) $(OUTDIR)/body.lua $(MINIFLAGS) $(OUTDIR)/mini.lua

$(OUTDIR)/$(SCRIPTNAME): dirs $(OUTDIR)/mini.lua
	echo $(SHEBANG) > $(OUTDIR)/$(SCRIPTNAME)
	cat $(OUTDIR)/mini.lua >> $(OUTDIR)/$(SCRIPTNAME)
	chmod +x $(OUTDIR)/$(SCRIPTNAME)

clean:
	rm -rf $(OUTDIR)/*
