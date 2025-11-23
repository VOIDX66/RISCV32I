// ============================================================
// RISC-V MONOCICLO - UNIDAD DE GENERACIÓN DE INMEDIATOS (IMM_GEN)
// ------------------------------------------------------------
// Extiende el campo inmediato de 32 bits, usando la entrada
// Instr[24:0] que corresponde a los bits [31:7] de la instrucción
// completa (Instruction[31:7]).
// ------------------------------------------------------------
// ImmSrc codes:
// 3'b000: I-Type (R-Imm, Load, JALR)
// 3'b001: S-Type (Store)
// 3'b010: U-Type (LUI, AUIPC)
// 3'b101: B-Type (Branch)
// 3'b110: J-Type (JAL)
// ============================================================

module IMM_GEN(
  input  logic [24:0] Instr,     // Instrucción sin opcode (bits [31:7] de la instr. original)
  input  logic [2:0]  ImmSrc,    // Selecciona tipo de inmediato
  output logic [31:0] ImmExt    // Inmediato de 32 bits extendido
);

  // Variables internas para la construcción de cada tipo de inmediato
  logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

  // ----------------------------------------------------------------
  // LÓGICA DE CONSTRUCCIÓN Y EXTESIÓN DE SIGNO (Basada en Instr[24:0])
  // ----------------------------------------------------------------
  
  // I-TYPE (ImmSrc = 3'b000) - Inmediato de 12 bits sign-extended
  // Instrucción original: [31:20] -> Campo inmediato
  // Mapeo a Instr[24:0]: El bit de signo es Instr[24], el resto es Instr[23:13]
  assign imm_i = {{20{Instr[24]}}, Instr[24:13]};

  // S-TYPE (ImmSrc = 3'b001) - Inmediato de 12 bits sign-extended (Store)
  // Instrucción original: [31:25] (bits altos) y [11:7] (bits bajos)
  // Mapeo a Instr[24:0]: Signo (Instr[24]), altos (Instr[23:18]), bajos (Instr[4:0])
  assign imm_s = {{20{Instr[24]}}, Instr[23:18], Instr[4:0]};

  // B-TYPE (ImmSrc = 3'b101) - Inmediato de 13 bits (Branch)
  // Instrucción original: [31] (Signo), [7], [30:25], [11:8], 1'b0
  // Mapeo a Instr[24:0]: {Signo=Instr[24], bit[11]=Instr[0], bits[10:5]=Instr[23:18], bits[4:1]=Instr[4:1], 1'b0}
  // El campo final tiene 13 bits, que se extienden a 32 bits (19 bits de signo)
  assign imm_b = {{19{Instr[24]}}, Instr[24], Instr[0], 
                  Instr[23:18], Instr[4:1], 1'b0};

  // U-TYPE (ImmSrc = 3'b010) - Inmediato de 20 bits (LUI/AUIPC)
  // Instrucción original: [31:12] -> Campo inmediato
  // Mapeo a Instr[24:0]: Instr[24:5]
  assign imm_u = {Instr[24:5], 12'b0};

  // J-TYPE (ImmSrc = 3'b110) - Inmediato de 21 bits (JAL)
  // Instrucción original: [31] (Signo), [19:12], [20], [30:21], 1'b0
  // Mapeo a Instr[24:0]: {Signo=Instr[24], [19:12]=Instr[12:5], [20]=Instr[13], [30:21]=Instr[23:14], 1'b0}
  // El campo final tiene 21 bits, que se extienden a 32 bits (11 bits de signo)
  assign imm_j = {{11{Instr[24]}}, Instr[24], Instr[12:5], 
                  Instr[13], Instr[23:14], 1'b0};

  // ----------------------------------------------------------------
  // MULTIPLEXOR FINAL
  // ----------------------------------------------------------------
  assign ImmExt = (ImmSrc == 3'b000) ? imm_i :
                  (ImmSrc == 3'b001) ? imm_s :
                  (ImmSrc == 3'b101) ? imm_b :
                  (ImmSrc == 3'b010) ? imm_u :
                  (ImmSrc == 3'b110) ? imm_j :
                  32'd0; // Default a 0
endmodule