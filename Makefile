# There are a couple of conventions we use so make works a little better.:
#
# We sometimes want to build an entire directory of files based on one file.
# We do this for dependencies. E.g.: package.json -> node_modules.
# For these cases, we track an empty `.stamp` file in the directory.
# This allows us to keep up with make's dependency model.
#
# We also want some place to store all the excess build artifacts.
# This might be test outputs, or it could be some intermediate artifacts.
# For this, we use the `$(FILEPOND_HALOGEN_BUILD_DIR)` directory.
# Assuming the different tools allow us to put their artifacts in here,
# we can clean up builds really easily: delete this directory.
#
# We use some make syntax that might be unfamiliar, a quick refresher:
# make is based on a set of rules
#
# <targets>: <prerequisites> | <order-only-prerequisites>
# 	<recipe>
#
# `<targets>` are the things we want to make. This is usually a single file,
# but it can be multiple things separated by spaces.
#
# `<prerequisites>` are the things that decide when `<targets>` is out of date.
# These are also usually files. They are separated by spaces.
# If any of the `<prerequisites>` are newer than the `<targets>`,
# the recipe is run to bring the `<targets>` up to date.
#
# `<recipe>` are the commands to run to bring the `<targets>` up to date.
# These are commands like we write on a terminal.
#
# See: https://www.gnu.org/software/make/manual/make.html#Rule-Syntax
#
# `<order-only-prerequisites>` are similar to normal `<prerequisites>`
# but they don't cause a target to be rebuilt if they're out of date.
# This is mostly useful for creating directories and whatnot.
#
# See: https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types
#
# And a quick refresher on some make variables:
#
# $@ - Expands to the target we're building.
# $< - Expands to the first prerequisite of the recipe.
#
# See: https://www.gnu.org/software/make/manual/make.html#Automatic-Variables
#
# `.DEFAULT_GOAL` is the goal to use if no other goals are specified.
# Normally, the first goal in the file is used if no other goals are specified.
# Setting this allows us to override that behavior.
#
# See: https://www.gnu.org/software/make/manual/make.html#index-_002eDEFAULT_005fGOAL-_0028define-default-goal_0029
#
# `.PHONY` forces a recipe to always run. This is useful for things that are
# more like commands than targets. For instance, we might want to clean up
# all artifacts. Since there's no useful target, we can mark `clean` with
# `.PHONY` and make will run the task every time we ask it to.
#
# See: https://www.gnu.org/software/make/manual/make.html#Phony-Targets
# See: https://www.gnu.org/software/make/manual/make.html#index-_002ePHONY-1

# Absolute path to either this project, or the root project if called
# from parent Makefile
ROOT_DIR ?= $(shell pwd)

# Relative path to this directory from $ROOT_DIR
# If called from a parent Makefile, will resolve to something like `lib/filepond-halogen`
FILEPOND_HALOGEN_DIR ?= .

# Library-specific constants
FILEPOND_HALOGEN_BUILD_DIR := $(FILEPOND_HALOGEN_DIR)/.build
FILEPOND_HALOGEN_FORMAT_PURS_TIDY_STAMP := $(FILEPOND_HALOGEN_BUILD_DIR)/.format-filepond-halogen-purs-tidy-stamp
FILEPOND_HALOGEN_PURS := $(shell find $(FILEPOND_HALOGEN_DIR) -name '*.purs' -type f)
FILEPOND_HALOGEN_SPAGO_CONFIG := $(FILEPOND_HALOGEN_DIR)/spago.dhall
FILEPOND_HALOGEN_SRCS := $(shell find $(FILEPOND_HALOGEN_DIR) \( -name '*.purs' -o -name '*.js' \) -type f)
ROOT_DIR_RELATIVE := $(shell echo '$(FILEPOND_HALOGEN_DIR)' | sed 's \([^./]\+\) .. g')

# Variables we want to inherit from a parent Makefile if it exists
OUTPUT_DIR ?= $(ROOT_DIR)/output
SPAGO_DIR ?= $(ROOT_DIR)/.spago
SPAGO_PACKAGES_CONFIG ?= $(FILEPOND_HALOGEN_DIR)/packages.dhall
SPAGO_STAMP ?= $(SPAGO_DIR)/.stamp

# Commands and variables
PSA ?= psa
PSA_ARGS ?= --censor-lib --stash=$(FILEPOND_HALOGEN_BUILD_DIR)/.psa_stash --strict --is-lib=$(SPAGO_DIR) --censor-codes=HiddenConstructors
PURS_TIDY ?= purs-tidy
PURS_TIDY_CMD ?= check
RTS_ARGS ?= +RTS -N2 -A800m -RTS
SPAGO ?= spago
SPAGO_BUILD_DEPENDENCIES ?= $(SPAGO_STAMP)

