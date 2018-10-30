# This is slightly convoluted as it makes the PDF doc in a separate dir and copies them
# The HTML doc is made from within that dir, targeting this one

# Safe order of operations: make clean; make pdf; make html

COLVARSDIR=../colvars
SRCDIR=$(COLVARSDIR)/src
DOCSRCDIR=$(COLVARSDIR)/doc
DOCDIR=$(PWD)
PDFDIR=pdf
PDF=$(PDFDIR)/colvars-refman-lammps.pdf $(PDFDIR)/colvars-refman-namd.pdf $(PDFDIR)/colvars-refman-vmd.pdf
BIBTEX=$(DOCSRCDIR)/colvars-refman.bib

# Check that we are updating the doc for the master branch
branch := $(shell git -C $(DOCSRCDIR) symbolic-ref --short -q HEAD)
ifneq (master, $(branch))
$(error Source repo has branch $(branch) checked out, rather than master - update manually if you must)
endif

.PHONY: all clean veryclean doxygen readme
all: pdf html doxygen readme
pdf: $(PDF)
html: colvars-refman-namd/colvars-refman-namd.html colvars-refman-vmd/colvars-refman-vmd.html colvars-refman-lammps/colvars-refman-lammps.html
readme: $(COLVARSDIR)/README.md $(COLVARSDIR)/README-totalforce.md
	cp -f $^ ./

$(PDFDIR)/%.pdf: $(DOCSRCDIR)/%.tex $(BIBTEX) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex
	make -C $(DOCSRCDIR) pdf
	mv -f $(DOCSRCDIR)/`basename $@` $(PDFDIR)
	make -C $(DOCSRCDIR) clean

HTLATEX = htlatex
HTLATEX_OPTS = "html5mjlatex.cfg, charset=utf-8" " -cunihtf -utf8"

# Note: this relies on up-to-date bbl files; run pdflatex first!
colvars-refman-namd/colvars-refman-namd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-namd.tex
	cd $(DOCSRCDIR); \
	cp -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-namd.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-namd/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-namd; \
	sh ../fix_section_labels.sh

colvars-refman-vmd/colvars-refman-vmd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-vmd.tex
	cd $(DOCSRCDIR); \
	cp -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-vmd.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-vmd/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-vmd; \
	sh ../fix_section_labels.sh

colvars-refman-lammps/colvars-refman-lammps.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-lammps.tex
	cd $(DOCSRCDIR); \
	cp -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-lammps.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-lammps/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-lammps; \
	sh ../fix_section_labels.sh

doxygen: doxygen/html/index.html

doxygen/html/index.html: $(SRCDIR)/*.h doxygen/Doxyfile
	cd doxygen; doxygen

clean:
	make -C $(DOCSRCDIR) clean

veryclean: clean
	rm -f $(PDF) colvars-refman-namd/* colvars-refman-vmd/* colvars-refman-lammps/*
