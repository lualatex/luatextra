# Makefile for luatextra.

NAME = luatextra
DTX = $(wildcard *.dtx)
DOC_DTX = $(patsubst %.dtx, %.pdf, $(DTX))

# Files grouped by generation mode
UNPACKED= luatextra.sty
COMPILED = $(DOC_DTX)
GENERATED = $(UNPACKED) $(COMPILED)
SOURCE = $(DTX) README Makefile News

# Files grouped by installation location
RUNFILES = $(filter-out test.tex, $(UNPACKED))
DOCFILES = $(DOC_DTX) test.tex README News
SRCFILES = $(DTX) Makefile

# The following definitions should be equivalent
# ALL_FILES = $(RUNFILES) $(DOCFILES) $(SRCFILES)
ALL_FILES = $(GENERATED) $(SOURCE)

# Installation locations
FORMAT = lualatex
RUNDIR = $(TEXMFROOT)/tex/$(FORMAT)/$(NAME)
DOCDIR = $(TEXMFROOT)/doc/$(FORMAT)/$(NAME)
SRCDIR = $(TEXMFROOT)/source/$(FORMAT)/$(NAME)
TEXMFROOT = ./texmf

CTAN_ZIP = $(NAME).zip
TDS_ZIP = $(NAME).tds.zip
ZIPS = $(CTAN_ZIP) $(TDS_ZIP)

DO_TEX = tex --interaction=batchmode $< >/dev/null
DO_LATEXMK = latexmk -pdf -silent $< >/dev/null

all: $(GENERATED)
doc: $(COMPILED)
unpack: $(UNPACKED)
ctan: check $(CTAN_ZIP)
tds: $(TDS_ZIP)
world: all ctan
.PHONY: all doc unpack ctan tds world check

%.pdf: %.dtx
	$(DO_LATEXMK)

$(UNPACKED): luatextra.dtx
	$(DO_TEX)

check: $(UNPACKED)
	lualatex --interaction=batchmode test.tex >/dev/null

$(CTAN_ZIP): $(SOURCE) $(COMPILED) $(TDS_ZIP)
	@echo "Making $@ for CTAN upload."
	@$(RM) -- $@
	@zip -9 $@ $^ >/dev/null

define run-install
@mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
@mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
@mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)
endef

$(TDS_ZIP): TEXMFROOT=./tmp-texmf
$(TDS_ZIP): $(ALL_FILES)
	@echo "Making TDS-ready archive $@."
	@$(RM) -- $@
	$(run-install)
	@cd $(TEXMFROOT) && zip -9 ../$@ -r . >/dev/null
	@$(RM) -r -- $(TEXMFROOT)

.PHONY: install manifest clean mrproper

install: $(ALL_FILES)
	@echo "Installing in '$(TEXMFROOT)'."
	$(run-install)

manifest: 
	@echo "Source files:"
	@for f in $(SOURCE); do echo $$f; done
	@echo ""
	@echo "Derived files:"
	@for f in $(GENERATED); do echo $$f; done

clean:
	@latexmk -silent -c *.dtx >/dev/null
	@# for tex-only runs:
	@rm -f -- *.log

mrproper: clean
	@$(RM) -- $(GENERATED) $(ZIPS) test.*

