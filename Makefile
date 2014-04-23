uname := $(shell uname)
ifeq ($(uname),Darwin)
	format := macho64
endif
ifeq ($(uname),Linux)
	format := elf64
endif

fpew_test: fpew_test.c fpew.o
	gcc fpew_test.c fpew.o -o fpew_test

%.o: %.asm
	nasm -f $(format) $<

clean:
	rm -f *.o fpew_test
