// ============================================================
// TESTBENCH - RISC-V MONOCICLO
// ------------------------------------------------------------
// Genera:
//  - Reloj
//  - Reset al inicio
//  - Señales para GTKWave
// ============================================================

`timescale 1ns/1ps

module riscv_tb;

  // ============================
  // Señales del testbench
  // ============================
  logic clk;
  logic reset;

  // Señales de debug opcionales
  logic [31:0] INST_out;
  logic [31:0] ALURes_out;

  // ============================
  // Instancia del procesador
  // ============================
  RISCV dut (
    .clk(clk),
    .reset(reset),
    .INST_out(INST_out),
    .ALURes_out(ALURes_out)
  );

  // ============================
  // Generador de reloj
  // ============================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // periodo = 10ns
  end

  // ============================
  // Reset inicial
  // ============================
  initial begin
    reset = 1;
    #20;           // mantener reset por 20ns
    reset = 0;     // soltar reset
  end

  // ============================
  // Control de simulación
  // ============================
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, riscv_tb);

    #5000;    // duración de simulación
    $finish;
  end

endmodule
