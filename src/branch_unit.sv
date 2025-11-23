// ============================================================
// RISC-V MONOCICLO - BRANCH UNIT
// ------------------------------------------------------------
// Entradas:
//   - rs1, rs2: operandos leídos del banco de registros
//   - BrOp[4:0]: código de operación de salto/branch
//
// Salidas:
//   - NextPCSrc: 1 = usar ALURes como próximo PC (salto tomado)
//                0 = continuar con PC+4
//
// Convención:
//   NextPCSrc BrOp
//   0 00XXX  -> secuencial
//   0 01000  -> BEQ (=)
//   0 01001  -> BNE (≠)
//   0 01100  -> BLT (< signed)
//   0 01101  -> BGE (≥ signed)
//   0 01110  -> BLTU (< unsigned)
//   0 01111  -> BGEU (≥ unsigned)
//   1 1XXXX  -> saltos incondicionales (JAL / JALR)
// ============================================================

module BRANCH_UNIT (
  input  logic [31:0] rs1,
  input  logic [31:0] rs2,
  input  logic [4:0]  BrOp,
  output logic        NextPCSrc
);

  always @(*) begin
    // Valor por defecto: no salto
    NextPCSrc = 1'b0;

    // Saltos incondicionales: BrOp[4] = 1
    if (BrOp[4] == 1'b1) begin
      NextPCSrc = 1'b1;
    end else begin
      // Branches condicionales
      case (BrOp)
        5'b01000: NextPCSrc = (rs1 == rs2);                     // BEQ
        5'b01001: NextPCSrc = (rs1 != rs2);                     // BNE
        5'b01100: NextPCSrc = ($signed(rs1) <  $signed(rs2));   // BLT
        5'b01101: NextPCSrc = ($signed(rs1) >= $signed(rs2));   // BGE
        5'b01110: NextPCSrc = (rs1 <  rs2);                     // BLTU
        5'b01111: NextPCSrc = (rs1 >= rs2);                     // BGEU
        default:  NextPCSrc = 1'b0;                             // No branch
      endcase
    end
  end

endmodule