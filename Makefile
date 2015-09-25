# This is slightly convoluted as it makes the PDF doc in a separate dir and copies them
# and the HTML doc from within that dir, targeting this one

SRCDIR=../colvars/doc
DOCDIR=$(PWD)
PDFDIR=pdf
PDF=$(PDFDIR)/colvars-refman-lammps.pdf $(PDFDIR)/colvars-refman-namd.pdf $(PDFDIR)/colvars-refman-vmd.pdf
BIBTEX=$(SRCDIR)/colvars-refman.bib

# Check that we are updating the doc for the master branch
branch := $(shell git -C $(SRCDIR) symbolic-ref --short -q HEAD)
ifneq (master, $(branch))
$(error Source repo has branch $(branch) checked out, rather than master - update manually if you must)
endif

.PHONY: all clean clean-all
all: pdf html
pdf: $(PDF)
html: colvars-refman-*/*html

$(PDFDIR)/%.pdf: $(SRCDIR)/%.tex $(BIBTEX) $(SRCDIR)/colvars-refman-main.tex $(SRCDIR)/colvars-refman.tex $(SRCDIR)/colvars-cv.tex
	make -C $(SRCDIR) pdf
	cp $(SRCDIR)/`basename $@` $(PDFDIR)

# Note: this relies on up-to-date bbl files; run pdflatex first!
colvars-refman-namd/colvars-refman-namd.html: $(BIBTEX) $(PDF) $(SRCDIR)/colvars-refman-main.tex $(SRCDIR)/colvars-refman.tex $(SRCDIR)/colvars-refman-namd.tex $(SRCDIR)/colvars-cv.tex 
	cd $(SRCDIR); htlatex  colvars-refman-namd.tex "" "" "-d$(DOCDIR)/colvars-refman-namd/"
colvars-refman-vmd/colvars-refman-vmd.html: $(BIBTEX) $(PDF) $(SRCDIR)/colvars-refman-main.tex $(SRCDIR)/colvars-refman.tex $(SRCDIR)/colvars-refman-vmd.tex $(SRCDIR)/colvars-cv.tex 
	cd $(SRCDIR); htlatex  colvars-refman-vmd.tex "" "" "-d$(DOCDIR)/colvars-refman-vmd/"
colvars-refman-lammps/colvars-refman-lammps.html: $(BIBTEX) $(PDF) $(SRCDIR)/colvars-refman-main.tex $(SRCDIR)/colvars-refman.tex $(SRCDIR)/colvars-refman-lammps.tex $(SRCDIR)/colvars-cv.tex 
	cd $(SRCDIR); htlatex  colvars-refman-lammps.tex "" "" "-d$(DOCDIR)/colvars-refman-lammps/"

clean: 
	cd $(SRCDIR); rm -f *.aux *.blg *.log *.toc *.out *.idx *.ilg *.ind *.brf *.4tc *.4ct *.css *.dvi *.html *.idv *.lg *.xref *.tmp *.bbl

clean-all: 
	rm -rf $(PDF) colvars-refman-namd colvars-refman-vmd colvars-refman-lammps
