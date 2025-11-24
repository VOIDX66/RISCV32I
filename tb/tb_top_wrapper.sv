// ========================================================================
// Testbench para TOP_WRAPPER (Simulación Lógica Real con 1-bit SW)
//
// CORRECCIÓN: El pulso KEY1 ahora se mantiene presionado el tiempo 
// suficiente para que el step_pulse se genere correctamente.
// ========================================================================
`timescale 1ns/1ns

module tb_top_wrapper;

  // Parámetros de simulación
  parameter CLOCK_PERIOD = 10; // 10ns -> 100MHz

  // Señales de la interfaz del top_wrapper
  reg  CLOCK_50;
  reg  KEY0;
  reg  KEY1;
  reg  SW;                  // SW ahora es de 1 bit
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  // Señales de depuración para monitoreo (conectadas a las wires del top_wrapper)
  wire [31:0] debug_PC_mon;
  wire [31:0] debug_ALU_mon;
  wire [23:0] selected24_mon;
  
  // Instancia del DUT (Device Under Test)
  top_wrapper dut (
    .CLOCK_50(CLOCK_50),
    .KEY0(KEY0),
    .KEY1(KEY1),
    .SW(SW),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5)
  );

  // Monitoreo de señales internas del DUT
  assign debug_PC_mon = dut.debug_PC;
  assign debug_ALU_mon = dut.debug_ALU;
  assign selected24_mon = dut.selected24; 


  // -------------------------------------------------------
  // Generación de CLOCK_50
  // -------------------------------------------------------
  initial begin
    CLOCK_50 = 0;
    forever #(CLOCK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;
  end

  // Macro para mostrar el estado actual de las señales
  `define SHOW_STATE $display(" | SW: %b | PC: %h | ALU: %h | HEX_OUT: %h |", \
                             SW, debug_PC_mon, debug_ALU_mon, selected24_mon);
                             

  // -------------------------------------------------------
  // Estímulos de Prueba
  // -------------------------------------------------------
  initial begin
    $dumpfile("top_wrapper.vcd");
    $dumpvars(0, tb_top_wrapper);
    $display("Inicio de la simulacion del Top Wrapper (1-bit SW) - TEMPORIZACIÓN CORREGIDA");
    $display("-------------------------------------------------------");
    $display(" | SW: (1=PC, 0=ALU) | PC: (32-bit) | ALU: (32-bit) | HEX_OUT: (24-bit) |");
    $display("-------------------------------------------------------");


    // 1. Inicialización y Reset
    KEY0 = 0;   // Activa reset (activo en bajo)
    KEY1 = 1;   // Botón suelto (Step deshabilitado)
    SW = 1'b0;  // Valor inicial: Muestra ALURes
    
    #10; 
    
    // Desactivar Reset
    @(posedge CLOCK_50);
    KEY0 = 1;   
    @(posedge CLOCK_50);
    $display("Paso 1: Reset liberado. PC y ALU en estado inicial.");
    `SHOW_STATE


    // --- PRUEBAS DE SELECCIÓN DE DISPLAY EN ESTADO INICIAL (PC = 0) ---
    
    // 2. Prueba SW = 0. Esperado: ALURes (000400)
    SW = 1'b0;
    #1;
    $display("TEST 2: SW=0 (ALU) seleccionado.");
    `SHOW_STATE

    // 3. Prueba SW = 1. Esperado: PC (000000)
    SW = 1'b1;
    #1;
    $display("TEST 3: SW=1 (PC) seleccionado.");
    `SHOW_STATE
    
    // -------------------------------------------------------
    // PRUEBA DE STEP-BY-STEP 1 (Ejecución de la primera instrucción)
    // -------------------------------------------------------
    
    $display("-------------------------------------------------------");
    $display("Paso 4: Pulso KEY1 (Step) - Ejecuta la primera instrucción.");
    
    // SECUENCIA CORREGIDA PARA GARANTIZAR EL STEP_PULSE
    KEY1 = 0;           // Presionar KEY1
    @(posedge CLOCK_50); // T+1: s1=1, s2=0. step_pulse=0.
    @(posedge CLOCK_50); // T+2: s1=1, s2=1. step_pulse=1 (CPU CLOCKS) -> PC DEBE AVANZAR A 4
    KEY1 = 1;           // Soltar KEY1
    @(posedge CLOCK_50); // T+3: s1=0, s2=1. step_pulse=0. (Fin del pulso)
    
    $display("Estado despues del 1er step (PC debe ser 4):");
    `SHOW_STATE

    // 5. Verificar la selección del PC (SW=1) ahora debe mostrar 000004
    SW = 1'b1;
    #1;
    $display("TEST 5: SW=1 (PC) seleccionado. Esperado: PC=000004");
    `SHOW_STATE

    // 6. Verificar la selección del ALU (SW=0) ahora debe mostrar el resultado de la 1era instrucción
    SW = 1'b0;
    #1;
    $display("TEST 6: SW=0 (ALU) seleccionado. Esperado: Nuevo ALURes.");
    `SHOW_STATE

    // -------------------------------------------------------
    // PRUEBA DE STEP-BY-STEP 2 (Ejecución de la segunda instrucción)
    // -------------------------------------------------------
    
    $display("-------------------------------------------------------");
    $display("Paso 7: Segundo Pulso KEY1 (Step) - Ejecuta la segunda instrucción.");
    
    // SECUENCIA CORREGIDA PARA GARANTIZAR EL STEP_PULSE
    KEY1 = 0;           // Presionar KEY1
    @(posedge CLOCK_50); // T+1: s1=1, s2=0. step_pulse=0.
    @(posedge CLOCK_50); // T+2: s1=1, s2=1. step_pulse=1 (CPU CLOCKS) -> PC DEBE AVANZAR A 8
    KEY1 = 1;           // Soltar KEY1
    @(posedge CLOCK_50); // T+3: s1=0, s2=1. step_pulse=0. (Fin del pulso)
    
    $display("Estado despues del 2do step (PC debe ser 8):");
    `SHOW_STATE
    
    // 8. Verificar la selección del PC (SW=1) ahora debe mostrar 000008
    SW = 1'b1;
    #1;
    $display("TEST 8: SW=1 (PC) seleccionado. Esperado: PC=000008");
    `SHOW_STATE


    #100 $finish;
  end

endmodule