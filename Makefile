all: fpgadecoder_tb

fpgadecoder_tb: fpgadecoder.v fpgadecoder_tb.v
	iverilog -o $@ $^

check: fpgadecoder_tb fpgadecoder.dump
	@tmpfile=$$(mktemp /tmp/fpgadecoder-XXXXXX.dump); \
	vvp fpgadecoder_tb > $$tmpfile && diff $$tmpfile fpgadecoder.dump; \
	rv=$$?; \
	rm -f $$tmpfile; \
	exit $$rv

clean:
	rm -f fpgadecoder_tb

.phony: clean check
