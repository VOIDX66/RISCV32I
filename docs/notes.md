# Notas de Diseño y Trazabilidad del Proyecto RISC-V 32i

Este archivo se utilizará para registrar las decisiones clave de diseño, las notas personales y la trazabilidad de la implementación del procesador.

## 1. Estructura del Proyecto (Commit Inicial)

Directorios:

- src/: Módulos SystemVerilog del RTL.

- tb/: Testbenches para verificación de módulos.

- sim/: Archivos generados por la simulación (ej. logs, resultados).

- docs/: Documentación, notas de diseño, etc.

- Flujo de Simulación: Utilización de iverilog y vvp con visualización en gtkwave.

## 2. Decisiones de Diseño (RTL)

### ALU (Arithmetic Logic Unit):

Workaround para iverilog (Shamt): Se creó la señal intermedia shamt (logic [4:0] shamt; assign shamt = B[4:0];) fuera del bloque always_comb.

Razón: El compilador Icarus Verilog (iverilog), incluso con la bandera -g2012, reportaba un error ("constant selects in always_* processes are not currently supported") al intentar acceder directamente a los bits de desplazamiento (B[4:0]) dentro del bloque always_comb para las operaciones SLL, SRL y SRA. La extracción de esta selección a una señal cableada (assign) resuelve la incompatibilidad.

Constantes Negativas en TB: Se documenta que se utiliza la notación hexadecimal (ej. 32'hFFFF_FFFB para -5) en el Testbench (tb/tb_alu.sv) en lugar de 32'sd-X para evitar errores de sintaxis en iverilog.