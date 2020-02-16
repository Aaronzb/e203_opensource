verif := $(project)
SIM := vcs
SRC := test_name.c
CASE_NAME := case_name
SIM_DIR := $(verif)/run_sim
TMP_DIR := $(verif)/tmp_sim
COM_LOG := comp.log
RUN_LOG := run.log
TESTCASE := ${project}/riscv-tools/riscv-tests/isa/generated/rv32ui-p-addi
TESTNAME := $(notdir $(patsubst %.dump,%,${TESTCASE}.dump))
DUT    := $(verif)/rtl/e203/soc.sim.lst
TB     := $(verif)/tb/tb.sim.lst

VCS_DEFINE := -full64
VCS_DEFINE += +v2k
VCS_DEFINE += -sverilog
VCS_DEFINE += -lca
VCS_DEFINE += -kdb
VCS_DEFINE += +vcs+lic+wait
VCS_DEFINE += -override_timescale=1ns/10ps
VCS_DEFINE += -debug_access+all

RUN_DEFINE := +DUMPWAVE=1
RUN_DEFINE += +TESTCASE=$(TESTCASE)

all: clean comp_sv run 

comp_sv:
	mkdir -p $(SIM_DIR) && \
	cd $(SIM_DIR) && \
	vcs $(VCS_DEFINE) \
		-f $(DUT) \
		-f $(TB) \
		-top tb_top \
		-o simv | tee $(COM_LOG)

comp_c:
	cd $(SIM_DIR) && \
	gcc -w -pipe -fPIC -DNOT_DSM \
	  -I $(VCS_HOME)/include \
	  -I $(verif)/c_code -O \
	  -c test.c && \
	gcc -fPIC -shared -o test.so test.o

run:
	cd $(SIM_DIR) && \
	$(SIM_DIR)/simv $(RUN_DEFINE) \
	-l $(RUN_LOG)

clean:
	rm -rf $(SIM_DIR)
	


