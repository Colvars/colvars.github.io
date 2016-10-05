# This is slightly convoluted as it makes the PDF doc in a separate dir and copies them
# and the HTML doc from within that dir, targeting this one

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

.PHONY: all clean clean-all doxygen readme
all: pdf html doxygen readme
pdf: $(PDF)
html: colvars-refman-namd/colvars-refman-namd.html colvars-refman-vmd/colvars-refman-vmd.html colvars-refman-lammps/colvars-refman-lammps.html
readme: $(COLVARSDIR)/README.md $(COLVARSDIR)/README-totalforce.md
	cp -f $^ ./

$(PDFDIR)/%.pdf: $(DOCSRCDIR)/%.tex $(BIBTEX) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-cv.tex
	make -C $(DOCSRCDIR) pdf
	mv $(DOCSRCDIR)/`basename $@` $(PDFDIR)
	make -C $(DOCSRCDIR) clean

# Note: this relies on up-to-date bbl files; run pdflatex first!
colvars-refman-namd/colvars-refman-namd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-namd.tex $(DOCSRCDIR)/colvars-cv.tex 
	cd $(DOCSRCDIR); htlatex  colvars-refman-namd.tex "xhtml, charset=utf-8" " -cunihtf -utf8" "-d$(DOCDIR)/colvars-refman-namd/"
colvars-refman-vmd/colvars-refman-vmd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-vmd.tex $(DOCSRCDIR)/colvars-cv.tex 
	cd $(DOCSRCDIR); htlatex  colvars-refman-vmd.tex "xhtml, charset=utf-8" " -cunihtf -utf8" "-d$(DOCDIR)/colvars-refman-vmd/"
colvars-refman-lammps/colvars-refman-lammps.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-lammps.tex $(DOCSRCDIR)/colvars-cv.tex 
	cd $(DOCSRCDIR); htlatex  colvars-refman-lammps.tex "xhtml, charset=utf-8" " -cunihtf -utf8" "-d$(DOCDIR)/colvars-refman-lammps/"

doxygen: doxygen/html/index.html
   
doxygen/html/index.html: $(SRCDIR)/*.h
	cd doxygen; doxygen

clean:
	make -C $(DOCSRCDIR) clean

clean-all: 
	rm -f $(PDF) colvars-refman-namd/* colvars-refman-vmd/* colvars-refman-lammps/*

