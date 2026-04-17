// Charles Kowalski
// Test bench for ALU unit

module alu_tb;
    import brick_pkg::*;

word_t in_a, in_b, out_result;
alu_op_t in_op;
logic out_zero;


alu dut(
    .a          (in_a),
    .b          (in_b),
    .op         (in_op),
    .result     (out_result),
    .zero       (out_zero)
);


initial begin
    $display("Starting ALU Testbench");
    
    // Test ADD
    in_op = ALU_ADD;

    in_a = '0; 
    in_b = '0;
    #5;
    assert(out_result == 32'b0 && out_zero == 1'b1) else $error("Add 0 + 0 failed!");
    
    in_a = '1;
    in_b = '1;
    #5;
    assert(out_result == 32'hFFFFFFFE && out_zero == 1'b0) else $error("Add -1 + -1 failed!");

    in_a = 32'd8;
    in_b = 32'd47;
    #5;
    assert(out_result == 32'd55 && out_zero == 1'b0) else $error("Add 8 + 47 failed!");

    // Test SUB
    in_op = ALU_SUB;

    in_a = '0; 
    in_b = '0;
    #5;
    assert(out_result == 32'b0 && out_zero == 1'b1) else $error("Sub 0 - 0 failed!");

    in_a = '1;
    in_b = '1;
    #5;
    assert(out_result == 32'd0 && out_zero == 1'b1) else $error("Sub -1 - -1 failed!");

    in_a = 32'd18;
    in_b = 32'd9;
    #5;
    assert(out_result == 32'd9 && out_zero == 1'b0) else $error("Sub 18 - 9 failed!");

    in_a = 32'd20;
    in_b = 32'd40;
    #5;
    assert(out_result == 32'hFFFFFFEC && out_zero == 1'b0) else $error("Sub 20 - 40 failed!");

    // ALU_AND
    in_op = ALU_AND;
    
    in_a = '1;
    in_b = '0;
    #5;
    assert(out_result == 32'd0 && out_zero == 1'b1) else $error("AND '1 && '0 failed!");

    in_a = '1;
    in_b = '1;
    #5;
    assert(out_result == 32'hFFFFFFFF && out_zero == 1'b0) else $error("AND '1 && '1 failed!");

    // ALU_OR
    in_op = ALU_OR;
    
    in_a = '1;
    in_b = '0;
    #5;
    assert(out_result == 32'hFFFFFFFF && out_zero == 1'b0) else $error("OR '1 && '0 failed!");

    in_a = '0;
    in_b = '0;
    #5;
    assert(out_result == 32'd0 && out_zero == 1'b1) else $error("AND '0 && '0 failed!");

    // ALU_XOR
    in_op = ALU_XOR;
    in_a = '1;
    in_b = '1;
    #5;
    assert(out_result == 32'd0 && out_zero == 1'b1) else $error("XOR '1 ^ '1 failed!");

    in_a = 32'hAAAAAAAA;
    in_b = 32'h55555555;
    #5;
    assert(out_result == 32'hFFFFFFFF && out_zero == 1'b0) else $error("XOR alternating bits failed!");

    $display("ALU Testbench passed!");
    $finish;
end

endmodule