// ===================================================================
//  Testbench para REG_UNIT
// -------------------------------------------------------------------
//  Verifica mediante señales en simulación:
//      • Lectura constante del registro x0
//      • Escritura en registros válidos
//      • Inhibición de escritura con RUWr = 0
//      • Escritura ignorada cuando rd = 0 (x0)
// ===================================================================

`timescale 1ns/1ps

module tb_REG_UNIT;

    // Señales
    logic [4:0] rs1, rs2;
    logic [4:0] rd;
    logic [31:0] DataWr;
    logic RUWr;
    logic clk;

    logic [31:0] RU_rs1, RU_rs2;

    // Instancia del DUT
    REG_UNIT dut (
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .DataWr(DataWr),
        .RUWr(RUWr),
        .clk(clk),
        .RU_rs1(RU_rs1),
        .RU_rs2(RU_rs2)
    );

    // Generador de reloj 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_REG_UNIT);
    end

    // Estímulos sin displays
    initial begin
        
        // Caso 1: Lecturas de x0 (RU_rs1 y RU_rs2 deben ser 0)
        rs1 = 0;
        rs2 = 0;
        RUWr = 0;
        rd = 0;
        DataWr = 0;
        #10;

        // Caso 2: Escritura en x5
        rd = 5;
        DataWr = 32'hAABBCCDD;
        RUWr = 1;
        @(posedge clk);
        #10;

        // Lectura de x5
        rs1 = 5;
        rs2 = 0;
        RUWr = 0;
        #10;

        // Caso 3: Escritura deshabilitada (RUWr=0) en x10
        rd = 10;
        DataWr = 32'h12345678;
        RUWr = 0;
        @(posedge clk);
        #10;

        // Lectura de x10 (debe permanecer en 0)
        rs1 = 10;
        #10;

        // Caso 4: Escritura ignorada en x0
        rd = 0;
        DataWr = 32'hFFFFFFFF;
        RUWr = 1;
        @(posedge clk);
        #10;

        // Lectura de x0 (debe seguir en 0)
        rs1 = 0;
        #10;

        $finish;
    end

endmodule
