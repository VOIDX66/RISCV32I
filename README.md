# Proyecto RISC-V 32i Monociclo

## Objetivo del Proyecto
Este proyecto implementa un procesador **RISC-V 32i monociclo** completo, con soporte para instrucciones R, I, S, B, U y J.  
El objetivo es proveer un **entorno educativo y de simulación** donde se puedan estudiar las señales internas, la generación de inmediatos, la unidad de control y la interacción con memoria y registros.

---

## Estructura del Proyecto

- `src/` : Contiene todos los módulos de diseño (`.sv`)
  - `alu.sv` – Unidad aritmético-lógica
  - `branch_unit.sv` – Unidad de saltos condicionales
  - `control_unit.sv` – Unidad de control principal
  - `data_memory.sv` – Memoria de datos
  - `imm_gen.sv` – Generador de inmediatos
  - `instruction_memory.sv` – Memoria de instrucciones
  - `pc.sv` – Program Counter
  - `reg_unit.sv` – Banco de registros
  - `riscv.sv` – Top-level integrando todos los módulos
- `tb/` : Contiene todos los testbenches (`tb_*.sv`)
- `sim/` : Directorio donde se guardan los resultados de simulación (.vvp y .vcd)
- `docs/` : Documentación adicional

---

## Dependencias

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`) para compilación y simulación.
- [GTKWave](http://gtkwave.sourceforge.net/) para visualizar las señales (archivos `.vcd`).

---

## Cómo compilar y simular

### Simulación del procesador completo

```bash
make run
