// ===================================================================
//  Testbench para CONTROL_UNIT
// -------------------------------------------------------------------
//  Verifica mediante señales en simulación la correcta generación de:
//      • Señales ALUASrc y ALUBSrc según tipo de instrucción
//      • Selección de ImmSrc para cada formato (I,S,B,U,J)
//      • Señales de escritura RUWr y DMWr
//      • Señales de tamaño DMCtrl para LOAD/STORE
//      • Operaciones ALUOp según funct3/funct7
//      • Codificación de BrOp para instrucciones tipo B
// ===================================================================

`timescale 1ns/1ps

module tb_CONTROL_UNIT;

    // Entradas al DUT
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Salidas del DUT
    logic        RUWr;
    logic [1:0]  RUDataWrSrc;
    logic        DMWr;
    logic [2:0]  DMCtrl;
    logic        ALUASrc;
    logic        ALUBSrc;
    logic [3:0]  ALUOp;
    logic [2:0]  ImmSrc;
    logic [4:0]  BrOp;

    // Instancia del módulo bajo prueba
    CONTROL_UNIT dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RUWr(RUWr),
        .RUDataWrSrc(RUDataWrSrc),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc),
        .BrOp(BrOp)
    );

    // Archivo VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_CONTROL_UNIT);
    end

    // Estímulos sin displays
    initial begin

        // -----------------------------------------------------------
        // Caso 1: R-TYPE (ADD)
        // -----------------------------------------------------------
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 2: I-TYPE (ADDI)
        // -----------------------------------------------------------
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 3: LOAD (LW)
        // -----------------------------------------------------------
        opcode = 7'b0000011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 4: STORE (SW)
        // -----------------------------------------------------------
        opcode = 7'b0100011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 5: BRANCH (BEQ)
        // -----------------------------------------------------------
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 6: JAL
        // -----------------------------------------------------------
        opcode = 7'b1101111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 7: JALR
        // -----------------------------------------------------------
        opcode = 7'b1100111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 8: LUI
        // -----------------------------------------------------------
        opcode = 7'b0110111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // -----------------------------------------------------------
        // Caso 9: AUIPC
        // -----------------------------------------------------------
        opcode = 7'b0010111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        $finish;
    end

endmodule
