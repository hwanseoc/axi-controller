# AXI Controller Project

This project implements a basic set of AXI4 controllers in SystemVerilog, including both master and slave interfaces. The AXI (Advanced eXtensible Interface) protocol is a part of ARM's AMBA (Advanced Microcontroller Bus Architecture) specification and is widely used for high-performance communication in SoC designs.

## Project Structure

- `rtl/axi_master.sv`: AXI4 Master controller implementation
- `rtl/axi_slave.sv`: AXI4 Slave controller implementation with simple memory model
- `rtl/axi_interface.sv`: SystemVerilog interface definitions for AXI4 bus
- `tb/axi_tb.sv`: Testbench demonstrating master-slave interaction

## Features

### AXI Master Controller
- Supports both read and write transactions
- Supports burst transactions
- Simple command interface for user logic
- Parameterizable data/address widths

### AXI Slave Controller
- Implements all AXI channels
- Built-in memory model for storage
- Supports burst transactions
- Parameterizable memory size and interface widths

### AXI Interface
- Modular interface definitions with modports
- Support for master, slave, and monitor connections
- Fully parameterizable

## Getting Started

### Prerequisites
- SystemVerilog compatible simulator (e.g., ModelSim, VCS, Xcelium)

### Running the Testbench
The testbench `tb/axi_tb.sv` demonstrates basic functionality:

1. Single write transaction
2. Single read transaction (verifying the write)
3. Burst write transaction
4. Burst read transaction (verifying the burst write)

To run the testbench with ModelSim:

```bash
vlog rtl/axi_master.sv rtl/axi_slave.sv tb/axi_tb.sv
vsim -c axi_tb -do "run -all; quit"
```

## Customization

All modules are highly parameterizable:
- `AXI_ADDR_WIDTH`: Width of address bus (default: 32)
- `AXI_DATA_WIDTH`: Width of data bus (default: 32)
- `AXI_ID_WIDTH`: Width of ID field (default: 4)
- `AXI_USER_WIDTH`: Width of user field (default: 1)
- `MEM_SIZE`: Size of memory in the slave (default: 1024 bytes)

## Limitations

This is a basic implementation with some limitations:
- Only INCR burst type is fully supported
- No support for unaligned transfers
- Limited QoS features
- No protection for out-of-bounds memory access

## Future Enhancements

- Add support for AXI4-Lite protocol
- Add support for AXI4-Stream protocol
- Implement WRAP burst type
- Add advanced features like caching and buffering
- Add error injection capabilities for testing
- Enhanced verification environment with assertions 