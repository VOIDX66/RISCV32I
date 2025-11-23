// ==============================================================================
// RISC-V MONOCICLO - INSTRUCTION MEMORY
// ------------------------------------------------------------------------------
// Memoria de solo lectura (ROM) de instrucciones.
// Sintetizable en FPGA (usa $readmemh para inicializar).
//
// Entradas:
//    Address      -> dirección del PC (en bytes)
// Salidas:
//    Instruction  -> instrucción leída (32 bits)
//
// Convención:
//    - Cada instrucción ocupa 4 bytes (32 bits).
//    - Address[31:2] se usa como índice porque las
//      instrucciones están alineadas a 4 bytes.
// ==============================================================================

`timescale 1ns / 1ps
`default_nettype none

module INSTRUCTION_MEMORY (
  input  logic [31:0] Address,      // Dirección del PC
  output logic [31:0] Instruction   // Instrucción leída
);

  // Memoria ROM de 256 palabras (1 KB de almacenamiento de instrucciones)
  logic [31:0] memory [0:255];

  // Inicialización: Carga el programa desde el archivo program.hex
  initial begin
    // $readmemh busca el archivo program.hex en el directorio de ejecución
    $readmemh("program.hex", memory);
  end

  // Lectura combinacional: La Instrucción es el contenido de la memoria indexada
  // por Address[31:2] (eliminando los 2 bits menos significativos, ya que
  // las direcciones están alineadas a 4 bytes).
  assign Instruction = memory[Address[31:2]];

endmodule // instruction_memory