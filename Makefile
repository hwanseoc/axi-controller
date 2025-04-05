# Makefile for AXI Controller Project

# Tools
VLOG = iverilog
VSIM = vvp
VERILATOR = verilator

# Directories
RTL_DIR = rtl
TB_DIR = tb
BUILD_DIR = build
WAVE_DIR = $(BUILD_DIR)/wave

# Files
RTL_FILES = $(RTL_DIR)/axi_master.sv $(RTL_DIR)/axi_slave.sv $(RTL_DIR)/axi_interface.sv
TB_FILE = $(TB_DIR)/axi_tb.sv
TOP = axi_tb
OUT_FILE = $(BUILD_DIR)/$(TOP).vvp

# Flags
VLOG_FLAGS = -g2012 -Wall -o
VERILATOR_FLAGS = --lint-only -Wall

# Make sure build directories exist
$(shell mkdir -p $(BUILD_DIR) $(WAVE_DIR))

# Default target
all: compile simulate

# Compile the design
compile:
	@echo "Compiling design..."
	$(VLOG) $(VLOG_FLAGS) $(OUT_FILE) $(RTL_FILES) $(TB_FILE)

# Run the simulation
simulate: compile
	@echo "Running simulation..."
	$(VSIM) $(OUT_FILE)

# Run simulation with waveform dump
wave: compile
	@echo "Running simulation with waveform dump..."
	$(VSIM) -fst $(OUT_FILE)

# Lint the code using Verilator
lint:
	@echo "Linting the code..."
	$(VERILATOR) $(VERILATOR_FLAGS) $(RTL_FILES)

# Clean build products
clean:
	@echo "Cleaning build products..."
	rm -rf $(BUILD_DIR)

# Help target
help:
	@echo "Makefile for AXI Controller Project"
	@echo ""
	@echo "Targets:"
	@echo "  all        : Compile and simulate (default)"
	@echo "  compile    : Compile the design"
	@echo "  simulate   : Run the simulation"
	@echo "  wave       : Run simulation with waveform dump"
	@echo "  lint       : Run Verilator lint check"
	@echo "  clean      : Remove build products"

.PHONY: all compile simulate wave lint clean help 