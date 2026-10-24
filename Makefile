# fpga-digital-systems-lab - simulation driver
#
# Requires a Unix shell. On Windows run this from Git Bash, NOT cmd.exe:
#   cmd.exe resolves `find` to Windows' unrelated find.exe and everything breaks.
#
#   make test            run every testbench under tb/
#   make test TB=tb_pwm  run just one
#   make wave TB=tb_pwm  open that testbench's waveform in GTKWave
#   make list            show discovered testbenches
#   make check-tools     verify iverilog/vvp/gtkwave are on PATH
#   make clean           remove sim/ build output

SHELL := /bin/bash

IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave
FLAGS    ?= -g2012 -Wall -Wno-timescale -I rtl

# tb/<subsystem>/tb_<name>.sv  ->  <subsystem>/tb_<name>
ALL_TESTS := $(patsubst tb/%,%,$(basename $(shell find tb -name 'tb_*.sv' 2>/dev/null | sort)))
RTL       := $(shell find rtl -name '*.v' 2>/dev/null | sort)

ifdef TB
TESTS := $(filter %/$(TB),$(ALL_TESTS))
else
TESTS := $(ALL_TESTS)
endif

.PHONY: test list wave clean check-tools

test:
	@mkdir -p sim; \
	if [ -z "$(strip $(ALL_TESTS))" ]; then \
	  echo "No testbenches under tb/ yet - nothing to run."; exit 0; \
	fi; \
	if [ -z "$(strip $(TESTS))" ]; then \
	  echo "ERROR: TB=$(TB) matched no testbench. Run 'make list' to see what exists."; exit 1; \
	fi; \
	fail=0; pass=0; total=0; \
	for t in $(TESTS); do \
	  name=$$(basename $$t); total=$$((total+1)); \
	  echo "=== $$name ==="; \
	  if ! $(IVERILOG) $(FLAGS) -o sim/$$name.vvp -s $$name $(RTL) tb/$$t.sv; then \
	    echo "COMPILE FAILED: $$name"; fail=1; continue; \
	  fi; \
	  if $(VVP) sim/$$name.vvp; then pass=$$((pass+1)); else fail=1; fi; \
	done; \
	echo "------------------------------"; \
	echo "$$pass/$$total testbenches passed"; \
	exit $$fail

list:
	@if [ -z "$(strip $(ALL_TESTS))" ]; then \
	  echo "(no testbenches yet - add tb/<subsystem>/tb_<name>.sv)"; \
	else \
	  for t in $(ALL_TESTS); do echo "  $$(basename $$t)   <- tb/$$t.sv"; done; \
	fi

wave:
	@if [ -z "$(TB)" ]; then echo "Usage: make wave TB=tb_gates"; exit 1; fi
	@if [ ! -f sim/$(TB).vcd ]; then \
	  echo "sim/$(TB).vcd not found. Run 'make test TB=$(TB)' first."; exit 1; \
	fi
	$(GTKWAVE) sim/$(TB).vcd &

check-tools:
	@ok=0; \
	for t in $(IVERILOG) $(VVP) $(GTKWAVE); do \
	  if command -v $$t >/dev/null 2>&1; then \
	    echo "  OK       $$t"; \
	  else \
	    echo "  MISSING  $$t"; ok=1; \
	  fi; \
	done; \
	if [ $$ok -ne 0 ]; then \
	  echo ""; \
	  echo "Install Icarus Verilog v12 (64-bit) from https://bleyer.org/icarus/"; \
	  echo "and tick 'Add to PATH' during setup. GTKWave ships with it."; \
	fi; \
	exit $$ok

clean:
	rm -rf sim
