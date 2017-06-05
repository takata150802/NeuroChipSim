VERILOG_SRC_DIR=\"../src\"
TEST_BENCH=\"./fifo16_test.v\"
SETUP_SCRIPT=\"../env/hal_env\"

rtl.log : fifo16_test.v
	rm -rf INCA_libs
	source ${SETUP_SCRIPT}
	ncverilog \
	-l $@ \
	+incdir+${VERILOG_SRC_DIR} \
	+libext+.v \
	+licq \
	+turbo+3 \
	+access+rw \
	${TEST_BENCH}

clean :
	rm -rf INCA_libs rtl.log
