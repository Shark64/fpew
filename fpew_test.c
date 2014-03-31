#include <stdlib.h>
#include <stdio.h>
#include "fpew.h"

void gen_exp_maclaurin(double* p, unsigned int degree) {
  int i; double k;                        p[0] = 1.0;
  for(i=1, k=1.0; i<=degree; i++, k+=1.0) p[i] = p[i-1]/k;
}

int main() {
  int i;
  double exp_coeffs[16];
  double input[16] = {
    0.0, 0.25, 0.5, 0.75,
    1.0, 1.25, 1.5, 1.75,
    2.0, 2.25, 2.5, 2.75,
    3.0, 3.25, 3.5, 3.75};
  double output[16];

  gen_exp_maclaurin(exp_coeffs,13);
  polydf horner13 = gen_horner_d(13);
  horner13(output,input,exp_coeffs,4);

  for(i=0;i<sizeof(input)/sizeof(double);i++)
    printf("exp(%.3lf) = %.7lf\n",input[i],output[i]);
  return 0;
}
