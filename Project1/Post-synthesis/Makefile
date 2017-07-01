VLOG    = ncverilog
SRC     = testfixture1.v sram_1024x8_t13.v LMFE_syn.v -v tsmc13_neg.v
VLOGARG = +define+SDF +access+r  
TMPFILE = *.log ncverilog.key nWaveLog
DBFILE  = *.fsdb *.vcd *.bak
RM      = -rm -rf

all :: sim

sim :
	$(VLOG) $(SRC) $(VLOGARG)
check :
	$(VLOG) -c $(SRC)
clean :
	$(RM) $(TMPFILE)
	
veryclean :
	$(RM) $(TMPFILE) $(DBFILE)
