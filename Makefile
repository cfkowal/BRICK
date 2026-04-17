# Charles Kowalski
# BRICK Makefile

# Tools
VERILATOR = verilator

# Directories
RTL_DIR   = rtl
TB_DIR    = tb
SIM_DIR   = sim

# Sources
PKG       = $(RTL_DIR)/common/brick_pkg.sv
ALU       = $(RTL_DIR)/execute/alu.sv

RTL_SRCS  = $(PKG) $(ALU)

# Testbenches
TB_ALU    = $(TB_DIR)/execute/alu_tb.sv

TB_SRCS   = $(TB_ALU)

# Lint SV code and testbenches with Verilator
lint: $(RTL_SRCS) $(TB_ALU)
	$(VERILATOR) --lint-only --sv --assert $(RTL_SRCS) $(TB_ALU)

# Lint SV code only with Verilator
lint-rtl: $(RTL_SRCS)
	$(VERILATOR) --lint-only --sv --assert $(RTL_SRCS)

# Simulate SV with Verilator
sim: lint $(RTL_SRCS) $(TB_SRCS)
ifndef TOP
	$(error [MAKE ERROR]: TOP is not set. Usage: make sim TOP=top_module (no.sv suffix))
endif
	mkdir -p $(SIM_DIR)
	$(VERILATOR) --binary --sv --assert \
		-Mdir $(SIM_DIR) \
		--top-module $(TOP) \
		$(RTL_SRCS) $(TB_SRCS)
	$(SIM_DIR)/V$(TOP)

# Clean up
clean:
	rm -rf $(SIM_DIR)