void sort(int *pNum, int size);

void main(void){
    int aNum[6] = {4, 10, 5, 1, 0};
    int a, b, c;

    sort(aNum, 5);

    a = 0x87654321;
    b = 0x12345678;
    c = b + a;

    return;
}

void sort(int *pNum, int size){
    int temp;
    
    for (int i = 0; i<size-1; i++){
        for(int j = 0; j<(size-1-i); j++){
            if (pNum[j] > pNum[j+1]) {
                temp = pNum[j];
                pNum[j] = pNum[j+1];
                pNum[j+1] = temp;
            }
        }
    }
    return;
}
