# Notas de Diseño del Proyecto RISC-V Monociclo

## 1. Diseño del Módulo IMM_GEN (`imm_gen.sv`)
- Generador de inmediatos **combinacional** para los formatos I, S, B, J y U.
- Soporta instrucciones como:
  - **I-Type**: ADDI, LOAD, JALR.
  - **S-Type**: STORE.
  - **B-Type**: BEQ, BNE, BLT, BGE, BLTU, BGEU.
  - **J-Type**: JAL.
  - **U-Type (imm_u)**: LUI y AUIPC.
- Extensión de inmediato considerando si es **signed o unsigned** según el tipo de instrucción.

## 2. Unidad de Control (`control_unit.sv`)
- Diseñada basándose en la **especificación de Opcode del ISA RISC-V**.
- Genera señales de control principales:
  - **RegWrite (RUWr)**: habilita escritura en registros.
  - **MemRead/MemWrite (DMWr)**: controla lectura/escritura en memoria de datos.
  - **MemtoReg (RUDataWrSrc)**: selecciona si el dato a escribir viene de ALU, memoria o PC+4.
  - **ALUSrc**: selecciona entrada de la ALU (registro o inmediato).
  - **Branch/Jump (NextPCSrc)**: controla saltos condicionales e incondicionales.
  - **ImmSrc**: selecciona tipo de inmediato para IMM_GEN.
  - **ALUOp**: código general para operación de ALU.
- Implementación **combinacional**, sin latches ni memoria.

## 3. Unidad de Control de ALU (`alu_control.sv`)
- Decodifica los campos **Funct3** y **Funct7[5]** para generar el **ALUOpCode de 4 bits**.
- Permite operaciones: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT y SLTU.

## 4. Memoria de Datos (`data_memory.sv`)
- Memoria de **1 KB**, 256 palabras de 32 bits.
- Escritura **sincrónica** y lectura **combinacional**.
- Acceso por **byte, halfword y word** (signed y unsigned).
- Inicialización interna de memoria, sin necesidad de archivos externos (`program.hex` opcional).

## 5. Unidad de Registros (`reg_unit.sv`)
- Banco de 32 registros de 32 bits.
- Escritura controlada por **RegWrite** y lectura combinacional de **rs1** y **rs2**.
- Registro **x0** fijo en 0 según RISC-V.

## 6. ALU (`alu.sv`)
- Operaciones combinacionales según **ALUOpCode**.
- Entradas seleccionadas mediante **muxes** según ALUASrc y ALUBSrc.
- Salida principal: resultado de 32 bits.

## 7. Branch Unit (`branch_unit.sv`)
- Evalúa condiciones para instrucciones tipo B: BEQ, BNE, BLT, BGE, BLTU, BGEU.
- Evalúa saltos incondicionales JAL y JALR.
- Salida **NextPCSrc** controla si se toma el salto o se continúa con PC+4.

## 8. Top-Level (`riscv.sv`)
- Integra todos los módulos: **PC, Instruction Memory, CONTROL_UNIT, IMM_GEN, REG_UNIT, ALU, DATA_MEMORY, BRANCH_UNIT**.
- Mux de writeback (**ALURes / DataRd / PC+4**) hacia los registros.
- Lógica de **NextPC** combinando PC+4 y saltos.
- Salidas de depuración: **PC_out** y **ALURes_out**.

## 9. Estandarización de Archivos Fuente
- Eliminadas directivas `timescale` y `default_nettype` en todos los módulos `.sv`.
- Control de tiempo delegado a los **testbenches**.
- Archivos organizados en carpetas `src/` y `tb/`.

## 10. Testbenches
- Testbenches por módulo y **tb completo del procesador** (`tb_riscv.sv`).
- Generación de **archivos VCD** para GTKWave.
- Simulación controlada mediante **forever clock** y `$dumpvars` para señales internas.
