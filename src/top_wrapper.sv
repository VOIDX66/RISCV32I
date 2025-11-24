// ========================================================================
// top_wrapper.sv
// - KEY0 = reset (activo en bajo)
// - KEY1 = step-by-step (avanza 1 instrucción)
// - SW (1 bit) = Selector de Depuración
//   - SW = 1: Muestra PC[23:0]
//   - SW = 0: Muestra ALURes[23:0]
// - HEX0..HEX5 muestran 24 bits (6 nibbles)
// ========================================================================
module top_wrapper (
  input  wire CLOCK_50,
  input  wire KEY0,          // reset_n
  input  wire KEY1,          // step button
  input  wire SW,            // SW de 1 bit para seleccion (1=PC, 0=ALURes)
  
  // Puertos para los 6 displays de 7 segmentos (HEX5 es el más significativo)
  output wire [6:0] HEX0,
  output wire [6:0] HEX1,
  output wire [6:0] HEX2,
  output wire [6:0] HEX3,
  output wire [6:0] HEX4,
  output wire [6:0] HEX5
);

  // -------------------------------------------------------
  // RESET (KEY0 es activo en bajo)
  // -------------------------------------------------------
  wire reset = ~KEY0;

  // -------------------------------------------------------
  // SINGLE-STEP (debounce + flanco de subida)
  // -------------------------------------------------------
  reg s1, s2, s_prev;
  
  // Registros de muestreo para debouncing (anti-rebote)
  always @(posedge CLOCK_50) begin
    s1     <= ~KEY1;   // KEY1 es activo en bajo -> invertir
    s2     <= s1;
    s_prev <= s2;
  end

  // Genera un pulso de un ciclo cuando el botón s2 (ya limpio) pasa de 0 a 1
  wire step_pulse = (s2 && !s_prev); 

  // -------------------------------------------------------
  // Instancia del RISC-V CORE
  // Las wires se declaran aquí para que sean accesibles en el Testbench (tb.dut.debug_PC)
  // -------------------------------------------------------
  wire [31:0] debug_PC;
  wire [31:0] debug_ALU;

  RISCV cpu (
    .clk(step_pulse),        
    .reset(reset),
    .PC_out(debug_PC),
    .ALURes_out(debug_ALU)
    // Conectar otros puertos como Instrucción, Registros, etc. si es necesario
  );

  // -------------------------------------------------------
  // SELECCIÓN DE DATO A MOSTRAR (Usando SW de 1 bit)
  // -------------------------------------------------------
  wire [23:0] selected24;

  // SW = 1 (Arriba) -> Muestra PC
  // SW = 0 (Abajo) -> Muestra ALURes
  assign selected24 = (SW) ? debug_PC[23:0] : debug_ALU[23:0];

  // -------------------------------------------------------
  // Dividir la palabra de 24 bits en 6 nibbles (4 bits cada uno)
  // -------------------------------------------------------
  wire [3:0] nib5 = selected24[23:20]; // Más significativo
  wire [3:0] nib4 = selected24[19:16];
  wire [3:0] nib3 = selected24[15:12];
  wire [3:0] nib2 = selected24[11:8];
  wire [3:0] nib1 = selected24[7:4];
  wire [3:0] nib0 = selected24[3:0];  // Menos significativo

  // -------------------------------------------------------
  // Función de fuente 7 segmentos (Decodificador BCD a 7-Segmentos)
  // -------------------------------------------------------
  function automatic [6:0] font7;
    input [3:0] v;
    begin
      case (v)
        4'h0: font7 = 7'b1111110; 4'h1: font7 = 7'b0110000;
        4'h2: font7 = 7'b1101101; 4'h3: font7 = 7'b1111001;
        4'h4: font7 = 7'b0110011; 4'h5: font7 = 7'b1011011;
        4'h6: font7 = 7'b1011111; 4'h7: font7 = 7'b1110000;
        4'h8: font7 = 7'b1111111; 4'h9: font7 = 7'b1111011;
        4'hA: font7 = 7'b1110111; 4'hB: font7 = 7'b0011111;
        4'hC: font7 = 7'b1001110; 4'hD: font7 = 7'b0111101;
        4'hE: font7 = 7'b1001111; 4'hF: font7 = 7'b1000111;
        default: font7 = 7'b0000000;
      endcase
    end
  endfunction

  // -------------------------------------------------------
  // ASIGNACIÓN FINAL DE SALIDAS (Inversión para Ánodo Común)
  // -------------------------------------------------------
  assign HEX0 = ~font7(nib0);
  assign HEX1 = ~font7(nib1);
  assign HEX2 = ~font7(nib2);
  assign HEX3 = ~font7(nib3);
  assign HEX4 = ~font7(nib4);
  assign HEX5 = ~font7(nib5);

endmodule