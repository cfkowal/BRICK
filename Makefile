# Charles Kowalski
# BRICK Makefile

# Tools
VERILATOR = verilator

# Set waveform viewer based on OS
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
    WAVE_VIEWER = surfer
else
    WAVE_VIEWER = gtkwave
endif

# Directories
RTL_DIR   = rtl
TB_DIR    = tb
SIM_DIR   = sim

# Sources
PKG       = $(RTL_DIR)/common/brick_pkg.sv
FIFO      = $(RTL_DIR)/common/fifo.sv
ALU       = $(RTL_DIR)/execute/alu.sv
PRF 	  = $(RTL_DIR)/common/prf.sv


RTL_SRCS  = $(PKG) $(ALU) $(FIFO) $(PRF)

# Testbenches
TB_ALU    = $(TB_DIR)/execute/alu_tb.sv
TB_FIFO   = $(TB_DIR)/common/fifo_tb.sv
TB_PRF    = $(TB_DIR)/common/prf_tb.sv

TB_SRCS   = $(TB_ALU) $(TB_FIFO) $(TB_PRF)

# Lint SV code and testbenches with Verilator
lint: $(RTL_SRCS) $(TB_SRCS)
	$(VERILATOR) --lint-only --sv --assert -Wno-MULTITOP $(RTL_SRCS) $(TB_SRCS)

# Lint SV code only with Verilator
lint-rtl: $(RTL_SRCS)
	$(VERILATOR) --lint-only --sv --assert $(RTL_SRCS)

# Simulate a single specified tb
sim: lint $(RTL_SRCS) $(TB_SRCS)
ifndef TOP
	$(error [MAKE ERROR]: TOP is not set. Usage: make sim TOP=top_module (no.sv suffix))
endif
	mkdir -p $(SIM_DIR)
	$(VERILATOR) --binary --sv --assert \
		-Mdir $(SIM_DIR) \
		--trace-fst\
		--top-module $(TOP) \
		$(RTL_SRCS) $(TB_SRCS)
	$(SIM_DIR)/V$(TOP)

# Simulates a single specified tb, dump traces, open in wave viewer
sim-wave: lint $(RTL_SRCS) $(TB_SRCS)
ifndef TOP
	$(error [MAKE ERROR]: TOP is not set. Usage: make sim-wave TOP=top_module (no.sv suffix))
endif
	mkdir -p $(SIM_DIR)
	$(VERILATOR) --binary --sv --assert \
		--trace-fst \
		-Mdir $(SIM_DIR) \
		--top-module $(TOP) \
		$(RTL_SRCS) $(TB_SRCS)
	$(SIM_DIR)/V$(TOP); $(WAVE_VIEWER) $(SIM_DIR)/$(TOP).fst

# Clean up
clean:
	rm -rf $(SIM_DIR)