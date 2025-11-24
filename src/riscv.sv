// ============================================================
// RISC-V MONOCICLO — TOP LEVEL
// ------------------------------------------------------------
// Integra todos los módulos del procesador:
//   - PC (Program Counter)
//   - Instruction Memory
//   - Control Unit
//   - Immediate Generator
//   - Register Unit
//   - ALU
//   - Data Memory
//   - Branch Unit
//   - Writeback MUX
//   - NextPC Logic
//
// Este módulo es el "núcleo" del CPU y es el que se conecta
// al top_wrapper para la FPGA (DE10-Lite).
//
// El reloj usado es "single-step" desde el botón KEY0,
// para depuración paso a paso.
// ============================================================

module RISCV (
    input  logic clk,          // reloj del CPU (pulsos manuales)
    input  logic reset,        // reset global (KEY0)
    output logic [31:0] INST_out,        // PC visible para debug
    output logic [31:0] ALURes_out     // resultado ALU para debug
);

  // ============================================================
  // 1. Señales internas
  // ------------------------------------------------------------
  // Conexiones entre los bloques del procesador.
  // Todas estas señales se "arman" en el top level.
  // ============================================================
  logic [31:0] PC, NextPC, PCplus4;
  logic [31:0] Instruction;
  logic [31:0] ImmExt;
  logic [31:0] DataRs1, DataRs2;
  logic [31:0] ALURes, DataRd;
  logic [31:0] RUDataWr;

  // Señales de control desde CONTROL_UNIT
  logic        RUWr;
  logic [1:0]  RUDataWrSrc;
  logic        ALUASrc, ALUBSrc;
  logic [3:0]  ALUOp;
  logic [2:0]  ImmSrc;
  logic [4:0]  BrOp;
  logic        DMWr;
  logic [2:0]  DMCtrl;
  logic        NextPCSrc;

  // ============================================================
  // 2. PROGRAM COUNTER (PC)
  // ------------------------------------------------------------
  // Guarda la dirección de la instrucción actual.
  // Se actualiza con single-step usando clk.
  // ============================================================
  PC PCU (
      .clk(clk),
      .reset(reset),
      .NextPC(NextPC),
      .PC(PC)
  );

  // ============================================================
  // 3. INSTRUCTION MEMORY
  // ------------------------------------------------------------
  // Lee la instrucción ubicada en la dirección PC.
  // Memoria solo de lectura.
  // ============================================================
  INSTRUCTION_MEMORY IMEM (
      .Address(PC),
      .Instruction(Instruction)
  );

  // ============================================================
  // 4. CONTROL UNIT
  // ------------------------------------------------------------
  // Decodifica opcode, funct3 y funct7 para generar:
  //   - Selección de MUXs
  //   - Operaciones de la ALU
  //   - Tipo de inmediato
  //   - Señales de memoria
  //   - Señales del banco de registros
  //   - Señal del branch unit
  // ============================================================
  CONTROL_UNIT CU (
      .opcode(Instruction[6:0]),
      .funct3(Instruction[14:12]),
      .funct7(Instruction[31:25]),
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

  // ============================================================
  // 5. IMMEDIATE GENERATOR (IMMGEN)
  // ------------------------------------------------------------
  // Extiende y acomoda el inmediato de acuerdo al formato
  // (I, S, B, U, J) seleccionado por ImmSrc.
  // ============================================================
  IMM_GEN IMM (
      .Instr(Instruction[31:7]),
      .ImmSrc(ImmSrc),
      .ImmExt(ImmExt)
  );

  // ============================================================
  // 6. REGISTER UNIT (RU)
  // ------------------------------------------------------------
  // Banco de 32 registros x 32 bits.
  // Lectura combinacional (rs1, rs2).
  // Escritura sincrónica (rd).
  // ============================================================
  REG_UNIT RU (
      .clk(clk),
      .RUWr(RUWr),
      .rs1(Instruction[19:15]),
      .rs2(Instruction[24:20]),
      .rd(Instruction[11:7]),
      .DataWr(RUDataWr),
      .RU_rs1(DataRs1),
      .RU_rs2(DataRs2)
  );

  // ============================================================
  // 7. ALU INPUT MUXES
  // ------------------------------------------------------------
  // Seleccionan entre:
  //   A = PC ó rs1
  //   B = ImmExt ó rs2
  // Según ALUASrc y ALUBSrc.
  // ============================================================
  logic [31:0] ALU_A, ALU_B;
  assign ALU_A = (ALUASrc) ? PC      : DataRs1;
  assign ALU_B = (ALUBSrc) ? ImmExt  : DataRs2;

  // ============================================================
  // 8. ALU
  // ------------------------------------------------------------
  // Ejecuta operaciones aritméticas/lógicas o cálculo de direcciones.
  // Resultado usado para:
  //   - Cálculo de direcciones de memoria
  //   - Operaciones R-type e I-type
  //   - Dirección destino de saltos
  // ============================================================
  ALU ALU (
      .A(ALU_A),
      .B(ALU_B),
      .ALUOp(ALUOp),
      .ALURes(ALURes)
  );

  // ============================================================
  // 9. DATA MEMORY (DMEM)
  // ------------------------------------------------------------
  // Memoria de datos con:
  //   • Escritura sincrónica (DMWr)
  //   • Lectura combinacional (DataRd)
  //   • Modos byte/halfword/word mediante DMCtrl
  // ============================================================
  DATA_MEMORY DMEM (
      .clk(clk),
      .Address(ALURes),
      .DataWr(DataRs2),
      .DMWr(DMWr),
      .DMCtrl(DMCtrl),
      .DataRd(DataRd)
  );

  // ============================================================
  // 10. BRANCH UNIT
  // ------------------------------------------------------------
  // Evalúa condiciones de salto:
  //   - BEQ, BNE, BLT, BGE, etc.
  //   - Saltos incondicionales (BrOp[4] = 1)
  // ============================================================
  BRANCH_UNIT BU (
      .rs1(DataRs1),
      .rs2(DataRs2),
      .BrOp(BrOp),
      .NextPCSrc(NextPCSrc)
  );

  // ============================================================
  // 11. WRITEBACK MUX
  // ------------------------------------------------------------
  // Selecciona el dato que se escribe en rd:
  //   00 → ALURes
  //   01 → DataRd (LOAD)
  //   10 → PC + 4 (JAL / JALR)
  // ============================================================
  always @(*) begin
      case (RUDataWrSrc)
          2'b00: RUDataWr = ALURes;
          2'b01: RUDataWr = DataRd;
          2'b10: RUDataWr = PCplus4;
          default: RUDataWr = 32'b0;
      endcase
  end

  // ============================================================
  // 12. NEXT PC LOGIC
  // ------------------------------------------------------------
  // Calcula el próximo PC:
  //   - Secuencial: PC + 4
  //   - Salto tomado: ALURes (dirección objetivo)
  // ============================================================
  assign PCplus4 = PC + 32'd4;
  assign NextPC  = (NextPCSrc) ? ALURes : PCplus4;

  // ============================================================
  // 13. DEBUG OUTPUTS
  // ------------------------------------------------------------
  // Señales exportadas al wrapper (para LEDs o displays).
  // ============================================================
  assign INST_out      = Instruction;
  assign ALURes_out  = ALURes;

endmodule
