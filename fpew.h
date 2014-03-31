typedef void (*polydf)(double*, double*, double*, unsigned int);
// arguments: destination, source, coefficients, number of elements / 4
polydf gen_horner_d(unsigned int degree);
