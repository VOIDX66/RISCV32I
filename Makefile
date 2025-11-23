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

# Módulo Principal del Procesador (Se actualizará cuando se cree el top)
TOP_MODULE = riscv_top
TOP_TB = $(TB_DIR)/tb_$(TOP_MODULE).sv
TOP_BIN = $(TOP_MODULE).vvp

# ------------------------------------------------------------------------------
# Regla para asegurar que los directorios existan
# ------------------------------------------------------------------------------
# Directorios: src, tb, sim, docs
DIRS = $(SRC_DIR) $(TB_DIR) sim docs
$(shell mkdir -p $(DIRS))

.PHONY: all default clean run help sim sim_%

default: help

# ------------------------------------------------------------------------------
# Regla para el Módulo Principal (make run)
# Los archivos de salida (.vvp y .vcd) se quedan en la raíz del proyecto.
# ------------------------------------------------------------------------------
run: $(TOP_BIN)
	@echo "======================================================================"
	@echo " Ejecutando la simulación del módulo principal: $(TOP_MODULE) "
	@echo " VCD/VVP de salida: Raíz del proyecto "
	@echo "======================================================================"
	$(VVP) $<
	$(GTKWAVE) $(WAVE_FILE) &

$(TOP_BIN): $(TOP_TB) $(SRC_DIR)/*.sv
	@echo "Compilando módulo principal y todos los módulos fuente..."
	# ¡IMPORTANTE!: Usar -g2012 para habilitar la sintaxis de SystemVerilog
	$(IVERILOG) -g2012 -o $@ $^ $(SRC_DIR)/*.sv

# ------------------------------------------------------------------------------
# Regla Genérica para Testbenches de Módulos (make sim_<modulo>)
# Las salidas (.vvp y .vcd) se guardan en sim/<modulo_nombre>/.
# ------------------------------------------------------------------------------
sim_%:
	# Convertimos el nombre del módulo ($*) a minúsculas
	$(eval MOD_NAME := $(shell echo $* | tr '[:upper:]' '[:lower:]'))
	$(eval MOD_SIM_DIR := sim/$(MOD_NAME))
	$(eval VVP_PATH := $(MOD_SIM_DIR)/tb_$(MOD_NAME).vvp)

	@echo "======================================================================"
	@echo " Preparando y ejecutando simulación para el módulo: $(MOD_NAME) "
	@echo " Directorio de salida: $(MOD_SIM_DIR)/ "
	@echo "======================================================================"

	# 1. Crear el directorio de simulación específico
	mkdir -p $(MOD_SIM_DIR)

	# 2. Compila el módulo específico y su testbench
	$(IVERILOG) -g2012 -o $(VVP_PATH) $(TB_DIR)/tb_$(MOD_NAME).sv $(SRC_DIR)/$(MOD_NAME).sv

	# 3. Ejecuta la simulación (se cambia al directorio para que 'wave.vcd' se cree allí)
	@echo "Ejecutando $(VVP) en $(MOD_SIM_DIR)/"
	# El 'cd' se ejecuta en una subshell y el 'vvp' crea el wave.vcd dentro de esa carpeta.
	cd $(MOD_SIM_DIR) && $(VVP) tb_$(MOD_NAME).vvp
	
	# 4. Abre GTKWave, apuntando al archivo VCD dentro del directorio
	$(GTKWAVE) $(MOD_SIM_DIR)/$(WAVE_FILE) &

# ------------------------------------------------------------------------------
# Regla 'sim' de advertencia (para evitar el uso incorrecto como 'make sim alu')
# ------------------------------------------------------------------------------
sim:
	@echo "======================================================================"
	@echo " ERROR: Uso incorrecto del comando 'make sim'."
	@echo " Por favor, use 'make sim_<modulo_nombre>' para especificar el módulo."
	@echo " Ejemplo: 'make sim_alu'"
	@echo "======================================================================"
	@exit 1

# ------------------------------------------------------------------------------
# Otras Reglas
# ------------------------------------------------------------------------------
clean:
	@echo "Limpiando archivos de simulación (.vvp y .vcd)..."
	# Limpieza de archivos en la raíz (para 'make run')
	rm -f $(TOP_BIN) $(WAVE_FILE)
	# Limpieza de archivos VVP generados en tb/ (Formato antiguo)
	rm -f $(TB_DIR)/*.vvp
	# Limpieza de archivos de simulación de módulos en sim/*
	rm -rf sim/*/*.vvp sim/*/*.vcd
	@echo "Archivos temporales eliminados."

help:
	@echo "======================================================================"
	@echo " Ayuda del Makefile para el Procesador RISC-V 32i "
	@echo "======================================================================"
	@echo " Comandos disponibles: "
	@echo "   make run                  -> Simula el procesador principal ($(TOP_MODULE))"
	@echo "   make sim_<modulo_nombre>  -> Simula el testbench de un módulo específico (Ej: make sim_alu)"
	@echo "   make clean                -> Limpia los archivos generados de la simulación (.vvp y .vcd)"
	@echo "   make help                 -> Muestra esta ayuda"
	@echo "----------------------------------------------------------------------"