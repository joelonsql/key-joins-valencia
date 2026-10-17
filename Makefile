.DEFAULT_GOAL := all

TECTONIC ?= tectonic
TECTONIC_FLAGS ?= --untrusted --reruns 1 --keep-logs

NAME := key-joins-valencia-presentation
SOURCE := $(NAME).tex
PDF := $(NAME).pdf
BUILD_DIR := build
ASSETS := assets/key-joins-valencia/derived-tables-workshop.jpg \
          assets/key-joins-valencia/derived-tables-whiteboard.jpg \
          assets/key-joins-valencia/stockholm.jpg \
          assets/key-joins-valencia/standardese-experts.jpg \
          assets/key-joins-valencia/restarting-iso.jpg \
          assets/key-joins-valencia/tashkent-acceptance.jpg \
          assets/key-joins-valencia/mimer-logo.pdf
EXAMPLE_PDFS := examples/key-joins-fanout.pdf examples/key-joins-guarantees.pdf

.PHONY: all pdf examples clean
.DELETE_ON_ERROR:

all: pdf

pdf: $(PDF)

$(PDF): $(SOURCE) $(ASSETS) Makefile | $(BUILD_DIR)
	$(TECTONIC) $(TECTONIC_FLAGS) --outdir "$(BUILD_DIR)" "$(SOURCE)"
	cp "$(BUILD_DIR)/$(PDF)" "$@"

examples: $(EXAMPLE_PDFS)

examples/%.pdf: examples/%.tex Makefile | $(BUILD_DIR)
	$(TECTONIC) $(TECTONIC_FLAGS) --outdir "$(BUILD_DIR)" "$<"
	cp "$(BUILD_DIR)/$(@F)" "$@"

$(BUILD_DIR):
	mkdir -p "$@"

clean:
	rm -rf "$(BUILD_DIR)"
	rm -f "$(PDF)" $(EXAMPLE_PDFS)
