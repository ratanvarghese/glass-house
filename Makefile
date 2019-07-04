LJ=luajit
LJFLAGS=-b

COMBINE=$(LJ) tools/combine.lua

CC=cc
LIBLJ=-l:libluajit-5.1.a
LDLIBS=$(LIBLJ) -ldl -lm
INCLUDELJ=-I/usr/include/luajit-2.1
CINCLUDES=$(INCLUDELJ) -Iout
CFLAGS=-rdynamic $(LDLIBS) $(CINCLUDES)

OUTDIR=out
MKDIR=mkdir -p

BODYFILES=lib/*.lua src/*.lua ui/*.lua

EXECNAME=glass-house

.PHONY: dirs

all: dirs $(OUTDIR)/$(EXECNAME)

dirs: $(OUTDIR)

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

$(OUTDIR)/body.lua: dirs
	$(COMBINE) $(BODYFILES) > $(OUTDIR)/body.lua

$(OUTDIR)/body.h: dirs $(OUTDIR)/body.lua
	$(LJ) $(LJFLAGS) $(OUTDIR)/body.lua $(OUTDIR)/body.h

$(OUTDIR)/$(EXECNAME): dirs $(OUTDIR)/body.h
	$(CC) src/wrapper.c $(CFLAGS) -o $(OUTDIR)/$(EXECNAME)

clean:
	rm -rf $(OUTDIR)/*
