TB_TOP = tb_spi

DUT_RTL=../rtl.f

VCS_OPT += +v2k
VCS_OPT += +sverilog
VCS_OPT += -debug_access+all
VCS_OPT += -full64
 

vcs 00:
	vcs $(VCS_OPT) -f $(DUT_RTL) 
	./simv 
verdi 01:
	verdi -sv -ssv -ssf $(TB_TOP).fsdb -f $(DUT_RTL)& 

  
