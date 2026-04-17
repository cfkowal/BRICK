// Charles Kowalski
// Parameterized FIFO for BRICK

module fifo 
    import brick_pkg::*;
#(
    parameter int DEPTH = 8,
    parameter int WIDTH = XLEN
)(
    input logic [WIDTH - 1 : 0] din,
    output logic [WIDTH - 1: 0] dout,

    // Active HIGH control signals
    input logic push, pop,
    output logic empty, full, 

    input logic rst, clk // Active HIGH reset
);
    localparam PTR_WIDTH = $clog2(DEPTH) + 1; // Extra bit for wrap
    logic [PTR_WIDTH - 1 : 0] w_ptr, r_ptr;
    logic [WIDTH - 1 : 0] mem [DEPTH - 1 : 0];

    assign empty = (w_ptr == r_ptr); // FIFO is empty when pointers are equal (idx AND wrap bit)
    assign full = ((w_ptr != r_ptr) && (w_ptr[PTR_WIDTH - 2 : 0] == r_ptr[PTR_WIDTH - 2 : 0])); // FIFO is full when idx (all except MSB) bits match but wrap bit does not

    // Pointer increment for arbitrary length fifo handling
    function automatic logic [PTR_WIDTH - 1 : 0] ptr_inc (
        input logic [PTR_WIDTH - 1 : 0] ptr
    );
        logic [PTR_WIDTH - 2 : 0] fifo_idx;
        logic ptr_msb;
        
        fifo_idx = ptr[PTR_WIDTH - 2 : 0];
        ptr_msb = ptr[PTR_WIDTH - 1];
        // Flip wrap bit if idx has reached pointer depth, otherwise increment normally
        if (fifo_idx == (PTR_WIDTH - 1)'(DEPTH - 1)) 
            return {~ptr_msb, {(PTR_WIDTH - 1){1'b0}}};
        else 
            return {ptr_msb, fifo_idx + 1'b1};
    endfunction

    always_ff @(posedge clk) begin
        // Reset Logic
        if (rst == 1'b1) begin 
            w_ptr <= '0;
            r_ptr <= '0;
            dout <= '0;
        end else begin

        /*
        // Pass through (COMMENTED OUT to prevent timing bugs)
        if (push && pop && empty) begin 
            dout <= din; 
        end else begin
        */

        // Push+Pop when full
        if (push && pop && full) begin
            dout <= mem[r_ptr[PTR_WIDTH - 2 : 0]];
            mem[w_ptr[PTR_WIDTH - 2 : 0]] <= din;

            w_ptr <= ptr_inc(w_ptr);
            r_ptr <= ptr_inc(r_ptr);
            
        end else begin
            
            // Normal Push and Pop
            if (push && ~full) begin
                mem[w_ptr[PTR_WIDTH - 2 : 0]] <= din;
                w_ptr <= ptr_inc(w_ptr);
            end

            if (pop && ~empty) begin
                dout <=  mem[r_ptr[PTR_WIDTH - 2 : 0]];
                r_ptr <= ptr_inc(r_ptr);
            end else begin
                dout <= dout; // Hold
            end
        end
        end
    end
endmodule : fifo