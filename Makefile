#
# Makefile
#
# Installs, links or uninstalls all scripts in the $HOME/bin directory or
# sets symbolic links from $HOME/bin to the scripts in the current directory.
#
#
# Copyright (C) 2010 Marc Weidler (marc.weidler@web.de)
#
# THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
# THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.
# SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY
# SERVICING, REPAIR OR CORRECTION.

BINS = $(wildcard *.sh)

install:
	@mkdir -p $(HOME)/bin
	@echo "... installing scripts to $(HOME)/bin"
	@$(foreach BIN, $(BINS), \
		echo "... installing `basename $(BIN)`"; \
		cp -f $(BIN) $(HOME)/bin/$(BIN); \
	)

link:
	@mkdir -p $(HOME)/bin
	@echo "... linking scripts to $(HOME)/bin"
	@$(foreach BIN, $(BINS), \
		echo "... linking `basename $(BIN)`"; \
		rm -f $(HOME)/bin/$(BIN); \
		ln -s `pwd`/$(BIN) $(HOME)/bin/$(BIN); \
	)

uninstall:
	@$(foreach BIN, $(BINS), \
		echo "... uninstalling $(HOME)/bin/$(BIN)"; \
		rm -f $(HOME)/bin/$(BIN); \
	)

.PHONY: install link uninstall
