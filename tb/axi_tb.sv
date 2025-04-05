`timescale 1ns/1ps

module axi_tb;
    // Parameters
    localparam AXI_ADDR_WIDTH = 32;
    localparam AXI_DATA_WIDTH = 32;
    localparam AXI_ID_WIDTH   = 4;
    localparam AXI_USER_WIDTH = 1;
    localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
    localparam MEM_SIZE       = 1024;
    
    // Clock and reset
    logic clk = 0;
    logic rst_n = 0;
    
    // Generate clock
    always #5 clk = ~clk;
    
    // Command interface signals (from test to master)
    logic                        cmd_valid;
    logic                        cmd_ready;
    logic                        cmd_write;
    logic [AXI_ADDR_WIDTH-1:0]   cmd_addr;
    logic [AXI_DATA_WIDTH-1:0]   cmd_wdata;
    logic [AXI_STRB_WIDTH-1:0]   cmd_wstrb;
    logic [7:0]                  cmd_len;
    logic [AXI_DATA_WIDTH-1:0]   cmd_rdata;
    logic                        cmd_rvalid;
    logic                        cmd_rready;
    logic [1:0]                  cmd_resp;
    
    // AXI signals
    // Write Address Channel
    logic [AXI_ID_WIDTH-1:0]     axi_awid;
    logic [AXI_ADDR_WIDTH-1:0]   axi_awaddr;
    logic [7:0]                  axi_awlen;
    logic [2:0]                  axi_awsize;
    logic [1:0]                  axi_awburst;
    logic                        axi_awlock;
    logic [3:0]                  axi_awcache;
    logic [2:0]                  axi_awprot;
    logic [3:0]                  axi_awqos;
    logic [3:0]                  axi_awregion;
    logic [AXI_USER_WIDTH-1:0]   axi_awuser;
    logic                        axi_awvalid;
    logic                        axi_awready;
    
    // Write Data Channel
    logic [AXI_DATA_WIDTH-1:0]   axi_wdata;
    logic [AXI_STRB_WIDTH-1:0]   axi_wstrb;
    logic                        axi_wlast;
    logic [AXI_USER_WIDTH-1:0]   axi_wuser;
    logic                        axi_wvalid;
    logic                        axi_wready;
    
    // Write Response Channel
    logic [AXI_ID_WIDTH-1:0]     axi_bid;
    logic [1:0]                  axi_bresp;
    logic [AXI_USER_WIDTH-1:0]   axi_buser;
    logic                        axi_bvalid;
    logic                        axi_bready;
    
    // Read Address Channel
    logic [AXI_ID_WIDTH-1:0]     axi_arid;
    logic [AXI_ADDR_WIDTH-1:0]   axi_araddr;
    logic [7:0]                  axi_arlen;
    logic [2:0]                  axi_arsize;
    logic [1:0]                  axi_arburst;
    logic                        axi_arlock;
    logic [3:0]                  axi_arcache;
    logic [2:0]                  axi_arprot;
    logic [3:0]                  axi_arqos;
    logic [3:0]                  axi_arregion;
    logic [AXI_USER_WIDTH-1:0]   axi_aruser;
    logic                        axi_arvalid;
    logic                        axi_arready;
    
    // Read Data Channel
    logic [AXI_ID_WIDTH-1:0]     axi_rid;
    logic [AXI_DATA_WIDTH-1:0]   axi_rdata;
    logic [1:0]                  axi_rresp;
    logic                        axi_rlast;
    logic [AXI_USER_WIDTH-1:0]   axi_ruser;
    logic                        axi_rvalid;
    logic                        axi_rready;
    
    // Instantiate AXI master
    axi_master #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH)
    ) master (
        .clk(clk),
        .rst_n(rst_n),
        
        // Command interface
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_write(cmd_write),
        .cmd_addr(cmd_addr),
        .cmd_wdata(cmd_wdata),
        .cmd_wstrb(cmd_wstrb),
        .cmd_len(cmd_len),
        .cmd_rdata(cmd_rdata),
        .cmd_rvalid(cmd_rvalid),
        .cmd_rready(cmd_rready),
        .cmd_resp(cmd_resp),
        
        // AXI Write Address Channel
        .m_axi_awid(axi_awid),
        .m_axi_awaddr(axi_awaddr),
        .m_axi_awlen(axi_awlen),
        .m_axi_awsize(axi_awsize),
        .m_axi_awburst(axi_awburst),
        .m_axi_awlock(axi_awlock),
        .m_axi_awcache(axi_awcache),
        .m_axi_awprot(axi_awprot),
        .m_axi_awqos(axi_awqos),
        .m_axi_awregion(axi_awregion),
        .m_axi_awuser(axi_awuser),
        .m_axi_awvalid(axi_awvalid),
        .m_axi_awready(axi_awready),
        
        // AXI Write Data Channel
        .m_axi_wdata(axi_wdata),
        .m_axi_wstrb(axi_wstrb),
        .m_axi_wlast(axi_wlast),
        .m_axi_wuser(axi_wuser),
        .m_axi_wvalid(axi_wvalid),
        .m_axi_wready(axi_wready),
        
        // AXI Write Response Channel
        .m_axi_bid(axi_bid),
        .m_axi_bresp(axi_bresp),
        .m_axi_buser(axi_buser),
        .m_axi_bvalid(axi_bvalid),
        .m_axi_bready(axi_bready),
        
        // AXI Read Address Channel
        .m_axi_arid(axi_arid),
        .m_axi_araddr(axi_araddr),
        .m_axi_arlen(axi_arlen),
        .m_axi_arsize(axi_arsize),
        .m_axi_arburst(axi_arburst),
        .m_axi_arlock(axi_arlock),
        .m_axi_arcache(axi_arcache),
        .m_axi_arprot(axi_arprot),
        .m_axi_arqos(axi_arqos),
        .m_axi_arregion(axi_arregion),
        .m_axi_aruser(axi_aruser),
        .m_axi_arvalid(axi_arvalid),
        .m_axi_arready(axi_arready),
        
        // AXI Read Data Channel
        .m_axi_rid(axi_rid),
        .m_axi_rdata(axi_rdata),
        .m_axi_rresp(axi_rresp),
        .m_axi_rlast(axi_rlast),
        .m_axi_ruser(axi_ruser),
        .m_axi_rvalid(axi_rvalid),
        .m_axi_rready(axi_rready)
    );
    
    // Instantiate AXI slave
    axi_slave #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) slave (
        .clk(clk),
        .rst_n(rst_n),
        
        // AXI Write Address Channel
        .s_axi_awid(axi_awid),
        .s_axi_awaddr(axi_awaddr),
        .s_axi_awlen(axi_awlen),
        .s_axi_awsize(axi_awsize),
        .s_axi_awburst(axi_awburst),
        .s_axi_awlock(axi_awlock),
        .s_axi_awcache(axi_awcache),
        .s_axi_awprot(axi_awprot),
        .s_axi_awqos(axi_awqos),
        .s_axi_awregion(axi_awregion),
        .s_axi_awuser(axi_awuser),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),
        
        // AXI Write Data Channel
        .s_axi_wdata(axi_wdata),
        .s_axi_wstrb(axi_wstrb),
        .s_axi_wlast(axi_wlast),
        .s_axi_wuser(axi_wuser),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_wready(axi_wready),
        
        // AXI Write Response Channel
        .s_axi_bid(axi_bid),
        .s_axi_bresp(axi_bresp),
        .s_axi_buser(axi_buser),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready),
        
        // AXI Read Address Channel
        .s_axi_arid(axi_arid),
        .s_axi_araddr(axi_araddr),
        .s_axi_arlen(axi_arlen),
        .s_axi_arsize(axi_arsize),
        .s_axi_arburst(axi_arburst),
        .s_axi_arlock(axi_arlock),
        .s_axi_arcache(axi_arcache),
        .s_axi_arprot(axi_arprot),
        .s_axi_arqos(axi_arqos),
        .s_axi_arregion(axi_arregion),
        .s_axi_aruser(axi_aruser),
        .s_axi_arvalid(axi_arvalid),
        .s_axi_arready(axi_arready),
        
        // AXI Read Data Channel
        .s_axi_rid(axi_rid),
        .s_axi_rdata(axi_rdata),
        .s_axi_rresp(axi_rresp),
        .s_axi_rlast(axi_rlast),
        .s_axi_ruser(axi_ruser),
        .s_axi_rvalid(axi_rvalid),
        .s_axi_rready(axi_rready)
    );
    
    // Test sequence
    initial begin
        // Initialize inputs
        cmd_valid = 0;
        cmd_write = 0;
        cmd_addr = 0;
        cmd_wdata = 0;
        cmd_wstrb = 0;
        cmd_len = 0;
        cmd_rready = 0;
        
        // Reset
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        
        // Test 1: Single write transaction
        $display("Test 1: Single write transaction at time %0t", $time);
        cmd_valid = 1;
        cmd_write = 1;
        cmd_addr = 32'h00000010;
        cmd_wdata = 32'hABCD1234;
        cmd_wstrb = 4'b1111;
        cmd_len = 0; // Single transfer
        
        // Wait for command to be accepted
        wait(cmd_ready && cmd_valid);
        @(posedge clk);
        cmd_valid = 0;
        
        // Wait for transaction to complete
        wait(master.state == master.IDLE);
        @(posedge clk);
        
        // Test 2: Single read transaction
        $display("Test 2: Single read transaction at time %0t", $time);
        cmd_valid = 1;
        cmd_write = 0;
        cmd_addr = 32'h00000010;
        cmd_len = 0; // Single transfer
        cmd_rready = 1;
        
        // Wait for command to be accepted
        wait(cmd_ready && cmd_valid);
        @(posedge clk);
        cmd_valid = 0;
        
        // Wait for read data
        wait(cmd_rvalid);
        $display("Read data: %h (Expected: %h)", cmd_rdata, 32'hABCD1234);
        
        // Test 3: Burst write (4 transfers)
        $display("Test 3: Burst write transaction at time %0t", $time);
        @(posedge clk);
        cmd_valid = 1;
        cmd_write = 1;
        cmd_addr = 32'h00000020;
        cmd_len = 3; // 4 transfers (len = n-1)
        
        // First data beat
        cmd_wdata = 32'h11111111;
        cmd_wstrb = 4'b1111;
        
        // Wait for command to be accepted
        wait(cmd_ready && cmd_valid);
        @(posedge clk);
        cmd_valid = 0;
        
        // Subsequent data beats
        @(posedge clk);
        wait(master.state == master.WRITE_DATA);
        
        // Second data beat
        cmd_wdata = 32'h22222222;
        @(posedge clk);
        
        // Third data beat
        cmd_wdata = 32'h33333333;
        @(posedge clk);
        
        // Fourth data beat
        cmd_wdata = 32'h44444444;
        @(posedge clk);
        
        // Wait for transaction to complete
        wait(master.state == master.IDLE);
        @(posedge clk);
        
        // Test 4: Burst read (4 transfers)
        $display("Test 4: Burst read transaction at time %0t", $time);
        cmd_valid = 1;
        cmd_write = 0;
        cmd_addr = 32'h00000020;
        cmd_len = 3; // 4 transfers (len = n-1)
        cmd_rready = 1;
        
        // Wait for command to be accepted
        wait(cmd_ready && cmd_valid);
        @(posedge clk);
        cmd_valid = 0;
        
        // Wait for all read data
        repeat(6) @(posedge clk);
        
        // End simulation
        repeat(10) @(posedge clk);
        $display("Simulation finished at time %0t", $time);
        $finish;
    end
    
    // Monitor transactions
    always @(posedge clk) begin
        if (cmd_rvalid && cmd_rready) begin
            $display("Read data received: %h at time %0t", cmd_rdata, $time);
        end
    end
    
endmodule 