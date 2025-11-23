# ==============================================================================
# Makefile para Simulación de RISC-V 32i en SystemVerilog
# Herramientas: Icarus Verilog (iverilog) y GTKWave
# Fecha: Noviembre 2025
# ==============================================================================

# Variables de Directorio y Herramientas
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
SRC_DIR = src
TB_DIR = tb
WAVE_FILE = wave.vcd

# Módulo Principal del Procesador
TOP_MODULE = riscv
TOP_TB = $(TB_DIR)/tb_$(TOP_MODULE).sv

# Directorio y rutas de simulación del TOP
TOP_SIM_DIR = sim/$(TOP_MODULE)
TOP_VVP = $(TOP_SIM_DIR)/$(TOP_MODULE).vvp
TOP_VCD = $(TOP_SIM_DIR)/$(WAVE_FILE)

# ------------------------------------------------------------------------------
# Regla para asegurar que los directorios existan
# ------------------------------------------------------------------------------
DIRS = $(SRC_DIR) $(TB_DIR) sim docs
$(shell mkdir -p $(DIRS))

.PHONY: all default clean run help sim sim_%

default: help

# ------------------------------------------------------------------------------
# Regla para el Módulo Principal (make run)
# Ahora guarda TODO en sim/riscv/ como pediste
# ------------------------------------------------------------------------------
run: $(TOP_VVP)
	@echo "======================================================================"
	@echo " Ejecutando la simulación del módulo principal: $(TOP_MODULE) "
	@echo " Directorio de salida: $(TOP_SIM_DIR)/ "
	@echo "======================================================================"
	cd $(TOP_SIM_DIR) && $(VVP) $(TOP_MODULE).vvp
	$(GTKWAVE) $(TOP_VCD) &

$(TOP_VVP): $(TOP_TB) $(SRC_DIR)/*.sv
	@echo "Compilando módulo principal y todos los módulos fuente..."
	mkdir -p $(TOP_SIM_DIR)
	$(IVERILOG) -g2012 -o $(TOP_VVP) $^

# ------------------------------------------------------------------------------
# Regla Genérica para Testbenches de Módulos (make sim_<modulo>)
# Las salidas (.vvp y .vcd) se guardan en sim/<modulo_nombre>/
# ------------------------------------------------------------------------------
sim_%:
	$(eval MOD_NAME := $(shell echo $* | tr '[:upper:]' '[:lower:]'))
	$(eval MOD_SIM_DIR := sim/$(MOD_NAME))
	$(eval VVP_PATH := $(MOD_SIM_DIR)/tb_$(MOD_NAME).vvp)

	@echo "======================================================================"
	@echo " Preparando y ejecutando simulación para el módulo: $(MOD_NAME) "
	@echo " Directorio de salida: $(MOD_SIM_DIR)/ "
	@echo "======================================================================"

	mkdir -p $(MOD_SIM_DIR)

	cp src/program.hex $(MOD_SIM_DIR)/

	$(IVERILOG) -g2012 -o $(VVP_PATH) $(TB_DIR)/tb_$(MOD_NAME).sv $(SRC_DIR)/$(MOD_NAME).sv

	@echo "Ejecutando $(VVP) en $(MOD_SIM_DIR)/"
	cd $(MOD_SIM_DIR) && $(VVP) tb_$(MOD_NAME).vvp

	$(GTKWAVE) $(MOD_SIM_DIR)/$(WAVE_FILE) &

# ------------------------------------------------------------------------------
# Regla de advertencia para evitar uso incorrecto
# ------------------------------------------------------------------------------
sim:
	@echo "======================================================================"
	@echo " ERROR: Uso incorrecto del comando 'make sim'."
	@echo " Por favor, use 'make sim_<modulo_nombre>' para especificar el módulo."
	@echo " Ejemplo: 'make sim_alu'"
	@echo "======================================================================"
	@exit 1

# ------------------------------------------------------------------------------
# Limpieza de archivos generados
# ------------------------------------------------------------------------------
clean:
	@echo "Limpiando archivos de simulación (.vvp y .vcd)..."
	rm -rf sim/*
	rm -f $(TB_DIR)/*.vvp
	@echo "Archivos temporales eliminados."

help:
	@echo "======================================================================"
	@echo " Ayuda del Makefile para el Procesador RISC-V 32i "
	@echo "======================================================================"
	@echo " Comandos disponibles: "
	@echo "   make run                  -> Simula el procesador principal ($(TOP_MODULE))"
	@echo "   make sim_<modulo_nombre>  -> Simula un módulo específico"
	@echo "   make clean                -> Limpia los archivos generados"
	@echo "   make help                 -> Muestra esta ayuda"
	@echo "----------------------------------------------------------------------"
