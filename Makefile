# This is slightly convoluted as it makes the PDF doc in a separate dir and copies them
# The HTML doc is made from within that dir, targeting this one

# Safe order of operations: make clean; make pdf; make html

DOCDIR=$(PWD)
COLVARSDIR=$(PWD)/../colvars
SRCDIR=$(COLVARSDIR)/src
DOCSRCDIR=$(COLVARSDIR)/doc
PDFDIR=pdf
PDF=$(PDFDIR)/colvars-refman-gromacs.pdf \
	$(PDFDIR)/colvars-refman-lammps.pdf \
	$(PDFDIR)/colvars-refman-namd.pdf \
	$(PDFDIR)/colvars-refman-vmd.pdf \
	vmd-1.9.4/$(PDFDIR)/colvars-refman-vmd.pdf

BIBTEX=$(DOCSRCDIR)/colvars-refman.bib
HTML=colvars-refman-gromacs/colvars-refman-gromacs.html \
	colvars-refman-lammps/colvars-refman-lammps.html \
	colvars-refman-namd/colvars-refman-namd.html \
	colvars-refman-vmd/colvars-refman-vmd.html \
	vmd-1.9.4/colvars-refman-vmd/colvars-refman-vmd.html

IMAGES = cover-512px.jpg eulerangles-512px.png

# Check that we are updating the doc for the master branch
branch := $(shell git -C $(DOCSRCDIR) symbolic-ref --short -q HEAD)
ifneq ($(FORCE), 1)
  ifneq ($(branch), master)
  $(error Source repo has branch $(branch) checked out, instead of master. Use FORCE=1 to override)
  endif
endif

.PHONY: all clean veryclean doxygen readme images

all: images pdf html doxygen readme

images:
	make -C images all; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) $(DOCSRCDIR)/

pdf: $(PDF)

html: $(HTML)

readme: $(COLVARSDIR)/README.md $(COLVARSDIR)/README-totalforce.md $(COLVARSDIR)/README-c++11.md $(COLVARSDIR)/README-versions.md
	cp -p -f $^ ./

$(PDFDIR)/%.pdf: $(DOCSRCDIR)/%.tex $(BIBTEX) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex
	make -C $(DOCSRCDIR) pdf
	mv -f $(DOCSRCDIR)/`basename $@` $(PDFDIR)
	make -C $(DOCSRCDIR) clean

HTLATEX = htlatex
HTLATEX_OPTS = "html5mjlatex.cfg, charset=utf-8" " -cunihtf -utf8"

# Note: this relies on up-to-date bbl files; run pdflatex first!
colvars-refman-namd/colvars-refman-namd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-namd.tex
	cd $(DOCSRCDIR); \
	cp -p -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-namd.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-namd/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-namd; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) ./ ; \
	sh ../postprocess_html.sh

colvars-refman-vmd/colvars-refman-vmd.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-vmd.tex
	cd $(DOCSRCDIR); \
	cp -p -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-vmd.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-vmd/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-vmd; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) ./ ; \
	sh ../postprocess_html.sh

vmd-1.9.4/colvars-refman-vmd/colvars-refman-vmd.html: colvars-refman-vmd/colvars-refman-vmd.html
	cp -p -f $^ $@; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) vmd-1.9.4/colvars-refman-vmd/

vmd-1.9.4/pdf/colvars-refman-vmd.pdf: pdf/colvars-refman-vmd.pdf
	cp -p -f $^ $@

colvars-refman-lammps/colvars-refman-lammps.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-lammps.tex
	cd $(DOCSRCDIR); \
	cp -p -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-lammps.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-lammps/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-lammps; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) ./ ; \
	sh ../postprocess_html.sh

colvars-refman-gromacs/colvars-refman-gromacs.html: $(BIBTEX) $(PDF) $(DOCSRCDIR)/colvars-refman-main.tex $(DOCSRCDIR)/colvars-refman.tex $(DOCSRCDIR)/colvars-refman-gromacs.tex
	cd $(DOCSRCDIR); \
	cp -p -f $(DOCDIR)/html5mjlatex.cfg ./ ; \
	$(HTLATEX) colvars-refman-gromacs.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/colvars-refman-gromacs/"; \
	rm -f html5mjlatex.cfg; \
	cd $(DOCDIR)/colvars-refman-gromacs; \
	cp -p -f $(addprefix $(DOCDIR)/images/, $(IMAGES)) ./ ; \
	sh ../postprocess_html.sh


multi-map/multi-map.pdf: multi-map.src/multi-map.tex
	cd multi-map.src; \
	make; \
	cp -p -f multi-map.pdf $(DOCDIR)/multi-map/

multi-map/multi-map.html: multi-map/multi-map.pdf multi-map.src/multi-map.tex
	cd multi-map.src; \
	cp -p -f $(DOCDIR)/html5mjlatex.cfg $(DOCSRCDIR)/colvars-refman-css.tex ./ ; \
	$(HTLATEX) multi-map.tex $(HTLATEX_OPTS) "-d$(DOCDIR)/multi-map/"; \
	rm -f html5mjlatex.cfg colvars-refman-css.tex; \
	cd $(DOCDIR)/multi-map; \
	sh ../postprocess_html.sh


doxygen: doxygen/html/index.html

doxygen/html/index.html: $(SRCDIR)/*.h doxygen/Doxyfile
	cd doxygen; doxygen

clean:
	make -C $(DOCSRCDIR) clean

veryclean: clean
	rm -f $(PDF) colvars-refman-namd/* colvars-refman-vmd/* colvars-refman-lammps/*  colvars-refman-gromacs/*

