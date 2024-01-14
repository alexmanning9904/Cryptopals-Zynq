# AXI Stream FIFO Makefile

.PHONY: default
default: test

.PHONY: clean
clean:
	rmdir /s /q xsim.dir
	del *.pb *.jou *.wdb *.log

.PHONY: test
test: xsim.dir/work.axi_stream_fifo_tb
	xsim -R axi_stream_fifo_tb

xsim.dir/work.axi_stream_fifo_tb: xsim.dir/work/axi_stream_fifo_tb.vdb xsim.dir/work/axi_stream_fifo.vdb
	xelab --debug typical axi_stream_fifo_tb

xsim.dir/work/axi_stream_fifo_tb.vdb:
	xvhdl ./axi_stream_fifo_tb.vhdl

xsim.dir/work/axi_stream_fifo.vdb:
	xvhdl ./axi_stream_fifo.vhdl