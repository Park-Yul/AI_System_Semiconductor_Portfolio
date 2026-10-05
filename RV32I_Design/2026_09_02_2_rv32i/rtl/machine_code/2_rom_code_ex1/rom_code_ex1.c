int adder(int a, int b);

void main(void){
	int a, sum;
    a = 0;
    sum = 0;

    while(a<10) {
        a = a + 1;
        sum = adder(sum, a);
    }

    while(1);   // halt
	return;
 }

 int adder(int a, int b) {
    return a + b;
 }
