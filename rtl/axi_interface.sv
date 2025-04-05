// AXI Interface Definitions
// This file contains SystemVerilog interface definitions for AXI4

interface axi_interface #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
) (
    input logic clk,
    input logic rst_n
);

    // Write Address Channel
    logic [AXI_ID_WIDTH-1:0]     awid;
    logic [AXI_ADDR_WIDTH-1:0]   awaddr;
    logic [7:0]                  awlen;
    logic [2:0]                  awsize;
    logic [1:0]                  awburst;
    logic                        awlock;
    logic [3:0]                  awcache;
    logic [2:0]                  awprot;
    logic [3:0]                  awqos;
    logic [3:0]                  awregion;
    logic [AXI_USER_WIDTH-1:0]   awuser;
    logic                        awvalid;
    logic                        awready;
    
    // Write Data Channel
    logic [AXI_DATA_WIDTH-1:0]   wdata;
    logic [AXI_STRB_WIDTH-1:0]   wstrb;
    logic                        wlast;
    logic [AXI_USER_WIDTH-1:0]   wuser;
    logic                        wvalid;
    logic                        wready;
    
    // Write Response Channel
    logic [AXI_ID_WIDTH-1:0]     bid;
    logic [1:0]                  bresp;
    logic [AXI_USER_WIDTH-1:0]   buser;
    logic                        bvalid;
    logic                        bready;
    
    // Read Address Channel
    logic [AXI_ID_WIDTH-1:0]     arid;
    logic [AXI_ADDR_WIDTH-1:0]   araddr;
    logic [7:0]                  arlen;
    logic [2:0]                  arsize;
    logic [1:0]                  arburst;
    logic                        arlock;
    logic [3:0]                  arcache;
    logic [2:0]                  arprot;
    logic [3:0]                  arqos;
    logic [3:0]                  arregion;
    logic [AXI_USER_WIDTH-1:0]   aruser;
    logic                        arvalid;
    logic                        arready;
    
    // Read Data Channel
    logic [AXI_ID_WIDTH-1:0]     rid;
    logic [AXI_DATA_WIDTH-1:0]   rdata;
    logic [1:0]                  rresp;
    logic                        rlast;
    logic [AXI_USER_WIDTH-1:0]   ruser;
    logic                        rvalid;
    logic                        rready;

    // Master modport
    modport master (
        // Global
        input  clk,
        input  rst_n,
        
        // Write Address Channel
        output awid,
        output awaddr,
        output awlen,
        output awsize,
        output awburst,
        output awlock,
        output awcache,
        output awprot,
        output awqos,
        output awregion,
        output awuser,
        output awvalid,
        input  awready,
        
        // Write Data Channel
        output wdata,
        output wstrb,
        output wlast,
        output wuser,
        output wvalid,
        input  wready,
        
        // Write Response Channel
        input  bid,
        input  bresp,
        input  buser,
        input  bvalid,
        output bready,
        
        // Read Address Channel
        output arid,
        output araddr,
        output arlen,
        output arsize,
        output arburst,
        output arlock,
        output arcache,
        output arprot,
        output arqos,
        output arregion,
        output aruser,
        output arvalid,
        input  arready,
        
        // Read Data Channel
        input  rid,
        input  rdata,
        input  rresp,
        input  rlast,
        input  ruser,
        input  rvalid,
        output rready
    );
    
    // Slave modport
    modport slave (
        // Global
        input  clk,
        input  rst_n,
        
        // Write Address Channel
        input  awid,
        input  awaddr,
        input  awlen,
        input  awsize,
        input  awburst,
        input  awlock,
        input  awcache,
        input  awprot,
        input  awqos,
        input  awregion,
        input  awuser,
        input  awvalid,
        output awready,
        
        // Write Data Channel
        input  wdata,
        input  wstrb,
        input  wlast,
        input  wuser,
        input  wvalid,
        output wready,
        
        // Write Response Channel
        output bid,
        output bresp,
        output buser,
        output bvalid,
        input  bready,
        
        // Read Address Channel
        input  arid,
        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst,
        input  arlock,
        input  arcache,
        input  arprot,
        input  arqos,
        input  arregion,
        input  aruser,
        input  arvalid,
        output arready,
        
        // Read Data Channel
        output rid,
        output rdata,
        output rresp,
        output rlast,
        output ruser,
        output rvalid,
        input  rready
    );
    
    // Monitor modport (for verification)
    modport monitor (
        // Global
        input  clk,
        input  rst_n,
        
        // Write Address Channel
        input  awid,
        input  awaddr,
        input  awlen,
        input  awsize,
        input  awburst,
        input  awlock,
        input  awcache,
        input  awprot,
        input  awqos,
        input  awregion,
        input  awuser,
        input  awvalid,
        input  awready,
        
        // Write Data Channel
        input  wdata,
        input  wstrb,
        input  wlast,
        input  wuser,
        input  wvalid,
        input  wready,
        
        // Write Response Channel
        input  bid,
        input  bresp,
        input  buser,
        input  bvalid,
        input  bready,
        
        // Read Address Channel
        input  arid,
        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst,
        input  arlock,
        input  arcache,
        input  arprot,
        input  arqos,
        input  arregion,
        input  aruser,
        input  arvalid,
        input  arready,
        
        // Read Data Channel
        input  rid,
        input  rdata,
        input  rresp,
        input  rlast,
        input  ruser,
        input  rvalid,
        input  rready
    );

endinterface 