// RAM: base address 0x10000000
// GPI:  CTR : 0x20000000, IDR : 0x20000004
// GPO:  CTR : 0x20000100, ODR : 0x20000104
// GPIO: CTR : 0x20000200, ODR : 0x20000204, IDR : 0x20000208

#define APB_RAM         (0x1000000)
#define APB_PERIPHERAL  (0x2000000)
#define APB_GPI         (APB_PERIPHERAL + 0x000u)
#define APB_GPO         (APB_PERIPHERAL + 0x100u)
#define APB_GPIO        (APB_PERIPHERAL + 0x200u)
// #define APB_UART        (APB_PERIPHERAL + 0x300u)
// #define APB_FND         (APB_PERIPHERAL + 0x400u)

#define __IO        volatile

typedef struct {
    __IO    unsigned int        CTR;
    __IO    unsigned int        IDR;
} GPI_typedef;

typedef struct {
    __IO    unsigned int        CTR;
    __IO    unsigned int        ODR;
} GPO_typedef;

typedef struct {
    __IO    unsigned int        CTR;
    __IO    unsigned int        ODR;
    __IO    unsigned int        IDR;
} GPIO_typedef;

#define GPI_A       ((GPI_typedef *) APB_GPI)
#define GPO_B       ((GPO_typedef *) APB_GPO)
#define GPIO_C       ((GPIO_typedef *) APB_GPIO)

void GPIO_init(GPIO_typedef *GPIO, unsigned int control);
void GPIO_write (GPIO_typedef *GPIO, unsigned int wdata);
unsigned int GPIO_read (GPIO_typedef *GPIO);
void delay(int n);

void main(void){
    // RAM
    *(unsigned int *)  APB_RAM = 0x12345678;

    int in_sw = 0;
    // setup GPIO
    GPIO_init(GPIO_C, 0x0000000f);
    in_sw = GPIO_read(GPIO_C);
    GPIO_write(GPIO_C, in_sw);

    while(1){
        in_sw = in_sw << 4;
        GPIO_write(GPIO_C, in_sw);
        delay(10);
        GPIO_write(GPIO_C, (~in_sw));
        delay(10);
    }
    

}

void GPIO_init (GPIO_typedef *GPIO, unsigned int control){
    GPIO->CTR = control;
}

void GPIO_write (GPIO_typedef *GPIO, unsigned int wdata){
    GPIO->ODR = wdata;
}

unsigned int GPIO_read (GPIO_typedef *GPIO){
    return GPIO->IDR;
}

void delay(int n){
    unsigned int temp = 0;
    for (int i = 0; i<n ; i++){
        for (int j = 0; j<256; j++){
            temp++;
        }
    }
}
