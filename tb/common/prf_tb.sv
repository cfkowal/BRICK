// Charles Kowalski
// Test bench for PRF module

// Notes:
// Built SPECIFICALLY for 2R + 1R PRF. Will need to be rebuilt when BRICK goes superscalar.

module prf_tb;
    import brick_pkg::*;

localparam int DEPTH = 256; 
localparam int WIDTH = XLEN;
localparam NUM_ADDR_BITS = $clog2(DEPTH);

logic in_r0_en, in_r1_en, in_w0_en;
logic out_r0_valid, out_r1_valid;

logic [$clog2(DEPTH) - 1 : 0] in_r0_addr, in_r1_addr, in_w0_addr;
logic [WIDTH - 1 : 0] in_w0_din;
logic [WIDTH - 1 : 0] out_r0_dout, out_r1_dout;

logic in_clk;

prf #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut
(
    .r0_en                      (in_r0_en),
    .r1_en                      (in_r1_en),
    .w0_en                      (in_w0_en),
    .r0_valid                   (out_r0_valid),
    .r1_valid                   (out_r1_valid),
    .r0_addr                    (in_r0_addr),
    .r1_addr                    (in_r1_addr),
    .w0_addr                    (in_w0_addr),
    .w0_din                     (in_w0_din),
    .r0_dout                    (out_r0_dout),
    .r1_dout                    (out_r1_dout),
    .clk                        (in_clk)
);

initial in_clk = 0;
always #5 in_clk = ~in_clk;


initial begin
    int r0_rand_addr, r1_rand_addr;
    $display("Starting Physical Register File Testbench");
    $dumpfile($sformatf("sim/%m.fst"));
    $dumpvars(0);

    assert(DEPTH >= 16) else $error("Testbench built to expect a PRF size of at least 16.");


    in_r0_en = 1'b0;
    in_r1_en = 1'b0;
    in_w0_en = 1'b0;
    in_r0_addr = '0;
    in_r1_addr = '0;
    in_w0_addr = '0;
    in_w0_din = '0;

    // Load register file with ascending data (mem[x] = x);
    for (int i = 0; i < DEPTH; i++) begin
        in_w0_en = 1'b1;
        in_w0_din = WIDTH'(i);
        in_w0_addr = NUM_ADDR_BITS'(i);
        @(posedge in_clk);
        assert(dut.mem[i] == WIDTH'(i)) else $error("Startup PRF load failed for address %d!", i);
    end
    in_w0_en = 1'b0;
   
    // Test Simple Read: Test all addresses, Single Read Port, Expect Address Number
    for (int i = 0; i < DEPTH; i++) begin // Test read port 0
        in_r0_en = 1'b1;
        in_r0_addr = NUM_ADDR_BITS'(i);
        #5;
        assert(out_r0_dout == WIDTH'(i)) else $error("Simple Read on Read Port 0 failed for i = %d!", i);
    end
    in_r0_en = 1'b0;

    for (int i = 0; i < DEPTH; i++) begin // Test read port 1
        in_r1_en = 1'b1;
        in_r1_addr = NUM_ADDR_BITS'(i);
        #5;
        assert(out_r1_dout == WIDTH'(i)) else $error("Simple Read on Read Port 1 failed for i = %d!", i);
    end
    in_r1_en = 1'b0;

    // Test Double Read: Test simultaneous reads of same and different addresses
    for (int i = 0; i < DEPTH; i++) begin // Test read ports 0 and 1 on the same address
        in_r0_en = 1'b1;
        in_r1_en = 1'b1;
        in_r0_addr = NUM_ADDR_BITS'(i);
        in_r1_addr = NUM_ADDR_BITS'(i);
        #5;
        assert(out_r0_dout == WIDTH'(i)) else $error("Double Read of Same Address on Read Port 0 failed for i = %d!", i);
        assert(out_r1_dout == WIDTH'(i)) else $error("Double Read of Same Address on Read Port 1 failed for i = %d!", i);
    end
    in_r0_en = 1'b0;
    in_r1_en = 1'b0;

    for (int i = 0; i < DEPTH*10; i++) begin // Test read ports 0 and 1 on random addresses
        in_r0_en = 1'b1;
        in_r1_en = 1'b1;
        r0_rand_addr = $urandom_range(DEPTH - 1, 0);
        r1_rand_addr = $urandom_range(DEPTH - 1, 0);
        in_r0_addr = NUM_ADDR_BITS'(r0_rand_addr);
        in_r1_addr = NUM_ADDR_BITS'(r1_rand_addr);
        #5;
        assert(out_r0_dout == WIDTH'(r0_rand_addr)) else $error("Double Read of Random Address on Read Port 0 failed for i = %d!", r0_rand_addr);
        assert(out_r1_dout == WIDTH'(r1_rand_addr)) else $error("Double Read of Random Address on Read Port 1 failed for i = %d!", r1_rand_addr);
    end
    in_r0_en = 1'b0;
    in_r1_en = 1'b0;


    // Test Simultaneous Read and Write of the same address
    // Test Read 0 and Write 0
    in_r0_addr = NUM_ADDR_BITS'(14);
    in_r0_en = 1'b1;
    in_w0_addr = NUM_ADDR_BITS'(14);
    in_w0_din = {WIDTH{1'b1}};
    in_w0_en = 1'b1;
    #5;
    assert(out_r0_dout == {WIDTH{1'b1}}) else $error("Simultaneous R/W of R0 and W0 Failed!");
    in_r0_en = 1'b0;
    @(posedge in_clk);
    in_w0_en = 1'b0;
    assert(dut.mem[14] == '1) else $error("Memory not written correctly after simultaneous R/W of R0 and W0!");


    // Test Read 1 and Write 0
    in_r1_addr = NUM_ADDR_BITS'(13);
    in_r1_en = 1'b1;
    in_w0_addr = NUM_ADDR_BITS'(13);
    in_w0_din = {WIDTH{1'b1}};
    in_w0_en = 1'b1;
    #5;
    assert(out_r1_dout == {WIDTH{1'b1}}) else $error("Simultaneous R/W of R1 and W0 Failed!");
    in_r1_en = 1'b0;
    @(posedge in_clk);
    in_w0_en = 1'b0;
    assert(dut.mem[13] == '1) else $error("Memory not written correctly after simultaneous R/W of R1 and W0!");


    // Test Read 0 and Read 1 and Write 0
    in_r0_addr = NUM_ADDR_BITS'(12);
    in_r0_en = 1'b1;
    in_r1_addr = NUM_ADDR_BITS'(12);
    in_r1_en = 1'b1;
    in_w0_addr = NUM_ADDR_BITS'(12);
    in_w0_din = {WIDTH{1'b1}};
    in_w0_en = 1'b1;
    #5;
    assert(out_r0_dout == {WIDTH{1'b1}}) else $error("Simultaneous R/W of R0, R1, W0 Failed for R0!");
    assert(out_r1_dout == {WIDTH{1'b1}}) else $error("Simultaneous R/W of R0, R1, W0 Failed for R1!");
    in_r1_en = 1'b0;
    in_r0_en = 1'b0;
    @(posedge in_clk);
    in_w0_en = 1'b0;
    assert(dut.mem[12] == '1) else $error("Memory not written correctly after simultaneous R/W of R1 and W0!");
    
    $display("Physical Register File Testbench passed!");
    $finish;
end


endmodule : prf_tb