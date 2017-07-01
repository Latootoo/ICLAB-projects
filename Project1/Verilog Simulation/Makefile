VLOG    = ncverilog +nospecify +notimingchecks
SRC     = testfixture1.v sram_1024x8_t13.v LMFE.v
VLOGARG = +access+r  
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
