// Charles Kowalski
// Package containing standardized definitions and structs for BRICK v1

package brick_pkg;

// Parameters
parameter XLEN = 32; // standard RV32 word len

// Definitions
typedef logic [XLEN - 1 : 0] word_t; 

// Enums
typedef enum logic [2:0] 
{
    ALU_ADD,
    ALU_SUB,
    ALU_AND, 
    ALU_OR, 
    ALU_XOR
} alu_op_t;

endpackage : brick_pkg