##	-- ccompiler --
#
#	ccompiler's project Makefile.
#
#	Utilization example:
#		make <TARGET> ["DEBUG=true"] ["VERBOSE=true"]
#
#	\param TARGET
#		Can be any of the following:
#		all - builds the project (DEFAULT TARGET)
#		clean - cleans up all binaries generated during compilation
#		redo - cleans up and then builds
#		help - shows the utilization example
#		test - builds and run tests
#		doc - builds the documentation
#		tool - generates compile_commands.json
#		release - cleans and compresses the work directory for release
#
#	\param "DEBUG=true"
#		When present, the build will happen in debug mode.
#
#	\param "VERBOSE=true"
#		When present, the final executable will be more verbose.
#
#	\author @hcpsilva - Henrique Silva
#	\author @birromer - Bernardo Hummes
#
#	Make's default action is "all" when no parameters are provided.


################################################################################
#	Definitions:

#	- Project's directories:
INC_DIR := include
OBJ_DIR := bin
OUT_DIR := build
SRC_DIR := src
LIB_DIR := lib
TST_DIR := test
DOC_DIR := doc

#	- Compilation flags:
#	Compiler and language version
CC := gcc -std=c11
LEX := flex
YACC := bison
#	CFLAGS contains some basic sanity warning flags besides the eventual
#	preprocessor definition or debug flag.
CFLAGS :=\
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wshadow \
	-Wunreachable-code
#	If DEBUG is defined, we'll turn on the debug flag and attach address
#	sanitizer on the executables.
CFLAGS += $(if $(DEBUG),-g -fsanitize=address -DDEBUG)
CFLAGS += $(if $(VERBOSE),-DVERBOSE)
#	Feature flags for the lex program
LFLAGS := --nomain --yylineno
LFLAGS += $(if $(DEBUG),-d)
#	Basic warnings for the yacc program
YFLAGS := -Wall
YFLAGS += $(if $(DEBUG),--debug)
#	Optimize if we aren't debugging
OPT := $(if $(DEBUG),-O0,-O3 -march=native)
#	Lookup directories
LIB := -L$(LIB_DIR)
INC := -I$(INC_DIR)

#	- Release version:
VERSION := etapa2

################################################################################
#	Files:

#	- Main source files:
#	Presumes that all "main" source files are in the root of SRC_DIR
MAIN := $(wildcard $(SRC_DIR)/*.c)

#	- Path to all final binaries:
TARGET := $(MAIN:$(SRC_DIR)/%.c=$(OUT_DIR)/%)

#	- Yacc files:
YSRC := $(shell find $(SRC_DIR) -name '*.y')
YSRC := $(YSRC:.y=.tab.c)

#	- Lex files:
LSRC := $(shell find $(SRC_DIR) -name '*.l')
LSRC := $(LSRC:.l=.yy.c)

#	- Other source files:
CSRC := $(shell find $(SRC_DIR) -name '*.c')
CSRC := $(filter-out $(MAIN) $(YSRC) $(LSRC),$(CSRC)) $(YSRC) $(LSRC)

#	- Objects to be created:
OBJ := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

#	- Documentation and related files:
PDF := $(DOC_DIR)/$(VERSION).pdf
GV  := $(YSRC:.tab.c=.gv)
LOG := $(YSRC:.tab.c=.log)

#	- Include directories to be used in the release main.c
INCMAIN := $(shell find $(INC_DIR) -mindepth 1 -type d)
INCMAIN := $(INCMAIN:%=-I%)

################################################################################
#	Rules:

#	- Executables:
$(TARGET): $(OUT_DIR)/%: $(SRC_DIR)/%.c $(OBJ)
	$(CC) -o $@ $^ $(INC) $(INCMAIN) $(CFLAGS) $(OPT) $(LIB)

#	- Generated lexer source:
$(LSRC): %.yy.c: %.l
	$(LEX) $(LFLAGS) -o $@ $<

#	- Generated grammar files:
$(YSRC): $(SRC_DIR)/%.tab.c: $(SRC_DIR)/%.y
	$(YACC) $(YFLAGS) --output=$@ --defines=$(INC_DIR)/$*.tab.h $<

#	- Objects:
$(OBJ): $(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) -c -o $@ $< $(INC) $(CFLAGS) $(OPT)

#	- Documentation:
$(PDF): %.pdf: %.org
	emacs -batch $< --funcall org-latex-export-to-pdf
	@rm $*.tex*

#	- Graphviz generation:
$(GV): %.gv: %.y
	$(YACC) --graph=$@ $<
	dot -Tpdf -o$(DOC_DIR)/$(notdir $*).pdf $@ && rm $@

#	- Automaton log generation:
$(LOG): %.log: %.y
	$(YACC) -r all --report-file=$(DOC_DIR)/$(notdir $@) $<

################################################################################
#	Targets:

.DEFAULT_GOAL = all

#	Create a symlink in the expected executable location
all: gen $(TARGET)
	ln -sf $(shell readlink -f $(TARGET)) $(VERSION)

#	Prerequisites are the wanted files
gen: $(LSRC) $(YSRC)

clean:
	rm -rf $(OBJ_DIR)/* $(OUT_DIR)/* $(DOC_DIR)/*.{pdf,log} $(VERSION){,.tgz}
	rm -f $(YSRC) $(YSRC:$(SRC_DIR)/%.c=$(INC_DIR)/%.h) $(LSRC)

redo: clean all

#	There should be a script with the version name in the test dir
test: redo
	$(TST_DIR)/$(VERSION).sh

#	To help language servers as we're using additional include paths
tool: clean
	bear make

#	The script takes care of any necessary cleaning
release: ; scripts/release.sh

#	Build all documentation and remove any stray yacc generated source
doc: $(PDF) $(GV) $(LOG)
	@rm $(notdir $(YSRC))

help:
	@echo "ccompiler's project Makefile."
	@echo
	@echo "Utilization example:"
	@echo " make <TARGET> ['DEBUG=true'] ['VERBOSE=true']"
	@echo
	@echo "@param TARGET"
	@echo " Can be any of the following:"
	@echo " all - builds the project (DEFAULT TARGET)"
	@echo " clean - cleans up all binaries generated during compilation"
	@echo " redo - cleans up and then builds"
	@echo " help - shows the utilization example"
	@echo " test - builds and run tests"
	@echo " doc - builds the documentation"
	@echo " tool - generates compile_commands.json"
	@echo " release - cleans and compresses the work directory for release"
	@echo
	@echo "@param 'DEBUG=true'"
	@echo " When present, the build will happen in debug mode."
	@echo
	@echo "@param 'VERBOSE=true'"
	@echo " When present, the final executable will be more verbose."

################################################################################
#	Debugging and etc.:

#	Debug of the Make variables
print-%:
	@echo $* = $($*)

.PHONY: all clean redo help tool test release doc gen
