// AXI Slave Controller
// This module implements an AXI4 Slave interface

module axi_slave #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
    parameter MEM_SIZE       = 1024  // Size of internal memory in bytes
)(
    // Global signals
    input  logic                        clk,
    input  logic                        rst_n,
    
    // AXI Write Address Channel
    input  logic [AXI_ID_WIDTH-1:0]     s_axi_awid,
    input  logic [AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic [7:0]                  s_axi_awlen,
    input  logic [2:0]                  s_axi_awsize,
    input  logic [1:0]                  s_axi_awburst,
    input  logic                        s_axi_awlock,
    input  logic [3:0]                  s_axi_awcache,
    input  logic [2:0]                  s_axi_awprot,
    input  logic [3:0]                  s_axi_awqos,
    input  logic [3:0]                  s_axi_awregion,
    input  logic [AXI_USER_WIDTH-1:0]   s_axi_awuser,
    input  logic                        s_axi_awvalid,
    output logic                        s_axi_awready,
    
    // AXI Write Data Channel
    input  logic [AXI_DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic [AXI_STRB_WIDTH-1:0]   s_axi_wstrb,
    input  logic                        s_axi_wlast,
    input  logic [AXI_USER_WIDTH-1:0]   s_axi_wuser,
    input  logic                        s_axi_wvalid,
    output logic                        s_axi_wready,
    
    // AXI Write Response Channel
    output logic [AXI_ID_WIDTH-1:0]     s_axi_bid,
    output logic [1:0]                  s_axi_bresp,
    output logic [AXI_USER_WIDTH-1:0]   s_axi_buser,
    output logic                        s_axi_bvalid,
    input  logic                        s_axi_bready,
    
    // AXI Read Address Channel
    input  logic [AXI_ID_WIDTH-1:0]     s_axi_arid,
    input  logic [AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic [7:0]                  s_axi_arlen,
    input  logic [2:0]                  s_axi_arsize,
    input  logic [1:0]                  s_axi_arburst,
    input  logic                        s_axi_arlock,
    input  logic [3:0]                  s_axi_arcache,
    input  logic [2:0]                  s_axi_arprot,
    input  logic [3:0]                  s_axi_arqos,
    input  logic [3:0]                  s_axi_arregion,
    input  logic [AXI_USER_WIDTH-1:0]   s_axi_aruser,
    input  logic                        s_axi_arvalid,
    output logic                        s_axi_arready,
    
    // AXI Read Data Channel
    output logic [AXI_ID_WIDTH-1:0]     s_axi_rid,
    output logic [AXI_DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]                  s_axi_rresp,
    output logic                        s_axi_rlast,
    output logic [AXI_USER_WIDTH-1:0]   s_axi_ruser,
    output logic                        s_axi_rvalid,
    input  logic                        s_axi_rready
);

    // Initialize memory to known values for simulation (all zeros)
    initial begin
        for (int i = 0; i < MEM_SIZE; i++) begin
            memory[i] = 8'h00;
        end
    end

    // Memory implementation using a simple array
    logic [7:0] memory [0:MEM_SIZE-1];
    
    // State machine states
    typedef enum logic [2:0] {
        IDLE,
        WRITE_DATA,
        WRITE_RESP,
        READ_DATA
    } state_t;
    
    state_t state, next_state;
    
    // Store transaction information
    logic [AXI_ID_WIDTH-1:0]   req_id;
    logic [AXI_ADDR_WIDTH-1:0] req_addr;
    logic [7:0]                req_len;
    logic [2:0]                req_size;
    logic [1:0]                req_burst;
    
    // Transaction counter
    logic [7:0] txn_count;
    
    // Current address for burst transactions
    logic [AXI_ADDR_WIDTH-1:0] curr_addr;
    
    // Set default values for unused signals
    assign s_axi_buser = '0;
    assign s_axi_ruser = '0;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            txn_count <= '0;
            req_id <= '0;
            req_addr <= '0;
            req_len <= '0;
            req_size <= '0;
            req_burst <= '0;
            curr_addr <= '0;
        end else begin
            state <= next_state;
            
            // Store transaction information
            if (state == IDLE) begin
                if (s_axi_awvalid && s_axi_awready) begin
                    req_id <= s_axi_awid;
                    req_addr <= s_axi_awaddr;
                    req_len <= s_axi_awlen;
                    req_size <= s_axi_awsize;
                    req_burst <= s_axi_awburst;
                    txn_count <= '0;
                    curr_addr <= s_axi_awaddr;
                end else if (s_axi_arvalid && s_axi_arready) begin
                    req_id <= s_axi_arid;
                    req_addr <= s_axi_araddr;
                    req_len <= s_axi_arlen;
                    req_size <= s_axi_arsize;
                    req_burst <= s_axi_arburst;
                    txn_count <= '0;
                    curr_addr <= s_axi_araddr;
                end
            end
            
            // Update transaction counter and address for bursts
            if ((state == WRITE_DATA && s_axi_wvalid && s_axi_wready) ||
                (state == READ_DATA && s_axi_rvalid && s_axi_rready)) begin
                if (txn_count < req_len) begin
                    txn_count <= txn_count + 1;
                    
                    // Update address for next beat in burst
                    if (req_burst == 2'b01) begin // INCR burst
                        curr_addr <= curr_addr + (1 << req_size);
                    end
                    // WRAP bursts not implemented in this basic version
                end
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (s_axi_awvalid && s_axi_awready)
                    next_state = WRITE_DATA;
                else if (s_axi_arvalid && s_axi_arready)
                    next_state = READ_DATA;
            end
            
            WRITE_DATA: begin
                if (s_axi_wvalid && s_axi_wready && s_axi_wlast)
                    next_state = WRITE_RESP;
            end
            
            WRITE_RESP: begin
                if (s_axi_bvalid && s_axi_bready)
                    next_state = IDLE;
            end
            
            READ_DATA: begin
                // Move to IDLE after the last data beat is sent and acknowledged
                if (s_axi_rvalid && s_axi_rready && s_axi_rlast)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // AXI interface control
    always_comb begin
        // Default values
        s_axi_awready = 1'b0;
        s_axi_wready = 1'b0;
        s_axi_bvalid = 1'b0;
        s_axi_bid = req_id;
        s_axi_bresp = 2'b00; // OKAY
        
        s_axi_arready = 1'b0;
        s_axi_rvalid = 1'b0;
        s_axi_rid = req_id;
        s_axi_rresp = 2'b00; // OKAY
        s_axi_rlast = (txn_count == req_len);
        
        // Read data comes from memory
        s_axi_rdata = '0;
        for (int i = 0; i < AXI_DATA_WIDTH/8; i++) begin
            if (curr_addr + i < MEM_SIZE) begin
                s_axi_rdata[i*8 +: 8] = memory[curr_addr + i];
            end
        end
        
        case (state)
            IDLE: begin
                s_axi_awready = 1'b1;
                s_axi_arready = 1'b1;
            end
            
            WRITE_DATA: begin
                s_axi_wready = 1'b1;
                
                // Write data to memory when valid
                if (s_axi_wvalid) begin
                    for (int i = 0; i < AXI_DATA_WIDTH/8; i++) begin
                        if (s_axi_wstrb[i] && (curr_addr + i < MEM_SIZE)) begin
                            memory[curr_addr + i] = s_axi_wdata[i*8 +: 8];
                        end
                    end
                end
            end
            
            WRITE_RESP: begin
                s_axi_bvalid = 1'b1;
            end
            
            READ_DATA: begin
                // Always attempt to provide valid data in READ_DATA state
                s_axi_rvalid = 1'b1;
            end
            
            default: begin
                // Default values already assigned
            end
        endcase
    end

endmodule 