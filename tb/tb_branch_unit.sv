// ===================================================================
//  Testbench para BRANCH_UNIT
// -------------------------------------------------------------------
//  Verifica mediante señales en simulación:
//      • Evaluación de todas las operaciones de salto condicional
//        (BEQ, BNE, BLT, BGE, BLTU, BGEU)
//      • Activación de salto incondicional (JAL / JALR)
//      • Comportamiento por defecto cuando BrOp no corresponde
// ===================================================================

`timescale 1ns/1ps

module tb_BRANCH_UNIT;

    // Entradas al DUT
    logic [31:0] rs1, rs2;
    logic [4:0]  BrOp;

    // Salida del DUT
    logic NextPCSrc;

    // Instancia del módulo bajo prueba
    BRANCH_UNIT dut (
        .rs1(rs1),
        .rs2(rs2),
        .BrOp(BrOp),
        .NextPCSrc(NextPCSrc)
    );

    // Archivo VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_BRANCH_UNIT);
    end

    // Estímulos sin displays
    initial begin

        // -----------------------------------------------------------
        // Valores base de prueba
        // -----------------------------------------------------------
        rs1 = 32'd5;
        rs2 = 32'd5;

        // -----------------------------------------------------------
        // Caso 1: BEQ (rs1 == rs2)
        // -----------------------------------------------------------
        BrOp = 5'b01000;
        #10;

        // -----------------------------------------------------------
        // Caso 2: BNE (rs1 != rs2)
        // -----------------------------------------------------------
        rs2 = 32'd7;
        BrOp = 5'b01001;
        #10;

        // -----------------------------------------------------------
        // Caso 3: BLT (signed rs1 < rs2)
        // -----------------------------------------------------------
        rs1 = -5;
        rs2 =  3;
        BrOp = 5'b01100;
        #10;

        // -----------------------------------------------------------
        // Caso 4: BGE (signed rs1 >= rs2)
        // -----------------------------------------------------------
        rs1 = 10;
        rs2 = -1;
        BrOp = 5'b01101;
        #10;

        // -----------------------------------------------------------
        // Caso 5: BLTU (unsigned rs1 < rs2)
        // -----------------------------------------------------------
        rs1 = 32'h00000001;
        rs2 = 32'hFFFFFF00;    // muy grande como unsigned
        BrOp = 5'b01110;
        #10;

        // -----------------------------------------------------------
        // Caso 6: BGEU (unsigned rs1 >= rs2)
        // -----------------------------------------------------------
        rs1 = 32'hFFFFFF00;
        rs2 = 32'h00000001;
        BrOp = 5'b01111;
        #10;

        // -----------------------------------------------------------
        // Caso 7: Salto incondicional (JAL/JALR)
        // BrOp[4] = 1
        // -----------------------------------------------------------
        BrOp = 5'b10000;
        #10;

        // -----------------------------------------------------------
        // Caso 8: Valor por defecto (no branch)
        // -----------------------------------------------------------
        BrOp = 5'b00000;
        rs1 = 123;
        rs2 = 456;
        #10;

        $finish;
    end

endmodule
