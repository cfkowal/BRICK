// Charles Kowalski
// Physical Register File for BRICK

/* 
// Notes:
// Currently sits at 2R + 1W ports for scalar OoO operation. Will need to be updated later on when expanding to super scalar.
// This is a behavioral PRF - would be replaced by SRAM macro otherwise. Has combinational reads and registered writes. 

*/
module prf
    import brick_pkg::*;
#(
    parameter int DEPTH = 256,
    parameter int WIDTH = XLEN
)(
    // Active HIGH control signals
    input logic r0_en, r1_en, w0_en,
    output logic r0_valid, r1_valid,

    input logic [$clog2(DEPTH) - 1 : 0] r0_addr, r1_addr, w0_addr,
    input logic [WIDTH - 1 : 0] w0_din,
    output logic [WIDTH - 1 : 0] r0_dout, r1_dout,

    input logic clk
);

logic [WIDTH - 1 : 0] mem [DEPTH - 1 : 0];
logic fwd_w0_r0, fwd_w0_r1;

// Signals for forwarding logic
assign fwd_w0_r0 = (r0_addr == w0_addr && r0_en && w0_en);
assign fwd_w0_r1 = (r1_addr == w0_addr && r1_en && w0_en);

// Read Logic
always_comb begin
    r0_valid = 1'b0;
    r1_valid = 1'b0;
    r0_dout  = '0;
    r1_dout  = '0;

    if (r0_en) begin
        r0_valid = 1'b1;
        r0_dout = fwd_w0_r0 ? w0_din : mem[r0_addr];
    end

    if (r1_en) begin
        r1_valid = 1'b1;
        r1_dout = fwd_w0_r1 ? w0_din : mem[r1_addr];
    end
end  

// Write Logic
always_ff @(posedge clk) begin
    if (w0_en) mem[w0_addr] <= w0_din;
end


endmodule : prf