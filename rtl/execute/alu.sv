// Charles Kowalski
// Basic ALU for single cycle operations

module alu
    import brick_pkg::*;
(
    input word_t a, b,
    input alu_op_t op,
    output word_t result,
    output logic zero
);

always_comb begin
    case (op) 
        ALU_ADD : result = a + b;
        ALU_SUB : result = a - b;
        ALU_AND : result = a & b;
        ALU_OR  : result = a | b;
        ALU_XOR : result = a ^ b;
        default: result = 0;
    endcase
end

assign zero = (result == 0);

endmodule : alu