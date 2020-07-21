#Output names
SCRIPTNAME=glass-house

#Combining all lua files
LJ=luajit
COMBINE=$(LJ) tools/combine.lua
BODYFILES=lib/*.lua platform/unixterm/*.lua core/*.lua core/*/*.lua data/*.lua

#Output directory
OUTDIR=out
MKDIR=mkdir -p

#Assembling script
SHEBANG='\#!/usr/bin/env luajit'

all: script

script: $(OUTDIR)/$(SCRIPTNAME)

#First one to use OUTDIR has to make it
$(OUTDIR)/body.lua: $(BODYFILES)
	$(MKDIR) $(OUTDIR)
	$(COMBINE) $(BODYFILES) > $(OUTDIR)/body.lua

$(OUTDIR)/$(SCRIPTNAME): $(OUTDIR)/body.lua
	echo $(SHEBANG) | cat - $(OUTDIR)/body.lua > $(OUTDIR)/$(SCRIPTNAME)
	chmod +x $(OUTDIR)/$(SCRIPTNAME)

clean:
	rm -rf $(OUTDIR)/*
