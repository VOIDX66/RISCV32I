# Notas de Diseño del Proyecto RISC-V Monociclo

## 1. Diseño del Módulo IMM_GEN (`imm_gen.sv`)

- **Propósito**: Generador de inmediatos combinacional para los formatos I, S, B, J y U
- **Instrucciones soportadas**:
  - **I-Type**: ADDI, LOAD, JALR
  - **S-Type**: STORE
  - **B-Type**: BEQ, BNE, BLT, BGE, BLTU, BGEU
  - **J-Type**: JAL
  - **U-Type**: LUI y AUIPC
- **Características**: Extensión de inmediato considerando si es signed o unsigned según el tipo de instrucción

## 2. Unidad de Control (`control_unit.sv`)

- **Base de diseño**: Especificación de Opcode del ISA RISC-V
- **Señales de control generadas**:
  - `RegWrite (RUWr)`: Habilita escritura en registros
  - `MemRead/MemWrite (DMWr)`: Controla lectura/escritura en memoria de datos
  - `MemtoReg (RUDataWrSrc)`: Selecciona fuente de dato a escribir (ALU, memoria o PC+4)
  - `ALUSrc`: Selecciona entrada de la ALU (registro o inmediato)
  - `Branch/Jump (NextPCSrc)`: Controla saltos condicionales e incondicionales
  - `ImmSrc`: Selecciona tipo de inmediato para IMM_GEN
  - `ALUOp`: Código general para operación de ALU
- **Implementación**: Combinacional, sin latches ni memoria

## 3. Unidad de Control de ALU (`alu_control.sv`)

- **Función**: Decodifica campos Funct3 y Funct7[5] para generar ALUOpCode de 4 bits
- **Operaciones soportadas**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

## 4. Memoria de Datos (`data_memory.sv`)

- **Capacidad**: 1 KB (256 palabras de 32 bits)
- **Características de acceso**:
  - Escritura sincrónica
  - Lectura combinacional
  - Acceso por byte, halfword y word (signed y unsigned)
- **Inicialización**: Memoria interna, sin necesidad de archivos externos (program.hex opcional)

## 5. Unidad de Registros (`reg_unit.sv`)

- **Estructura**: Banco de 32 registros de 32 bits
- **Control**: Escritura controlada por RegWrite, lectura combinacional de rs1 y rs2
- **Especificación RISC-V**: Registro x0 fijo en 0

## 6. ALU (`alu.sv`)

- **Tipo**: Operaciones combinacionales según ALUOpCode
- **Entradas**: Seleccionadas mediante muxes según ALUASrc y ALUBSrc
- **Salida**: Resultado de 32 bits

## 7. Branch Unit (`branch_unit.sv`)

- **Funcionalidad**: Evalúa condiciones para instrucciones tipo B
- **Instrucciones soportadas**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Saltos incondicionales**: JAL y JALR
- **Control**: Salida NextPCSrc determina si se toma el salto o continúa con PC+4

## 8. Top-Level (`riscv.sv`)

- **Integración**: Conecta todos los módulos:
  - PC, Instruction Memory
  - CONTROL_UNIT, IMM_GEN, REG_UNIT
  - ALU, DATA_MEMORY, BRANCH_UNIT
- **Características**:
  - Mux de writeback (ALURes / DataRd / PC+4) hacia registros
  - Lógica de NextPC combinando PC+4 y saltos
  - Salidas de depuración: PC_out y ALURes_out
  - Entidad principal para Simulación Lógica

## 9. Estandarización de Archivos Fuente

- **Cambios realizados**:
  - Eliminadas directivas `timescale` y `default_nettype` en todos los módulos .sv
  - Control de tiempo delegado a los testbenches
- **Organización**:
  - Archivos fuente en carpeta `src/`
  - Testbenches en carpeta `tb/`

## 10. Testbenches

- **Cobertura**: Testbenches por módulo y completo del procesador (`tb_riscv.sv`)
- **Herramientas**: Generación de archivos VCD para GTKWave
- **Control de simulación**:
  - `forever clock` para generación de reloj
  - `$dumpvars` para captura de señales internas

## 11. Top Wrapper de Hardware (FPGA) - `top_wrapper.sv`

### Propósito
Adaptador de interfaz entre el núcleo lógico (`RISCV.sv`) y los periféricos físicos de la placa DE1-SoC. Entidad principal (Top Entity) para síntesis e implementación en FPGA.

### Funciones Principales

#### Manejo de Reloj y Control
- **Reset**: Convierte KEY0 (activo en bajo) en señal de reset activo en alto
- **Single-Step**: 
  - Lógica de debouncing y detección de flanco positivo para KEY1
  - Genera pulso de reloj (`step_pulse`) que avanza una instrucción por pulsación

#### Selección de Depuración (Debug)
- **Multiplexor**: Utiliza switch SW (1 bit) para seleccionar registro interno a mostrar
  - `SW = 1`: Muestra valor del PC (Program Counter) [23:0]
  - `SW = 0`: Muestra valor del ALURes (Resultado de la ALU) [23:0]

#### Adaptación para Displays de 7 Segmentos
- **Función `font7`**: Decodificador BCD a 7-segmentos con lógica Activa Alta (`1` = ON)
- **Inversión crítica**: 
  ```systemverilog
  assign HEXx = ~font7(nibble);
  ```
  - **Necesaria** porque la placa DE1-SoC utiliza displays de Ánodo Común
  - Requiere nivel LOW (`0`) para encender un segmento