package rv32i_pkg;

// instrunction type
typedef enum logic  [6:0]{
  OP_RTYPE      = 7'b011_0011,
  OP_STYPE      = 7'b010_0011,
  OP_ITYPE_ALU  = 7'b001_0011,
  OP_ITYPE_LD   = 7'b000_0011,
  OP_BTYPE      = 7'b110_0011,
  OP_LUI        = 7'b011_0111,
  OP_AUIPC      = 7'b001_0111,
  OP_JAL        = 7'b110_1111,
  OP_JALR       = 7'b110_0111
} opcode_e;

// insrtunction name(R-type)
typedef enum logic  [3:0]{
  ADD   = 4'b0000,
  SUB   = 4'b1000,
  XOR   = 4'b0100,
  OR    = 4'b0110,
  AND   = 4'b0111,
  SLL   = 4'b0001,
  SRL   = 4'b0101,
  SRA   = 4'b1101,
  SLT   = 4'b0010,
  SLTU  = 4'b0011
} rv32i_inst_r;

// insrtunction name(S-type)
typedef enum logic  [2:0]{
  SB    = 3'b000,
  SH    = 3'b001,
  SW    = 3'b010
} rv32i_inst_s;

// insrtunction name(I(ALU)-type)
typedef enum logic  [3:0]{
  ADDI    = 4'b0000,
  ADD_I   = 4'b1000,
  XORI    = 4'b0100,
  XOR_I   = 4'b1100,
  ORI     = 4'b0110,
  OR_I    = 4'b1110,
  ANDI    = 4'b0111,
  AND_I   = 4'b1111,
  SLLI    = 4'b0001,
  SLL_I   = 4'b1001,
  SRLI    = 4'b0101,
  SRAI    = 4'b1101,
  SLTI    = 4'b0010,
  SLT_I   = 4'b1010,
  SLTUI   = 4'b0011,
  SLTU_I  = 4'b1011
} rv32i_inst_i_alu;

// insrtunction name(I(LD)-type)
typedef enum logic  [2:0]{
  LB    = 3'b000,
  LH    = 3'b001,
  LW    = 3'b010,
  LBU   = 3'b100,
  LHU   = 3'b101
} rv32i_inst_i_ld;


// instrunction name(B-type)
typedef enum logic [2:0]{
  BEQ   = 3'b000,
  BNE   = 3'b001,
  BLT   = 3'b100,
  BGE   = 3'b101,
  BLTU  = 3'b110,
  BGEU  = 3'b111
} rv32i_inst_b;

endpackage
