fpew
====

It's assembly code that generates machine code at runtime! Specifically, it will generate a [Horner scheme](http://en.wikipedia.org/wiki/Horner's_method) polynomial evaluator for any degree polynomial you want, as long as it's less than 13. (More than that and we start to run out of `xmm` registers.)

Sample run:
```
bash-3.2$ git clone https://github.com/davidad/fpew
Cloning into 'fpew'...
bash-3.2$ cd fpew
bash-3.2$ make
nasm -f macho64 fpew.asm
gcc fpew_test.c fpew.o -o fpew_test
bash-3.2$ ./fpew_test
exp(0.000) = 1.0000000
exp(0.250) = 1.2840254
exp(0.500) = 1.6487213
exp(0.750) = 2.1170000
exp(1.000) = 2.7182818
exp(1.250) = 3.4903430
exp(1.500) = 4.4816891
exp(1.750) = 5.7546026
exp(2.000) = 7.3890559
exp(2.250) = 9.4877347
exp(2.500) = 12.1824888
exp(2.750) = 15.6426121
exp(3.000) = 20.0854686
exp(3.250) = 25.7901261
exp(3.500) = 33.1148359
exp(3.750) = 42.5194293
```
