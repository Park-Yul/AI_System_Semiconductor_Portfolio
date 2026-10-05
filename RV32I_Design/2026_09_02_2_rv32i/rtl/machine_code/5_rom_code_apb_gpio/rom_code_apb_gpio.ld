main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,16777216
        li      a4,305418240
        addi    a4,a4,1656
        sw      a4,0(a5)
        sw      zero,-20(s0)
        li      a1,15
        li      a5,33554432
        addi    a0,a5,512
        call    GPIO_init
        li      a5,33554432
        addi    a0,a5,512
        call    GPIO_read
        mv      a5,a0
        sw      a5,-20(s0)
        lw      a5,-20(s0)
        mv      a1,a5
        li      a5,33554432
        addi    a0,a5,512
        call    GPIO_write
.L2:
        lw      a5,-20(s0)
        slli    a5,a5,4
        sw      a5,-20(s0)
        lw      a5,-20(s0)
        mv      a1,a5
        li      a5,33554432
        addi    a0,a5,512
        call    GPIO_write
        li      a0,10
        call    delay
        lw      a5,-20(s0)
        not     a5,a5
        mv      a1,a5
        li      a5,33554432
        addi    a0,a5,512
        call    GPIO_write
        li      a0,10
        call    delay
        j       .L2
GPIO_init:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a5,-20(s0)
        lw      a4,-24(s0)
        sw      a4,0(a5)
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
GPIO_write:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a5,-20(s0)
        lw      a4,-24(s0)
        sw      a4,4(a5)
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
GPIO_read:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        lw      a5,-20(s0)
        lw      a5,8(a5)
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
delay:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        sw      zero,-20(s0)
        sw      zero,-24(s0)
        j       .L8
.L11:
        sw      zero,-28(s0)
        j       .L9
.L10:
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
        lw      a5,-28(s0)
        addi    a5,a5,1
        sw      a5,-28(s0)
.L9:
        lw      a4,-28(s0)
        li      a5,255
        ble     a4,a5,.L10
        lw      a5,-24(s0)
        addi    a5,a5,1
        sw      a5,-24(s0)
.L8:
        lw      a4,-24(s0)
        lw      a5,-36(s0)
        blt     a4,a5,.L11
        nop
        nop
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra
