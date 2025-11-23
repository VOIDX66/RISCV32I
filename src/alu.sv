// ==============================================================================
// Módulo ALU (Arithmetic Logic Unit) para el Procesador RISC-V 32i
// Responsable de ejecutar todas las operaciones aritméticas y lógicas.
// Diseño: Monociclo (combinacional puro).
// ==============================================================================

`timescale 1ns / 1ps
`default_nettype none // Buena práctica: previene la inferencia accidental de nets

module ALU(
    // Entradas
    input  logic signed [31:0] A,        // Operando A (generalmente rs1)
    input  logic signed [31:0] B,        // Operando B (generalmente rs2 o inmediato)
    input  logic         [3:0] ALUOp,    // Código de operación de 4 bits que selecciona la función de la ALU

    // Salidas
    output logic signed [31:0] ALURes    // Resultado de la operación
);
    
    // WORKAROUND para Icarus Verilog: 
    // Extraer el 'shamt' (shift amount) de B fuera del bloque always_comb.
    // Icarus tiene problemas con la selección directa de bits de 'input' en always_comb/ff.
    logic [4:0] shamt;
    assign shamt = B[4:0];

    // Bloque combinacional que describe la lógica de la ALU
    always_comb begin
        // Inicialización por defecto para garantizar que la lógica es combinacional
        ALURes = 32'b0;

        // Estructura case para implementar el multiplexor basado en ALUOp
        case (ALUOp)
            // ------------------------------------------------------------------
            // Operaciones Aritméticas (2'b00 en Func3)
            // ------------------------------------------------------------------
            4'b0000 : ALURes = A + B;                                  // ADD (Suma)
            4'b1000 : ALURes = A - B;                                  // SUB (Resta: bit más significativo de Func7 es '1' para SUB)

            // ------------------------------------------------------------------
            // Operaciones de Desplazamiento (Shift)
            // Usamos la señal 'shamt' intermedia aquí.
            // ------------------------------------------------------------------
            4'b0001 : ALURes = A <<  $unsigned(shamt);                 // SLL (Shift Left Logical - Desplazamiento Lógico a la Izquierda)
            4'b0101 : ALURes = A >>  $unsigned(shamt);                 // SRL (Shift Right Logical - Desplazamiento Lógico a la Derecha)
            4'b1101 : ALURes = A >>> $unsigned(shamt);                 // SRA (Shift Right Arithmetic - Desplazamiento Aritmético a la Derecha)
                                                                       // Nota: >>> preserva el bit de signo de A

            // ------------------------------------------------------------------
            // Operaciones Lógicas
            // ------------------------------------------------------------------
            4'b0100 : ALURes = A ^ B;                                  // XOR (O Exclusiva)
            4'b0110 : ALURes = A | B;                                  // OR (O Lógica)
            4'b0111 : ALURes = A & B;                                  // AND (Y Lógica)

            // ------------------------------------------------------------------
            // Operaciones de Comparación (Set Less Than)
            // ------------------------------------------------------------------
            4'b0010 : ALURes = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT (Set Less Than - con signo)
            4'b0011 : ALURes = ($unsigned(A) < $unsigned(B)) ? 32'd1 : 32'd0; // SLTU (Set Less Than Unsigned - sin signo)

            // ------------------------------------------------------------------
            // Operaciones Misceláneas
            // ------------------------------------------------------------------
            4'b1001 : ALURes = B;                                      // Bypass / LUI (Señal de B pasa directamente)

            // ------------------------------------------------------------------
            // Default
            // ------------------------------------------------------------------
            default : ALURes = 32'b0;                                  // Valor por defecto para cualquier código no reconocido
        endcase
    end

endmodule // ALU