// ==============================================================================
// Módulo PC (Program Counter) para el Procesador RISC-V 32i
// ------------------------------------------------------------------------------
// Registro de 32 bits que almacena la dirección de la instrucción actual.
// Se actualiza en el flanco positivo del reloj (síncrono).
// ==============================================================================

module PC (
	input  logic        clk,     // Reloj del sistema
	input  logic        reset,   // Señal de reset activo alto
	input  logic [31:0] NextPC,  // Próximo valor del PC (PC+4 o dirección de salto)
	output logic [31:0] PC       // Valor actual del PC (salida)
);

	// Inicializa el PC a 0. Esto es útil para herramientas de simulación,
	// pero el reset síncrono es la lógica de diseño primaria.
	initial PC = 32'h00000000;

	// Bloque síncrono: actualiza el PC en el flanco positivo del reloj
	always_ff @(posedge clk) begin
		if (reset) begin
			// Si 'reset' es alto, inicializa la dirección a 0
			PC <= 32'h00000000;
		end else begin
			// Si no hay reset, carga el valor de la próxima dirección
			PC <= NextPC;
		end
	end
	
endmodule // PC