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
  // Cálculo de índices y offsets para Icarus (pre-cálculo)
  // ============================================================
  // Desplazamiento de bytes (0, 8, 16, 24)
  logic [4:0] byte_offset_start;
  assign byte_offset_start = Address[1:0] * 8; // Address[1:0] * 8

  // Desplazamiento de halfwords (0, 16)
  logic [4:0] half_word_offset_start;
  assign half_word_offset_start = Address[1] * 16; // Address[1] * 16

  // Palabra leída combinacionalmente
  logic [31:0] temp_word;
  assign temp_word = memory[word_index];

  // ============================================================
  // Inicialización interna (sin archivos externos)
  // ============================================================
  initial begin
    integer i;
    for (i = 0; i < 256; i = i + 1)
      memory[i] = 32'b0;

    // Precargar algunos datos:
    memory[0] = 32'h00000010;
    memory[1] = 32'hAABBCCDD;
  end

  // ============================================================
  // Escritura sincrónica (con reloj)
  // ============================================================
  always_ff @(posedge clk) begin
    if (DMWr) begin
      case (DMCtrl)
        3'b000, 3'b100: begin // Byte (SB/LB/LBU)
          memory[word_index][byte_offset_start +: 8] <= DataWr[7:0];
        end
        3'b001, 3'b101: begin // Halfword (SH/LH/LHU)
          memory[word_index][half_word_offset_start +: 16] <= DataWr[15:0];
        end
        3'b010: begin // Word (SW/LW)
          memory[word_index] <= DataWr;
        end
      endcase
    end
  end

  // ============================================================
  // Lectura combinacional
  // ============================================================
  always_comb begin
    case (DMCtrl)
      // LB: Byte con extensión de signo
      3'b000: DataRd = {{24{temp_word[byte_offset_start + 7]}}, temp_word[byte_offset_start +: 8]};
      
      // LH: Halfword con extensión de signo
      3'b001: DataRd = {{16{temp_word[half_word_offset_start + 15]}}, temp_word[half_word_offset_start +: 16]}; 
      
      // LW: Word
      3'b010: DataRd = temp_word;                                                              
      
      // LBU: Byte sin extensión (unsigned)
      3'b100: DataRd = {24'b0, temp_word[byte_offset_start +: 8]};                               
      
      // LHU: Halfword sin extensión (unsigned)
      3'b101: DataRd = {16'b0, temp_word[half_word_offset_start +: 16]};                               
      
      default: DataRd = 32'b0;
    endcase
  end

endmodule