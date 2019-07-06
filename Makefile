#Output names
BINNAME=glass-house-bin
SCRIPTNAME=glass-house-s

#Combining all lua files
LJ=luajit
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

all: bin script

bin: $(OUTDIR)/$(BINNAME)
script: $(OUTDIR)/$(SCRIPTNAME)

#First one to use OUTDIR has to make it
$(OUTDIR)/body.lua: $(BODYFILES)
	$(MKDIR) $(OUTDIR)
	$(COMBINE) $(BODYFILES) > $(OUTDIR)/body.lua

$(OUTDIR)/mini.lua: $(OUTDIR)/body.lua
	$(MINI) $(OUTDIR)/body.lua $(MINIFLAGS) $(OUTDIR)/mini.lua

$(OUTDIR)/body.h: $(OUTDIR)/mini.lua
	$(MAKEH) $(OUTDIR)/mini.lua > $(OUTDIR)/body.h

$(OUTDIR)/$(BINNAME): $(OUTDIR)/body.h
	$(CC) src/wrapper.c $(CFLAGS) -o $(OUTDIR)/$(BINNAME)

$(OUTDIR)/$(SCRIPTNAME): $(OUTDIR)/mini.lua
	echo $(SHEBANG) | cat - $(OUTDIR)/mini.lua > $(OUTDIR)/$(SCRIPTNAME)
	chmod +x $(OUTDIR)/$(SCRIPTNAME)

#Not strictly a build step, so not included in 'all'
sanity: bin script
	touch .save.glass
	mv .save.glass .save.glass.bk
	echo "q"| $(LJ) src/main.lua -s > $(OUTDIR)/o1.txt
	cp .save.glass $(OUTDIR)/
	cd $(OUTDIR); \
	echo "q" | ./$(BINNAME) -s > o2.txt; \
	echo "q" | ./$(SCRIPTNAME) -s > o3.txt
	diff $(OUTDIR)/o1.txt $(OUTDIR)/o2.txt
	diff $(OUTDIR)/o1.txt $(OUTDIR)/o3.txt
	rm .save.glass
	mv .save.glass.bk .save.glass

clean:
	rm -rf $(OUTDIR)/*
