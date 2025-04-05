// AXI4-Lite Adapter
// This module adapts a full AXI4 interface to an AXI4-Lite interface

module axi_lite_adapter #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
)(
    // Global signals
    input  logic                        clk,
    input  logic                        rst_n,
    
    // AXI4 Master Interface (connects to AXI4 slave)
    // Write Address Channel
    output logic [AXI_ID_WIDTH-1:0]     m_axi_awid,
    output logic [AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
    output logic [7:0]                  m_axi_awlen,
    output logic [2:0]                  m_axi_awsize,
    output logic [1:0]                  m_axi_awburst,
    output logic                        m_axi_awlock,
    output logic [3:0]                  m_axi_awcache,
    output logic [2:0]                  m_axi_awprot,
    output logic [3:0]                  m_axi_awqos,
    output logic [3:0]                  m_axi_awregion,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_awuser,
    output logic                        m_axi_awvalid,
    input  logic                        m_axi_awready,
    
    // Write Data Channel
    output logic [AXI_DATA_WIDTH-1:0]   m_axi_wdata,
    output logic [AXI_STRB_WIDTH-1:0]   m_axi_wstrb,
    output logic                        m_axi_wlast,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_wuser,
    output logic                        m_axi_wvalid,
    input  logic                        m_axi_wready,
    
    // Write Response Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_bid,
    input  logic [1:0]                  m_axi_bresp,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_buser,
    input  logic                        m_axi_bvalid,
    output logic                        m_axi_bready,
    
    // Read Address Channel
    output logic [AXI_ID_WIDTH-1:0]     m_axi_arid,
    output logic [AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
    output logic [7:0]                  m_axi_arlen,
    output logic [2:0]                  m_axi_arsize,
    output logic [1:0]                  m_axi_arburst,
    output logic                        m_axi_arlock,
    output logic [3:0]                  m_axi_arcache,
    output logic [2:0]                  m_axi_arprot,
    output logic [3:0]                  m_axi_arqos,
    output logic [3:0]                  m_axi_arregion,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_aruser,
    output logic                        m_axi_arvalid,
    input  logic                        m_axi_arready,
    
    // Read Data Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_rid,
    input  logic [AXI_DATA_WIDTH-1:0]   m_axi_rdata,
    input  logic [1:0]                  m_axi_rresp,
    input  logic                        m_axi_rlast,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_ruser,
    input  logic                        m_axi_rvalid,
    output logic                        m_axi_rready,
    
    // AXI4-Lite Slave Interface (connects to AXI4-Lite master)
    // Write Address Channel
    input  logic [AXI_ADDR_WIDTH-1:0]   s_axil_awaddr,
    input  logic [2:0]                  s_axil_awprot,
    input  logic                        s_axil_awvalid,
    output logic                        s_axil_awready,
    
    // Write Data Channel
    input  logic [AXI_DATA_WIDTH-1:0]   s_axil_wdata,
    input  logic [AXI_STRB_WIDTH-1:0]   s_axil_wstrb,
    input  logic                        s_axil_wvalid,
    output logic                        s_axil_wready,
    
    // Write Response Channel
    output logic [1:0]                  s_axil_bresp,
    output logic                        s_axil_bvalid,
    input  logic                        s_axil_bready,
    
    // Read Address Channel
    input  logic [AXI_ADDR_WIDTH-1:0]   s_axil_araddr,
    input  logic [2:0]                  s_axil_arprot,
    input  logic                        s_axil_arvalid,
    output logic                        s_axil_arready,
    
    // Read Data Channel
    output logic [AXI_DATA_WIDTH-1:0]   s_axil_rdata,
    output logic [1:0]                  s_axil_rresp,
    output logic                        s_axil_rvalid,
    input  logic                        s_axil_rready
);

    // Set default values for AXI4 signals not present in AXI4-Lite
    assign m_axi_awid     = '0;
    assign m_axi_awlen    = 8'h00;     // Single transfer
    assign m_axi_awsize   = $clog2(AXI_STRB_WIDTH); // Size based on data width
    assign m_axi_awburst  = 2'b01;     // INCR type
    assign m_axi_awlock   = 1'b0;      // Normal access
    assign m_axi_awcache  = 4'b0000;   // Non-cacheable and non-bufferable
    assign m_axi_awqos    = 4'b0000;   // Default QoS
    assign m_axi_awregion = 4'b0000;   // Default region
    assign m_axi_awuser   = '0;        // No user signals
    
    assign m_axi_wlast    = 1'b1;      // Always last for single transfers
    assign m_axi_wuser    = '0;        // No user signals
    
    assign m_axi_arid     = '0;
    assign m_axi_arlen    = 8'h00;     // Single transfer
    assign m_axi_arsize   = $clog2(AXI_STRB_WIDTH); // Size based on data width
    assign m_axi_arburst  = 2'b01;     // INCR type
    assign m_axi_arlock   = 1'b0;      // Normal access
    assign m_axi_arcache  = 4'b0000;   // Non-cacheable and non-bufferable
    assign m_axi_arqos    = 4'b0000;   // Default QoS
    assign m_axi_arregion = 4'b0000;   // Default region
    assign m_axi_aruser   = '0;        // No user signals
    
    // Simple pass-through for signaling channels
    // Write Address
    assign m_axi_awaddr   = s_axil_awaddr;
    assign m_axi_awprot   = s_axil_awprot;
    assign m_axi_awvalid  = s_axil_awvalid;
    assign s_axil_awready = m_axi_awready;
    
    // Write Data
    assign m_axi_wdata    = s_axil_wdata;
    assign m_axi_wstrb    = s_axil_wstrb;
    assign m_axi_wvalid   = s_axil_wvalid;
    assign s_axil_wready  = m_axi_wready;
    
    // Write Response
    assign s_axil_bresp   = m_axi_bresp;
    assign s_axil_bvalid  = m_axi_bvalid;
    assign m_axi_bready   = s_axil_bready;
    
    // Read Address
    assign m_axi_araddr   = s_axil_araddr;
    assign m_axi_arprot   = s_axil_arprot;
    assign m_axi_arvalid  = s_axil_arvalid;
    assign s_axil_arready = m_axi_arready;
    
    // Read Data
    assign s_axil_rdata   = m_axi_rdata;
    assign s_axil_rresp   = m_axi_rresp;
    assign s_axil_rvalid  = m_axi_rvalid;
    assign m_axi_rready   = s_axil_rready;

endmodule 