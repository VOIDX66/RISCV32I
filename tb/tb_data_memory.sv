// ===================================================================
//  Testbench para DATA_MEMORY
// -------------------------------------------------------------------
//  Verifica mediante señales en simulación:
//      • Escritura de palabra completa (word)
//      • Escritura de byte en posiciones específicas
//      • Escritura de halfword según Address[1:0]
//      • Lecturas combinacionales en todos los modos:
//            - Byte / ByteU
//            - Halfword / HalfwordU
//            - Word
// ===================================================================

`timescale 1ns/1ps

module tb_DATA_MEMORY;

    // Entradas al DUT
    logic        clk;
    logic [31:0] Address;
    logic [31:0] DataWr;
    logic        DMWr;
    logic [2:0]  DMCtrl;

    // Salida del DUT
    logic [31:0] DataRd;

    // Instancia del módulo bajo prueba
    DATA_MEMORY dut (
        .clk(clk),
        .Address(Address),
        .DataWr(DataWr),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .DataRd(DataRd)
    );

    // Generación del reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Archivo VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_DATA_MEMORY);
    end

    // Estímulos sin displays
    initial begin
        Address = 0;
        DataWr  = 0;
        DMWr    = 0;
        DMCtrl  = 0;

        // -----------------------------------------------------------
        // Caso 1: Escritura de WORD en Address = 0
        //         Se espera memory[0] = AABBCCDD
        // -----------------------------------------------------------
        Address = 32'h0000_0000;
        DataWr  = 32'hAABBCCDD;
        DMWr    = 1;
        DMCtrl  = 3'b010;   // word
        #10;
        DMWr = 0;

        // Lectura WORD
        DMCtrl = 3'b010;
        #10;

        // -----------------------------------------------------------
        // Caso 2: Escritura de BYTE en offset 1
        //         Escribe EE → memoria queda: AA BB EE DD
        // -----------------------------------------------------------
        Address = 32'h0000_0001;
        DataWr  = 32'h0000_00EE;
        DMWr    = 1;
        DMCtrl  = 3'b000;   // byte
        #10;
        DMWr = 0;

        // Lectura BYTE signed
        DMCtrl = 3'b000;
        #10;

        // Lectura BYTE unsigned
        DMCtrl = 3'b100;
        #10;

        // -----------------------------------------------------------
        // Caso 3: Escritura de HALFWORD en offset 2
        //         Escribe FF55 → memoria queda: FF 55 EE DD
        // -----------------------------------------------------------
        Address = 32'h0000_0002;
        DataWr  = 32'h0000_FF55;
        DMWr    = 1;
        DMCtrl  = 3'b001;   // halfword
        #10;
        DMWr = 0;

        // Lectura HALFWORD signed
        DMCtrl = 3'b001;
        #10;

        // Lectura HALFWORD unsigned
        DMCtrl = 3'b101;
        #10;

        // -----------------------------------------------------------
        // Caso 4: Escritura de BYTE en offset 3
        //         Escribe 12 → memoria queda: 12 55 EE DD
        // -----------------------------------------------------------
        Address = 32'h0000_0003;
        DataWr  = 32'h0000_0012;
        DMWr    = 1;
        DMCtrl  = 3'b000;   // byte
        #10;
        DMWr = 0;

        // Lectura BYTE unsigned (último byte)
        DMCtrl = 3'b100;
        #10;

        $finish;
    end

endmodule
