// AXI Master Controller
// This module implements an AXI4 Master interface

module axi_master #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
)(
    // Global signals
    input  logic                        clk,
    input  logic                        rst_n,
    
    // Command interface (from user logic)
    input  logic                        cmd_valid,
    output logic                        cmd_ready,
    input  logic                        cmd_write,
    input  logic [AXI_ADDR_WIDTH-1:0]   cmd_addr,
    input  logic [AXI_DATA_WIDTH-1:0]   cmd_wdata,
    input  logic [AXI_STRB_WIDTH-1:0]   cmd_wstrb,
    input  logic [7:0]                  cmd_len,
    output logic [AXI_DATA_WIDTH-1:0]   cmd_rdata,
    output logic                        cmd_rvalid,
    input  logic                        cmd_rready,
    output logic [1:0]                  cmd_resp,
    
    // AXI Write Address Channel
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
    
    // AXI Write Data Channel
    output logic [AXI_DATA_WIDTH-1:0]   m_axi_wdata,
    output logic [AXI_STRB_WIDTH-1:0]   m_axi_wstrb,
    output logic                        m_axi_wlast,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_wuser,
    output logic                        m_axi_wvalid,
    input  logic                        m_axi_wready,
    
    // AXI Write Response Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_bid,
    input  logic [1:0]                  m_axi_bresp,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_buser,
    input  logic                        m_axi_bvalid,
    output logic                        m_axi_bready,
    
    // AXI Read Address Channel
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
    
    // AXI Read Data Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_rid,
    input  logic [AXI_DATA_WIDTH-1:0]   m_axi_rdata,
    input  logic [1:0]                  m_axi_rresp,
    input  logic                        m_axi_rlast,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_ruser,
    input  logic                        m_axi_rvalid,
    output logic                        m_axi_rready
);

    // State machine states
    typedef enum logic [2:0] {
        IDLE,
        WRITE_ADDR,
        WRITE_DATA,
        WRITE_RESP,
        READ_ADDR,
        READ_DATA
    } state_t;
    
    state_t state, next_state;
    
    // Transaction counter
    logic [7:0] txn_count;
    
    // Default assignments
    assign m_axi_awid     = '0;
    assign m_axi_awsize   = $clog2(AXI_STRB_WIDTH);  // Size based on data width
    assign m_axi_awburst  = 2'b01;  // INCR burst type
    assign m_axi_awlock   = 1'b0;   // Normal access
    assign m_axi_awcache  = 4'b0000; // Non-cacheable and non-bufferable
    assign m_axi_awprot   = 3'b000;  // Unprivileged, secure, data access
    assign m_axi_awqos    = 4'b0000; // Default QoS
    assign m_axi_awregion = 4'b0000; // Default region
    assign m_axi_awuser   = '0;      // No user signals
    
    assign m_axi_wuser    = '0;      // No user signals
    
    assign m_axi_arid     = '0;
    assign m_axi_arsize   = $clog2(AXI_STRB_WIDTH);  // Size based on data width
    assign m_axi_arburst  = 2'b01;  // INCR burst type
    assign m_axi_arlock   = 1'b0;   // Normal access
    assign m_axi_arcache  = 4'b0000; // Non-cacheable and non-bufferable
    assign m_axi_arprot   = 3'b000;  // Unprivileged, secure, data access
    assign m_axi_arqos    = 4'b0000; // Default QoS
    assign m_axi_arregion = 4'b0000; // Default region
    assign m_axi_aruser   = '0;      // No user signals
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            txn_count <= '0;
        end else begin
            state <= next_state;
            
            // Update transaction counter
            if (state == IDLE) begin
                txn_count <= cmd_len;
            end else if ((state == WRITE_DATA && m_axi_wready && m_axi_wvalid) || 
                         (state == READ_DATA && m_axi_rready && m_axi_rvalid)) begin
                if (txn_count > 0)
                    txn_count <= txn_count - 1;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (cmd_valid) begin
                    if (cmd_write)
                        next_state = WRITE_ADDR;
                    else
                        next_state = READ_ADDR;
                end
            end
            
            WRITE_ADDR: begin
                if (m_axi_awready && m_axi_awvalid)
                    next_state = WRITE_DATA;
            end
            
            WRITE_DATA: begin
                if (m_axi_wready && m_axi_wvalid && m_axi_wlast)
                    next_state = WRITE_RESP;
            end
            
            WRITE_RESP: begin
                if (m_axi_bvalid && m_axi_bready)
                    next_state = IDLE;
            end
            
            READ_ADDR: begin
                if (m_axi_arready && m_axi_arvalid)
                    next_state = READ_DATA;
            end
            
            READ_DATA: begin
                if (m_axi_rvalid && m_axi_rready && m_axi_rlast)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Command interface
    assign cmd_ready = (state == IDLE);
    
    // AXI interface control
    always_comb begin
        // Default values
        m_axi_awvalid = 1'b0;
        m_axi_awaddr = cmd_addr;
        m_axi_awlen = cmd_len;
        
        m_axi_wvalid = 1'b0;
        m_axi_wdata = cmd_wdata;
        m_axi_wstrb = cmd_wstrb;
        m_axi_wlast = (txn_count == 0);
        
        m_axi_bready = 1'b0;
        
        m_axi_arvalid = 1'b0;
        m_axi_araddr = cmd_addr;
        m_axi_arlen = cmd_len;
        
        m_axi_rready = 1'b0;
        
        cmd_rvalid = 1'b0;
        cmd_rdata = m_axi_rdata;
        cmd_resp = 2'b00;
        
        case (state)
            WRITE_ADDR: begin
                m_axi_awvalid = 1'b1;
            end
            
            WRITE_DATA: begin
                m_axi_wvalid = 1'b1;
            end
            
            WRITE_RESP: begin
                m_axi_bready = 1'b1;
                if (m_axi_bvalid)
                    cmd_resp = m_axi_bresp;
            end
            
            READ_ADDR: begin
                m_axi_arvalid = 1'b1;
            end
            
            READ_DATA: begin
                m_axi_rready = 1'b1;
                if (m_axi_rvalid) begin
                    cmd_rvalid = 1'b1;
                    cmd_resp = m_axi_rresp;
                end
            end
            
            default: begin
                // Default values already assigned
            end
        endcase
    end

endmodule 