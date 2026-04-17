// Charles Kowalski
// Test bench for common FIFO module

module fifo_tb;
    import brick_pkg::*;


localparam int DEPTH = 8;
localparam int WIDTH = XLEN;

logic [WIDTH - 1 : 0] in_din, out_dout;
logic in_push, in_pop, out_empty, out_full;
logic in_rst, in_clk;

fifo #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut 
(
    .din                (in_din),
    .dout               (out_dout),
    .push               (in_push),
    .pop                (in_pop), 
    .empty              (out_empty),
    .full               (out_full),
    .rst                (in_rst),
    .clk                (in_clk)
);

// Pulses DUT reset
task reset_dut();
    @(posedge in_clk);
    in_rst = 1'b1;
    repeat(4) @(posedge in_clk);
    in_rst = 1'b0;
endtask

initial in_clk = 0;
always #5 in_clk = ~in_clk;

initial begin
    $display("Starting FIFO Testbench");
    $dumpfile($sformatf("sim/%m.fst"));
    $dumpvars(0);

    assert(DEPTH > 1);
    in_din  = '0;
    in_push = 1'b0;
    in_pop  = 1'b0;
    in_rst  = 1'b0;

    // Test empty and full signals after reset
    reset_dut();
    assert(out_empty == 1'b1 && out_full == 1'b0) else $error("Initial reset failed!");

    // Fill the FIFO without removing anything
    in_push = 1'b1;
    for (int i = 0; i < DEPTH - 1; i++) begin
        in_din = 32'(i);
        @(posedge in_clk);
        assert(out_empty == 1'b0 && out_full == 1'b0) else $error("Fill W/o Remove: Empty or full failed after %d entries added!", i + 1);
    end
    in_din = 32'(DEPTH - 1);
    @(posedge in_clk);
    assert(out_empty == 1'b0 && out_full == 1'b1) else $error("Fill W/o Remove: Empty or full failed after %d entries added!", DEPTH); ;
    
    // Check that loaded items exit in FIFO order
    in_push = 1'b0;
    in_pop = 1'b1;
    for (int i = 0; i < DEPTH - 1; i++) begin
        @(posedge in_clk);
        assert(out_dout == WIDTH'(i) && out_empty == 1'b0 && out_full == 1'b0) else $error("Full Remove and Check: Empty or full failed after %d entries removed!", i + 1);
    end
    @(posedge in_clk);
    assert(out_dout == WIDTH'(DEPTH - 1) && out_empty == 1'b1 && out_full == 1'b0) else $error("Full Remove and Check: Empty or full failed after %d entries removed!", DEPTH);

    // Test push when full
    reset_dut();
    in_pop = 1'b0;
    in_push = 1'b1;
    for (int i = 0; i < DEPTH - 1; i++) begin // Load FIFO
        in_din = 32'(i);
        @(posedge in_clk);
        assert(out_empty == 1'b0 && out_full == 1'b0) else $error("Push when full: Empty or full failed after %d entries added!", i + 1);
    end
    in_din = 32'(DEPTH - 1);
    @(posedge in_clk);
    assert(out_empty == 1'b0 && out_full == 1'b1) else $error("Push when full: Empty or full failed after %d entries added!", DEPTH); ;
    in_din = '1;
    @(posedge in_clk);
    in_push = 1'b0;
    in_pop = 1'b1;
    for (int i = 0; i < DEPTH - 1; i++) begin // Unload FIFO and check that the illegal push isn't in the data
        @(posedge in_clk);
        assert(out_dout == WIDTH'(i) && out_empty == 1'b0 && out_full == 1'b0) else $error("Push when full: Empty or full failed after %d entries removed!", i + 1);
    end
    @(posedge in_clk);
    assert(out_dout == WIDTH'(DEPTH - 1) && out_empty == 1'b1 && out_full == 1'b0) else $error("Push when full: Empty or full failed after %d entries removed!", DEPTH);

    // Test pop when empty
    in_push = 1'b0;
    in_pop = 1'b0;
    reset_dut();
    in_pop = 1'b1;
    assert(out_empty == 1'b1 && out_full == 1'b0 && out_dout == '0) else $error("Pop when empty: failed!");

    // Simultaneous push and pop
    reset_dut();
    in_pop = 1'b0;
    in_push = 1'b1;
    for (int i = 0; i < 3; i++) begin // Load FIFO with three items
        in_din = 32'(i);
        @(posedge in_clk);
        assert(out_empty == 1'b0 && out_full == 1'b0) else $error("Simultaneous push/pop preload: flags wrong after %0d entries added!", i + 1);
    end
    in_pop = 1'b1;
    for (int i = 0; i < 3; i++) begin // Do three push+pops
        in_din = 32'(100 + i);
        @(posedge in_clk);
        assert(out_dout == 32'(i) && out_empty == 1'b0 && out_full == 1'b0) else $error("Simultaneous push/pop: wrong behavior on iteration %0d!", i);
    end
    in_push = 1'b0;
    for (int i = 0; i < 2; i++) begin
        @(posedge in_clk);
        assert(out_dout == 32'(100 + i) && out_empty == 1'b0 && out_full == 1'b0) else $error("Simultaneous push/pop drain: wrong value/flags on iteration %0d!", i);
    end
    @(posedge in_clk);
    assert(out_dout == 32'(102) && out_empty == 1'b1 && out_full == 1'b0) else $error("Simultaneous push/pop drain: final value/flags wrong!");

    $display("FIFO Testbench passed!");
    $finish;
end

endmodule : fifo_tb