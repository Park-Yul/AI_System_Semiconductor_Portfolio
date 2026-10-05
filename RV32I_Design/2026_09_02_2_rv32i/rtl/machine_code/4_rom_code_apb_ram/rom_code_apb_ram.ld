main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
        li      a5,268435456
        li      a4,305418240
        addi    a4,a4,1656
        sw      a4,0(a5)
        nop
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        jr      ra
