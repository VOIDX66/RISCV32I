// ==============================================================================
// Testbench (TB) para el módulo PC (Program Counter)
// ------------------------------------------------------------------------------
// Secuencia de prueba limpia y clara para visualizar el reset, 
// el avance (PC+4) y un salto en las formas de onda.
// **Diseñado solo para generar formas de onda (VCD), sin salida de consola.**
// ==============================================================================

`timescale 1ns / 1ps // Unidad de tiempo y precisión en nanosegundos (ns)

module tb_pc;

	// --------------------------------------------------------------------------
	// 1. Declaración de Señales de Conexión y Parámetros
	// --------------------------------------------------------------------------
	localparam CLK_PERIOD = 10; // Período del reloj en ns (5ns alto, 5ns bajo)
	
	logic        clk;
	logic        reset;
	logic [31:0] NextPC_in;
	logic [31:0] PC_out;
	
	// --------------------------------------------------------------------------
	// 2. Instanciación del Dispositivo Bajo Prueba (DUT)
	// --------------------------------------------------------------------------
	PC DUT (
		.clk    (clk),
		.reset  (reset),
		.NextPC (NextPC_in),
		.PC     (PC_out)
	);

	// --------------------------------------------------------------------------
	// 3. Generador de Reloj
	// --------------------------------------------------------------------------
	initial begin
		clk = 1'b0;
		forever #(CLK_PERIOD / 2) clk = ~clk;
	end

	// --------------------------------------------------------------------------
	// 4. Volcado de Formas de Onda (para GTKWave)
	// --------------------------------------------------------------------------
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, tb_pc);
	end

	// --------------------------------------------------------------------------
	// 5. Secuencia de Prueba Principal (Estímulos claros)
	// --------------------------------------------------------------------------
	initial begin

    NextPC_in = 32'h0000000C;
    reset = 1'b1;

		// --- FASE 1: Reset y liberación ---
		@(posedge clk); // Flanco 1: PC se pone a 0 (PC = 0x0)

    
		NextPC_in = 32'h00000004; // Valor de entrada irrelevante
    reset = 1'b0;

		# (CLK_PERIOD);
		NextPC_in = 32'h00000008; // Siguiente dirección esperada: 4
		@(posedge clk);           // Flanco 2: PC = 0x4
		
		# (CLK_PERIOD);
		NextPC_in = 32'h00000008; // Siguiente dirección esperada: 8
		@(posedge clk);           // Flanco 3: PC = 0x8

		# (CLK_PERIOD);
		NextPC_in = 32'h0000000C; // Siguiente dirección esperada: 12
		@(posedge clk);           // Flanco 4: PC = 0xC (12)


		// --- FASE 3: Simulación de Salto (PC = Dirección de Salto) ---
		
		# (CLK_PERIOD);
		NextPC_in = 32'h10000000; // Dirección de salto
		@(posedge clk);           // Flanco 5: PC = 0x10000000 (Salto)

		// --- FASE 4: Continuación del flujo ---
		
		# (CLK_PERIOD);
		NextPC_in = 32'h10000004; // Siguiente dirección después del salto
		@(posedge clk);           // Flanco 6: PC = 0x10000004

		// Fin de la simulación
		# (CLK_PERIOD * 5); 
		$finish;
	end

endmodule // tb_pc