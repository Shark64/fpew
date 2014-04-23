fpew
====

It's assembly code that generates machine code at runtime! Specifically, it will generate a [Horner scheme](http://en.wikipedia.org/wiki/Horner's_method) polynomial evaluator for any degree polynomial you want, as long as it's less than 13. (More than that and we start to run out of `xmm` registers.)