# Colors for printing
CYAN ?= \033[0;36m
RESET ?= \033[0;0m

# Variables we add to
ALL_SRCS += $(FILEPOND_HALOGEN_SRCS)
CLEAN_DEPENDENCIES += clean-filepond-halogen
FORMAT_DEPENDENCIES += $(FILEPOND_HALOGEN_FORMAT_PURS_TIDY_STAMP)
SPAGO_CONFIGS += $(FILEPOND_HALOGEN_SPAGO_CONFIG)

.DEFAULT_GOAL := build-filepond-halogen

$(FILEPOND_HALOGEN_BUILD_DIR) $(OUTPUT_DIR):
	mkdir -p $@

$(FILEPOND_HALOGEN_BUILD_DIR)/help-unsorted: $(MAKEFILE_LIST) | $(FILEPOND_HALOGEN_BUILD_DIR)
	@grep \
		--extended-regexp '^[A-Za-z_-]+:.*?## .*$$' \
		--no-filename \
		$(MAKEFILE_LIST) \
		> $@

$(FILEPOND_HALOGEN_BUILD_DIR)/help: $(FILEPOND_HALOGEN_BUILD_DIR)/help-unsorted | $(FILEPOND_HALOGEN_BUILD_DIR)
	@sort $< > $@

$(FILEPOND_HALOGEN_FORMAT_PURS_TIDY_STAMP): $(FILEPOND_HALOGEN_PURS) | $(FILEPOND_HALOGEN_BUILD_DIR)
	$(PURS_TIDY) $(PURS_TIDY_CMD) $(FILEPOND_HALOGEN_DIR)/src
	@touch $@

$(FILEPOND_HALOGEN_SPAGO_CONFIG): gen-spago-config-filepond-halogen $(FILEPOND_HALOGEN_DIR)/spago.template.dhall

$(SPAGO_STAMP): $(SPAGO_PACKAGES_CONFIG) $(SPAGO_CONFIGS)
	# `spago` doesn't clean up after itself if different versions are installed, so we do it ourselves.
	rm -fr $(SPAGO_DIR)
	$(SPAGO) install $(RTS_ARGS)
	touch $@

.PHONY: build-filepond-halogen
build-filepond-halogen: $(FILEPOND_HALOGEN_SPAGO_CONFIG) $(SPAGO_BUILD_DEPENDENCIES) | $(FILEPOND_HALOGEN_BUILD_DIR) ## Build the `filepond-halogen` package
	$(SPAGO) --config $(FILEPOND_HALOGEN_SPAGO_CONFIG) build --purs-args '$(PSA_ARGS) $(RTS_ARGS)'

.PHONY: check-format-filepond-halogen
check-format-filepond-halogen: PURS_TIDY_CMD=check
check-format-filepond-halogen: $(FILEPOND_HALOGEN_FORMAT_PURS_TIDY_STAMP) ## Validate formatting of the `filepond-halogen` directory

# Since some of these variables are shared with the root Makefile.
# Running `clean-filepond-halogen` from root might have the unintended consequence
# of cleaning more than intended. Specifically, it will remove the
# root $OUTPUT_DIR, and $SPAGO_DIR.
.PHONY: clean-filepond-halogen
clean-filepond-halogen: clean-spago-config-filepond-halogen
	rm -fr \
		$(FILEPOND_HALOGEN_BUILD_DIR) \
		$(OUTPUT_DIR) \
		$(SPAGO_DIR)

.PHONY: clean-spago-config-filepond-halogen
clean-spago-config-filepond-halogen:
	rm -f $(FILEPOND_HALOGEN_SPAGO_CONFIG)

.PHONY: format-filepond-halogen
format-filepond-halogen: PURS_TIDY_CMD=format-in-place
format-filepond-halogen: $(FILEPOND_HALOGEN_FORMAT_PURS_TIDY_STAMP) ## Format the `filepond-halogen` directory

.PHONY: gen-spago-config-filepond-halogen
gen-spago-config-filepond-halogen: $(FILEPOND_HALOGEN_DIR)/spago.template.dhall | $(FILEPOND_HALOGEN_BUILD_DIR)
	@sed \
		's+{{PACKAGES_DIR}}+$(ROOT_DIR_RELATIVE)+g; s+{{SOURCES_DIR}}+$(FILEPOND_HALOGEN_DIR)+g; s+{{GENERATED_DOC}}+This config is auto-generated by make.\nIf the paths are wrong, try deleting it and running make again.+g' \
		$(FILEPOND_HALOGEN_DIR)/spago.template.dhall > $(FILEPOND_HALOGEN_BUILD_DIR)/spago.dhall
	@if cmp -s -- '$(FILEPOND_HALOGEN_BUILD_DIR)/spago.dhall' '$(FILEPOND_HALOGEN_SPAGO_CONFIG)'; then \
		echo 'Nothing to do for $(FILEPOND_HALOGEN_SPAGO_CONFIG)'; \
	else \
		echo 'Generating new $(FILEPOND_HALOGEN_SPAGO_CONFIG)'; \
		cp $(FILEPOND_HALOGEN_BUILD_DIR)/spago.dhall $(FILEPOND_HALOGEN_SPAGO_CONFIG); \
	fi

.PHONY: help
help: $(FILEPOND_HALOGEN_BUILD_DIR)/help ## Display this help message
	@awk 'BEGIN {FS = ":.*?## "}; {printf "$(CYAN)%-30s$(RESET) %s\n", $$1, $$2}' $<

.PHONY: variable-%
variable-%: ## Display the value of a variable; e.g. `make variable-FILEPOND_HALOGEN_BUILD_DIR`
	@echo '$*=$($*)'

