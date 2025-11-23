// ===============================================================
//  REG_UNIT — Banco de Registros de 32 x 32 bits
// ---------------------------------------------------------------
//  Implementa el banco de registros definido por el ISA RISC-V.
//  • 32 registros de 32 bits
//  • Lectura combinacional de rs1 y rs2
//  • Escritura secuencial en flanco positivo del reloj
//  • El registro x0 (rd = 0) siempre retorna 0 y no puede escribirse
// ===============================================================

module REG_UNIT(

    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,

    input  logic [4:0]  rd,
    input  logic [31:0] DataWr,
    input  logic        RUWr,

    input  logic        clk,

    output logic [31:0] RU_rs1,
    output logic [31:0] RU_rs2
);

    // Banco de 32 registros de 32 bits
    logic [31:0] ru [31:0];

    // Inicialización opcional
    initial begin
        ru[2] = 32'b1000000000;
    end

    // Lectura combinacional con x0 forzado a cero
    assign RU_rs1 = (rs1 == 5'b00000) ? 32'd0 : ru[rs1];
    assign RU_rs2 = (rs2 == 5'b00000) ? 32'd0 : ru[rs2];

    // Escritura síncrona
    always @(posedge clk) begin
        if (RUWr && rd != 5'b00000) begin
            ru[rd] <= DataWr;
        end
    end

endmodule
