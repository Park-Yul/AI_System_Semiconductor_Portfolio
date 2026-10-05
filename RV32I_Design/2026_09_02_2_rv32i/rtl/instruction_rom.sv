//-----------------//
// instrunction_rom
`define SIMULATION_TEST
module instrunction_rom (
  input   logic [31:0]  i_addr,
  output  logic [31:0]  o_inst
);
  // rom declaration
  logic [31:0] inst_rom  [0:127];   // 512B

  `ifdef SIMULATION_TEST
  // test instrunction
  initial begin
    // type-R
    inst_rom[0]   = 32'h0000_0033;  // add  x0,   x0,  x0    (nop)
    inst_rom[1]   = 32'h005A_00B3;  // add  x1,   x20, x5    (x1  <- 32'h0000_0019 = 25)
    inst_rom[2]   = 32'h41E4_0133;  // sub  x2,   x8,  x30   (x2  <- 32'hFFFF_FFEA = -22)
    inst_rom[3]   = 32'h00C1_C1B3;  // xor  x3,   x3,  x12   (x3  <- 32'h0000_000F = 15)
    inst_rom[4]   = 32'h00A2_E233;  // or   x4,   x5,  x10   (x4  <- 32'h0000_000F = 15)
    inst_rom[5]   = 32'h0066_F2B3;  // and  x5,   x13, x6    (x5  <- 32'h0000_0004 = 4)
    inst_rom[6]   = 32'h0051_9333;  // sll  x6,   x3,  x5    (x6  <- 32'h0000_00F0 = 240)
    inst_rom[7]   = 32'h0050_D3B3;  // srl  x7,   x1,  x5    (x7  <- 32'h0000_0001 = 1)
    inst_rom[8]   = 32'h4051_5433;  // sra  x8,   x2,  x5    (x8  <- 32'hFFFF_FFFE = -2)
    inst_rom[9]   = 32'h0020_A4B3;  // slt  x9,   x1,  x2    (x9  <- 32'h0000_0000 = 0)
    inst_rom[10]  = 32'h0020_B533;  // sltu x10,  x1,  x2    (x10 <- 32'h0000_0001 = 1)

    // type-S
    inst_rom[11]   = 32'hFE20_AE23;  // sw  x2, -4(x1)  (mem[21] is invalid in 'sw')
    inst_rom[12]   = 32'hFE20_ADA3;  // sw  x2, -5(x1)  (mem[20] <- 32'hFFFF_FFEA = -22)
    inst_rom[13]   = 32'h0022_90A3;  // sh  x2,  1(x5)  (mem[5]  is invalid in 'sh')
    inst_rom[14]   = 32'h0012_9223;  // sh  x1   4(x5)  (mem[8]  <- 16'h0019  =25)
    inst_rom[15]   = 32'h0062_9323;  // sh  x6,  6(x5)  (mem[10] <- 16'00F0   = 240)
    inst_rom[16]   = 32'h0021_8023;  // sb  x2,  0(x3)  (mem[15] <- 8'hEA     = -22)
    inst_rom[17]   = 32'hFE31_8FA3;  // sb  x3, -1(x3)  (mem[14] <- 8'0F      = 15)
    inst_rom[18]   = 32'hFE71_8F23;  // sb  x7, -2(x3)  (mem[13] <- 8'h01     = 1)
    inst_rom[19]   = 32'hFE81_8EA3;  // sb  x8  -3(x3)  (mem[12] <- 8'hFE     = -2)

    // type-I(ALU)
    inst_rom[20]   = 32'hFE60_8593;  // addi  x11,  x1, -26 (x11 <- 32'hFFFF_FFFF = -1)
    inst_rom[21]   = 32'hFF01_C613;  // xori  x12,  x3, -16 (x12 <- 32'hFFFF_FFFF = -1)
    inst_rom[22]   = 32'h0102_6693;  // ori   x13,  x4,  16 (x13 <- 32'h0000_001F = 31)
    inst_rom[23]   = 32'h00F1_7713;  // andi  x14,  x2,  15 (x14 <- 32'h0000_000A = 10)
    inst_rom[24]   = 32'h0103_9793;  // slli  x15,  x7,  16 (x15 <- 32'h0001_0000 = 65536)
    inst_rom[25]   = 32'h0101_5813;  // srli  x16,  x2,  16 (x16 <- 32'h0000_FFFF = 65535)
    inst_rom[26]   = 32'h4011_5893;  // srai  x17,  x2,   1 (x17 <- 32'hFFFF_FFF5 = -11)
    inst_rom[27]   = 32'h0648_A913;  // slti  x18,  x17,100 (x18 <- 32'h0000_0001 = 1)
    inst_rom[28]   = 32'hFFF7_B993;  // sltiu x19,  x15, -1 (x19 <- 32'h0000_0001 = 1)

    // type-I(aALU)
    inst_rom[29]   = 32'h0027_0A03;  // lb  x20,    2(x14) (x20 <- mem[12] = 32'hFFFF_FFFE =  -2)
    inst_rom[30]   = 32'hFEE6_8A83;  // lb  x21,  -18(x13) (x21 <- mem[13] = 32'h0000_0001 =   1)
    inst_rom[31]   = 32'h0198_8B03;  // lb  x22,   25(x17) (x22 <- mem[14] = 32'h0000_000F =  15)
    inst_rom[32]   = 32'h0001_8B83;  // lb  x23,    0(x3)  (x23 <- mem[15] = 32'hFFFF_FFEA = -22)
    inst_rom[33]   = 32'h0073_9C03;  // lh  x24,    7(x7)  (x24 <- mem[8]  = 32'h0000_0019 =  25)
    inst_rom[34]   = 32'hFF10_9C83;  // lh  x25,  -15(x1)  (x25 <- mem[10] = 32'h0000_00F0 = 240)
    inst_rom[35]   = 32'h0102_AD03;  // lw  x26,   16(x5)  (x26 <- mem[20] = 32'hFFFF_FFEA = -22)
    inst_rom[36]   = 32'h0178_CD83;  // lbu x27,   23(x17) (x27 <- mem[12] = 32'h0000_00FE = 254)
    inst_rom[37]   = 32'hFFF2_5E03;  // lhu x28,   -1(x4)  (x28 <- mem[14] = 32'h0000_EA0F = 59919)

    // type-B, U, J
    inst_rom[38]   = 32'h00C5_8463;  // beq   x11, x12, 8   (if x11 = =x12 go to PC+8=160)
    inst_rom[39]   = 32'hFF0F_8067;  // jarl  x0, -16(x31)  (x0 <- PC+4 = 160  and go to rs1-16=188)
    inst_rom[40]   = 32'h0139_1663;  // bne   x18, x19, 12  (if x1 8 != x19 go to PC+12=172)
    inst_rom[41]   = 32'h0107_C463;  // blt   x15, x16,  8  (if x15 < x16  go to PC+8 =172)
    inst_rom[42]   = 32'h0116_5863;  // bge   x12, x17, 16  (if x12 >= x17 go to PC+16=184)
    inst_rom[43]   = 32'h0000_0033;  // add   x0,   x0, x0  (nop)
    inst_rom[44]   = 32'h0000_0033;  // add   x0,   x0, x0  (nop)
    inst_rom[45]   = 32'h0000_0033;  // add   x0,   x0, x0  (nop)
    inst_rom[46]   = 32'h00F4_6463;  // bltu  x8,  x15,  8  (if x8 < x15 go to PC+8 = 192)
    inst_rom[47]   = 32'hF4DF_74E3;  // bgeu  x30, x13, -184(if x30 >= x13 go to PC-184 = 4)
    inst_rom[48]   = 32'h0000_1EB7;  // lui   x29, 4096     (x29 <- 32'h0000_1000 = 4096)
    inst_rom[49]   = 32'h0000_2F17;  // auipc x31, 8192     (x30 <- 32'h0000_20C4 = 8388)
    inst_rom[50]   = 32'hFD5F_FFEF;  // jal   x31, -44      (x31 <- PC+4=204 and go to PC-44=156)

  end
  `else
  initial begin
    $readmemh("./rtl/rom_code_ex1.mem", inst_rom,0,18);
  end
  `endif

  // CL
  assign o_inst = inst_rom[i_addr[31:2]];

endmodule
//-----------------//

