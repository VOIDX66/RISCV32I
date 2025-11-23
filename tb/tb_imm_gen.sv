// ============================================================
// TESTBENCH para IMM_GEN
// ------------------------------------------------------------
// Prueba los diferentes formatos de inmediato (I, S, B, U, J)
// generando valores conocidos para verificar ImmExt.
// ------------------------------------------------------------

`timescale 1ns/1ps

module tb_IMM_GEN;

  // ==========================================================
  // Señales
  // ----------------------------------------------------------
  logic [24:0] Instr;   // Corresponde a Instruction[31:7]
  logic [2:0]  ImmSrc;  // Selección del tipo de inmediato
  logic [31:0] ImmExt;  // Inmediato extendido a 32 bits

  // ==========================================================
  // Instancia del módulo bajo prueba (DUT)
  // ----------------------------------------------------------
  IMM_GEN dut (
    .Instr(Instr),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
  );

  // ==========================================================
  // Archivo de ondas
  // ----------------------------------------------------------
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_IMM_GEN);
  end

  // ==========================================================
  // Estímulos
  // ----------------------------------------------------------
  initial begin
    Instr  = 25'd0;
    ImmSrc = 3'b000;
    #20;

    // --------------------------------------------------------------
    // Caso 1: I-TYPE (ImmSrc = 3'b000)
    // Immediate: instr[24:13] = 12 bits (sign-extend)
    //
    // Instr = 1000 0000 0000 0000 0000 0000 0
    // imm[11:0] = 1000_0000_0000 = 0x800 → valor = -2048
    // --------------------------------------------------------------
    Instr  = 25'b1000000000000000000000000;
    ImmSrc = 3'b000;
    // Esperado: 0xFFFF_F800 (decimal -2048)
    #20;

    // --------------------------------------------------------------
    // Caso 2: S-TYPE (ImmSrc = 3'b001)
    // immediate = {instr[24:18], instr[4:0]}
    //
    // Instr = 010101_0000000000000_10101
    // part high = 010101 = 0x15
    // part low  = 10101 = 0x15
    // imm = 010101_10101 = 0x2B5 = 693
    // --------------------------------------------------------------
    Instr  = 25'b010101_0000000000000_10101;
    ImmSrc = 3'b001;
    // Esperado: 0x0000_02B5 (693 decimal)
    #20;

    // --------------------------------------------------------------
    // Caso 3: B-TYPE (ImmSrc = 3'b101)
    //
    // immediate B se arma así:
    // imm[12]   = instr[24]
    // imm[10:5] = instr[23:18]
    // imm[4:1]  = instr[4:1]
    // imm[11]   = instr[0]
    // imm[0]    = 0
    //
    // Instr = 111111_1000000000000_010111
    //
    // Esto forma un inmediato conocido: -10
    // --------------------------------------------------------------
    Instr  = 25'b11111111000000000000010111;
    ImmSrc = 3'b101;
    // Esperado: 0xFFFF_FFF6 (decimal -10)
    #20;

    // --------------------------------------------------------------
    // Caso 4: U-TYPE (ImmSrc = 3'b010)
    //
    // immediate = {instr[24:5], 12'b0}
    //
    // Instr = 25'b0011001100110011001100110
    // imm = 0x33333 << 12 = 0x33333000
    // --------------------------------------------------------------
    Instr  = 25'b0011001100110011001100110;
    ImmSrc = 3'b010;
    // Esperado: 0x3333_3000
    #20;

    // --------------------------------------------------------------
    // Caso 5: J-TYPE (ImmSrc = 3'b110)
    //
    // immediate J se arma así:
    // imm[20]   = instr[24]
    // imm[10:1] = instr[23:14]
    // imm[11]   = instr[13]
    // imm[19:12]= instr[12:5]
    // imm[0]    = 0
    //
    // Instr = 1111001100111111111100000
    //
    // Esto debe producir un inmediato que al extenderse es -206.
    // --------------------------------------------------------------
    Instr  = 25'b1111001100111111111100000;
    ImmSrc = 3'b110;
    // Esperado: inmediato = -206  → 0xFFFF_FF32
    //  Ahora el comentario corresponde al inmediato -206 que pediste.)
    #20;

    // --------------------------------------------------------------
    #50;
    $finish;
  end

endmodule
