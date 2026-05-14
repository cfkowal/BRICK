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
    $display("Starting Physical Register File Testbench");
    $dumpfile($sformatf("sim/%m.fst"));
    $dumpvars(0);

    in_r0_en = 1'b0;
    in_r1_en = 1'b0;
    in_w0_en = 1'b0;
    in_r0_addr = '0;
    in_r1_addr = '0;
    in_w0_addr = '0;
    in_w0_din = '0;

    // Simple Read: Test all addresses, single read
    for (int i = 0; i < DEPTH; i++) begin // Load RF
        in_w0_en = 1'b1;
        in_w0_din = WIDTH'(i);
        in_w0_addr = NUM_ADDR_BITS'(i);
        @(posedge in_clk);
    end
    in_w0_en = 1'b0;

    for (int i = 0; i < DEPTH; i++) begin // Test read port 1
        in_r0_en = 1'b1;
        in_r0_addr = NUM_ADDR_BITS'(i);
        #5;
        assert(out_r0_dout == WIDTH'(i)) else $error("Simple Read on Read Port 0 failed for i = %d!", i);
    end
    in_r0_en = 1'b0;

    $display("Physical Register File Testbench passed!");
    $finish;
end


endmodule : prf_tb