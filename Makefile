all: decoder

decoder: decoder.v decoder_tb.v
	iverilog -o $@ $^

check: decoder fpgadecoder.dump
	@tmpfile=$$(mktemp /tmp/fpgadecoder-XXXXXX.dump); \
	vvp decoder > $$tmpfile && diff $$tmpfile fpgadecoder.dump; \
	rv=$$?; \
	rm -f $$tmpfile; \
	exit $$rv

clean:
	rm -f decoder

.phony: clean check
