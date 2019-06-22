# =========================================================================
# Makefile syntax:
# variable = value
# variable ?= value (if value isn't already set, such as an environment variable)
#
# target:  dependency1 dependency2 ...
#    <tab> command

# =========================================================================
# Key project names and directories
PROJECT ?= prbs23_small
DEVICE   = xc7z015-clg485-1
OUT_DIR  = build_${PROJECT}


# =========================================================================
# Build names
SYNTH_NAME = zynq_synth
ROUTE_NAME = zynq_route


# =========================================================================
# Xilinx Vivado build flags are in the respective '.tcl' files
# See UG894 for details


# =========================================================================
# Build recipes
# 00 - Make everything
# 01a - Load design/cores: read_vhdl xxx.vhd  read_checkpoint xxx.dcp
# 01b - Synthesis: synth_design
# 02a - Optimisation: opt_design -verbose
# 02b - Place: place_design
# 02c - Route: route_design
# 03 - BitGen (Bitstream Generation): write_bitstream


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 00 - Make everything
# Typing 'make' by itself runs the first target entry in the makefile
all: synth route

clean:
	rm -fR .Xil ${OUT_DIR}
	rm -f vivado.log vivado.jou vivado*.backup.log vivado*.backup.jou


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 01 - Synthesis
.PHONY: synth
synth: ${OUT_DIR}/${SYNTH_NAME}.dcp ${SYNTH_NAME}.tcl ${DEVICE}.xdc
${OUT_DIR}/${SYNTH_NAME}.dcp : ../../src/${PROJECT}.vhd

# Invoke the synthesis script
	@echo
	@echo
	@echo '## ---  Running Synthesis  --- ##'
	@echo
	mkdir -p ${OUT_DIR}
	vivado -mode batch -source ${SYNTH_NAME}.tcl \
		-tclargs ${OUT_DIR} ${SYNTH_NAME} ${DEVICE} ${PROJECT}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 02 - Optimise, Place and Route: route_design
.PHONY: route
route: ${OUT_DIR}/${ROUTE_NAME}.dcp ${ROUTE_NAME}.tcl
${OUT_DIR}/${ROUTE_NAME}.dcp : ${OUT_DIR}/${SYNTH_NAME}.dcp

# Invoke the opt, place and route script
	@echo
	@echo
	@echo '## ---  Running Place and Route  --- ##'
	@echo
	vivado -mode batch -source ${ROUTE_NAME}.tcl \
		-tclargs ${OUT_DIR} ${SYNTH_NAME} ${ROUTE_NAME} ${PROJECT}
