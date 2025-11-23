// ============================================================
// RISC-V MONOCICLO - DATA MEMORY
// ------------------------------------------------------------
// Memoria de datos con escritura SINCRÓNICA (reloj)
// y lectura COMBINACIONAL (sin reloj).
// ============================================================

module DATA_MEMORY (
  input  logic        clk,        // reloj
  input  logic [31:0] Address,    // dirección de acceso
  input  logic [31:0] DataWr,     // dato a escribir
  input  logic        DMWr,       // enable de escritura
  input  logic [2:0]  DMCtrl,     // modo de acceso
  output logic [31:0] DataRd      // dato leído
);

  // Memoria de 256 palabras (1 KB)
  logic [31:0] memory [0:255];

  // Índice por palabra (Address / 4)
  logic [7:0] word_index;
  assign word_index = Address[31:2];

  // ============================================================
  // Inicialización interna (sin archivos externos)
  // ============================================================
  initial begin
    integer i;
    for (i = 0; i < 256; i = i + 1)
      memory[i] = 32'b0;

    // Si deseas precargar algunos datos:
    // memory[0] = 32'h00000010;
    // memory[1] = 32'hAABBCCDD;
  end

  // ============================================================
  // Escritura sincrónica (con reloj)
  // ============================================================
  always_ff @(posedge clk) begin
    if (DMWr) begin
      case (DMCtrl)
        3'b000, 3'b100: begin // Byte
          memory[word_index][(Address[1:0]*8)+:8] <= DataWr[7:0];
        end
        3'b001, 3'b101: begin // Halfword
          memory[word_index][(Address[1]*16)+:16] <= DataWr[15:0];
        end
        3'b010: begin // Word
          memory[word_index] <= DataWr;
        end
      endcase
    end
  end

  // ============================================================
  // Lectura combinacional
  // ============================================================
  logic [31:0] temp_word;
  assign temp_word = memory[word_index];

  always_comb begin
    case (DMCtrl)
      3'b000: DataRd = {{24{temp_word[(Address[1:0]*8+7)]}}, temp_word[(Address[1:0]*8)+:8]};  // Byte (signed)
      3'b001: DataRd = {{16{temp_word[(Address[1]*16+15)]}}, temp_word[(Address[1]*16)+:16]}; // Halfword (signed)
      3'b010: DataRd = temp_word;                                                              // Word
      3'b100: DataRd = {24'b0, temp_word[(Address[1:0]*8)+:8]};                               // Byte (unsigned)
      3'b101: DataRd = {16'b0, temp_word[(Address[1]*16)+:16]};                               // Halfword (unsigned)
      default: DataRd = 32'b0;
    endcase
  end

endmodule
