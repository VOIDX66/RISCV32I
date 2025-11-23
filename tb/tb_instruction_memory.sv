// ==============================================================================
// Testbench (TB) para el módulo INSTRUCTION_MEMORY
// ------------------------------------------------------------------------------
// Módulo combinacional, no requiere reloj. Verifica la lectura correcta
// en direcciones alineadas (0, 4, 8, 0x28, 0x74) y prueba el manejo de 
// direcciones no alineadas.
// **Diseñado solo para generar formas de onda (VCD).**
// ==============================================================================

`timescale 1ns / 1ps
`default_nettype none

module tb_instruction_memory;

    // --------------------------------------------------------------------------
    // 1. Declaración de Señales de Conexión y Parámetros
    // --------------------------------------------------------------------------
    localparam ADDRESS_DELAY = 30; // 30 ns de espera entre cambios de dirección para claridad

    logic [31:0] Address_in;
    logic [31:0] Instruction_out;

    // --------------------------------------------------------------------------
    // 2. Instanciación del Dispositivo Bajo Prueba (DUT)
    // --------------------------------------------------------------------------
    INSTRUCTION_MEMORY DUT (
        .Address     (Address_in),
        .Instruction (Instruction_out)
    );

    // --------------------------------------------------------------------------
    // 3. Volcado de Formas de Onda (para GTKWave)
    // --------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_instruction_memory);
    end

    // --------------------------------------------------------------------------
    // 4. Secuencia de Prueba Principal (Estímulos claros)
    // --------------------------------------------------------------------------
    initial begin
        // 1. Acceso a la primera instrucción (Dirección 0x00, Índice 0)
        // Valor esperado: 40000113
        Address_in = 32'h00000000;
        #ADDRESS_DELAY; 

        // 2. Acceso a la segunda instrucción (Dirección 0x04, Índice 1)
        // Valor esperado: 00800513
        Address_in = 32'h00000004;
        #ADDRESS_DELAY; 

        // 3. Acceso a la tercera instrucción (Dirección 0x08, Índice 2)
        // Valor esperado: 010000EF
        Address_in = 32'h00000008;
        #ADDRESS_DELAY; 
        
        // 4. Acceso a la instrucción en el medio (Dirección 0x28, Índice 10)
        // Valor esperado: 00100313
        Address_in = 32'h00000028;
        #ADDRESS_DELAY; 

        // 5. Prueba de alineación: Dirección no alineada (0x00000029)
        // Address[31:2] sigue siendo 0x28/4 = 10. Valor esperado: 00100313
        Address_in = 32'h00000029;
        #ADDRESS_DELAY; 

        // 6. Acceso a la última instrucción del programa (Dirección 0x74, Índice 29)
        // Valor esperado: 00028513
        Address_in = 32'h00000074;
        #ADDRESS_DELAY; 

        // 7. Acceso inmediatamente fuera de los límites del programa (Dirección 0x78, Índice 30)
        // Valor esperado: 00008067
        Address_in = 32'h00000078;
        #ADDRESS_DELAY; 

        // 8. Acceso a dirección de memoria muy alta, sin inicializar (Índice 200 -> Dirección 0x320)
        // Valor esperado: 00000000 (o 'x')
        Address_in = 32'h00000320;
        #ADDRESS_DELAY; 

        $finish;
    end
endmodule // tb_instruction_memory