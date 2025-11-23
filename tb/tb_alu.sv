// ==============================================================================
// Testbench (TB) para el módulo ALU (Arithmetic Logic Unit)
// Este módulo es combinacional, por lo que no requiere reloj.
// NOTA: Testbench simplificado para máxima compatibilidad con Icarus Verilog,
// utilizando constantes hexadecimales para números negativos (complemento a dos)
// para evitar errores de sintaxis como 'sd-5'.
// ==============================================================================

`timescale 1ns / 1ps
`default_nettype none

module tb_alu;

    // --------------------------------------------------------------------------
    // 1. Declaración de Señales de Conexión
    // --------------------------------------------------------------------------
    localparam integer WIDTH = 32;

    logic signed [WIDTH-1:0] A_in;
    logic signed [WIDTH-1:0] B_in;
    logic         [3:0]      ALUOp_in;
    logic signed [WIDTH-1:0] ALURes_out;

    // --------------------------------------------------------------------------
    // 2. Instanciación del Dispositivo Bajo Prueba (DUT)
    // --------------------------------------------------------------------------
    ALU DUT (
        .A      (A_in),
        .B      (B_in),
        .ALUOp  (ALUOp_in),
        .ALURes (ALURes_out)
    );

    // --------------------------------------------------------------------------
    // 3. Volcado de Formas de Onda (para GTKWave)
    // --------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_alu);
        $display("Generando archivo wave.vcd (ALU). Revise con GTKWave.");
    end

    // --------------------------------------------------------------------------
    // 4. Secuencia de Prueba Principal (Solo Estímulos)
    // --------------------------------------------------------------------------
    initial begin
        // Inicialización
        A_in = 32'h0;
        B_in = 32'h0;
        ALUOp_in = 4'b0000;
        #20; // Espera inicial

        // --- Caso 1: Aritmética (ADD, SUB) ---
        // ADD: 10 + 5
        A_in = 32'd10; 
        B_in = 32'd5; 
        ALUOp_in = 4'b0000;
        #10;

        // SUB: 10 - 5
        A_in = 32'd10; 
        B_in = 32'd5; 
        ALUOp_in = 4'b1000;
        #10;

        // ADD con negativos: -5 (0xFFFFFFFB) + 10
        A_in = 32'hFFFF_FFFB; // -5 en complemento a dos
        B_in = 32'd10; 
        ALUOp_in = 4'b0000;
        #10;

        // --- Caso 2: Operaciones Lógicas (AND, XOR) ---
        A_in = 32'hdeadbeef; 
        B_in = 32'h12345678;

        // AND
        ALUOp_in = 4'b0111;
        #10;

        // XOR
        ALUOp_in = 4'b0100;
        #10;

        // --- Caso 3: Desplazamiento (SLL, SRA) ---
        
        // SLL: 10 << 2
        A_in = 32'd10; 
        B_in = 32'd2; 
        ALUOp_in = 4'b0001;
        #10;

        // SRA: Desplazamiento aritmético con signo: -8 (0xFFFFFFF8) >>> 2
        A_in = 32'hFFFF_FFF8; // -8 en complemento a dos
        B_in = 32'd2; 
        ALUOp_in = 4'b1101;
        #10;

        // --- Caso 4: Comparación (SLT, SLTU) ---

        // SLT (Signed): -5 (0xFFFFFFFB) < 5 -> 1
        A_in = 32'hFFFF_FFFB; // -5 en complemento a dos
        B_in = 32'd5; 
        ALUOp_in = 4'b0010;
        #10;

        // SLTU (Unsigned): Unsigned(-5) vs 5
        A_in = 32'hFFFF_FFFB; // -5 en complemento a dos
        B_in = 32'd5; 
        ALUOp_in = 4'b0011;
        #10;

        // Fin de la simulación
        #100;
        $finish;
    end

endmodule // tb_alu