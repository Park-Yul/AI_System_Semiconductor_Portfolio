`include "./pkg/rv32i_pkg.sv"
//-----------------//
// control_unit
module control_unit(
  input   logic         i_clk,
  input   logic         i_rst_n,
  input   logic [31:0]  i_inst,
  input   logic         i_b_taken,
  input   logic [31:0]  i_rs1,
  output  logic [31:0]  o_addr,
  output  logic         o_we,
  output  logic [4:0]   o_wa,
  output  logic [4:0]   o_ra1,
  output  logic [4:0]   o_ra2,
  output  logic         o_alu_srcsel,
  output  logic [3:0]   o_alu_control,
  output  logic [2:0]   o_rf_srcsel,
  output  logic         o_ram_we,
  output  logic [2:0]   o_type,
  output  logic [31:0]  o_imm_ext,
  output  logic [31:0]  o_pc_imm,
  output  logic [31:0]  o_pc_4
);
  // logic declaration
  logic         w_branch;
  logic         w_jump;
  logic         w_jalr;
  logic [31:0]  w_imm_ext;

  // CL
  assign o_imm_ext = w_imm_ext;

  // program_counter instantiation
  program_counter U_PROGRAM_COUNTER(
    .*,
    .i_branch (w_branch),
    .i_b_taken(i_b_taken),
    .i_jalr   (w_jalr),
    .i_imm_ext(w_imm_ext),
    .i_rs1    (i_rs1),
    .i_jump   (w_jump),
    .o_addr   (o_addr),
    .o_pc_imm (o_pc_imm),
    .o_pc_4   (o_pc_4)
  );

  // instrunction_decoder instantiation
  instruction_decoder U_INSTRUNCTION_DECODER(
    .i_inst       (i_inst),
    .o_we         (o_we),
    .o_wa         (o_wa),
    .o_ra1        (o_ra1),
    .o_ra2        (o_ra2),
    .o_alu_srcsel (o_alu_srcsel),
    .o_alu_control(o_alu_control),
    .o_rf_srcsel  (o_rf_srcsel),
    .o_ram_we     (o_ram_we),
    .o_type       (o_type),
    .o_branch     (w_branch),
    .o_jump       (w_jump),
    .o_jalr       (w_jalr)
  );

  // imm_extend instantiation
  imm_extend U_IMM_EXTEND(
    .i_inst   (i_inst),
    .o_imm_ext(w_imm_ext)
  );


endmodule
//-----------------//


//-----------------//
// program_counter
module program_counter(
  input   logic         i_clk,
  input   logic         i_rst_n,
  input   logic         i_branch,
  input   logic         i_b_taken,
  input   logic         i_jalr,
  input   logic [31:0]  i_imm_ext,
  input   logic [31:0]  i_rs1,
  input   logic         i_jump,
  output  logic [31:0]  o_addr,
  output  logic [31:0]  o_pc_imm,
  output  logic [31:0]  o_pc_4
);
  // logic declaration
  logic [31:0]  c_addr, n_addr;
  logic [31:0]  w_pc_imm;
  logic [31:0]  w_pc_4;
  logic [31:0]  w_pc_rs1_mux_out;
  logic         w_or_jump_btaken;
  logic         w_pc_imm_mux_sel;

  // mux_2x1 instantiation
  mux_2x1 U_PC_RS1_MUX(
    .i_mux_in0(c_addr),
    .i_mux_in1(i_rs1),
    .i_mux_sel(i_jalr),
    .o_mux_out(w_pc_rs1_mux_out)
  );
  mux_2x1 U_PC_IMM_MUX(
    .i_mux_in0(w_pc_4),
    .i_mux_in1(w_pc_imm),
    .i_mux_sel(w_pc_imm_mux_sel),
    .o_mux_out(n_addr)
  );

  // CL
  assign o_addr           = c_addr;
  assign w_pc_imm         = w_pc_rs1_mux_out + i_imm_ext;
  assign w_pc_4           = c_addr + 4;
  assign o_pc_imm         = w_pc_imm;
  assign o_pc_4           = w_pc_4;
  assign w_or_jump_btaken = i_jump | i_b_taken;
  assign w_pc_imm_mux_sel = i_branch & w_or_jump_btaken;

  // SL
  always_ff @(posedge i_clk) begin
    if(!i_rst_n)  c_addr  <=32'h0;
    else begin
       c_addr  <=  n_addr;
    end
  end

endmodule
//-----------------//


//-----------------//
// instruction_decoder
module instruction_decoder
  import rv32i_pkg::*;
(
  input   logic [31:0]  i_inst,
  output  logic         o_we,
  output  logic [4:0]   o_wa,
  output  logic [4:0]   o_ra1,
  output  logic [4:0]   o_ra2,
  output  logic         o_alu_srcsel,
  output  logic [3:0]   o_alu_control,
  output  logic [2:0]   o_rf_srcsel,
  output  logic         o_ram_we,
  output  logic [2:0]   o_type,
  output  logic         o_branch,
  output  logic         o_jump,
  output  logic         o_jalr
);
  // logic declaration
  opcode_e    w_opcode;
  assign      w_opcode = opcode_e'(i_inst[6:0]);

  // for debugging
  rv32i_inst_r       w_inst_r;
  rv32i_inst_s       w_inst_s;
  rv32i_inst_i_alu   w_inst_i_alu;
  rv32i_inst_i_ld    w_inst_i_ld;
  rv32i_inst_b       w_inst_b;
  assign w_inst_r     =rv32i_inst_r'({i_inst[30], i_inst[14:12]});        // type-R
  assign w_inst_s     =rv32i_inst_s'(i_inst[14:12]);                    // type-S
  assign w_inst_i_alu =rv32i_inst_i_alu'({i_inst[30], i_inst[14:12]});    // type-I(ALU)
  assign w_inst_i_ld  =rv32i_inst_i_ld'(i_inst[14:12]);                 // type-I(LD)
  assign w_inst_b     =rv32i_inst_b'(i_inst[14:12]);                    // type-B

  // CL
  always_comb begin
      o_we          = 1'b0;
      o_alu_srcsel  = 1'b0;
      o_alu_control = 4'b0_000;
      o_rf_srcsel   = 3'b000;
      o_ram_we      = 1'b0;
      o_type        = 3'b111; // ram default
      o_branch      = 1'b0;
      o_jump        = 1'b0;
      o_jalr        = 1'b0;
    case(w_opcode)
      OP_RTYPE : begin // R-type
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b0;
        o_alu_control = {i_inst[30], i_inst[14:12]};
        o_rf_srcsel   = 3'b000;
        o_ram_we      = 1'b0;
        o_type        = 3'b111; // ram default
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_STYPE : begin // S-type
        o_we          = 1'b0;
        o_alu_srcsel  = 1'b1;
        o_alu_control = 4'b0_000; // add
        o_rf_srcsel   = 3'b000;   // don't care
        o_ram_we      = 1'b1;
        o_type        = i_inst[14:12];  // store
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_ITYPE_ALU : begin // I-type(operation)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b1;
        if(i_inst[14:12] == 3'b101) o_alu_control = {i_inst[30],  i_inst[14:12]};
        else                        o_alu_control = {1'b0,        i_inst[14:12]};
        o_rf_srcsel   = 3'b000; // alu_result
        o_ram_we      = 1'b0;
        o_type        = 3'b111; // ram default
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_ITYPE_LD : begin // I-type(load)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b1;
        o_alu_control = 4'b0_000; // add
        o_rf_srcsel   = 3'b001;   // i_ram_rd
        o_ram_we      = 1'b0;
        o_type        = i_inst[14:12];
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_BTYPE    : begin // B-type
        o_we          = 1'b0;
        o_alu_srcsel  = 1'b0;
        o_alu_control = {1'b0, i_inst[14:12]};
        o_rf_srcsel   = 3'b000; // don't care
        o_ram_we      = 1'b0;
        o_type        = 3'b111; // ram default
        o_branch      = 1'b1;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_LUI      : begin // U-type(LUI)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b0;     // don't care
        o_alu_control = 4'b0_000; // don't care
        o_rf_srcsel   = 3'b010;   // imm
        o_ram_we      = 1'b0;
        o_type        = 3'b111;   // ram default
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_AUIPC    : begin // U-type(AUIPC)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b0;     // don't care
        o_alu_control = 4'b0_000; // don't care
        o_rf_srcsel   = 3'b011;   // pc+imm
        o_ram_we      = 1'b0;
        o_type        = 3'b111;   // ram default
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
      end
      OP_JAL      : begin // J-type(JAL)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b0;     // don't care
        o_alu_control = 4'b0_000; // don't care
        o_rf_srcsel   = 3'b100;   // pc+4
        o_ram_we      = 1'b0;
        o_type        = 3'b111;   // ram default
        o_branch      = 1'b1;
        o_jump        = 1'b1; 
        o_jalr        = 1'b0;     //  pc+imm
      end
      OP_JALR      : begin  // I-type(JALR)
        o_we          = 1'b1;
        o_alu_srcsel  = 1'b0;     // don't care
        o_alu_control = 4'b0_000; // don't care
        o_rf_srcsel   = 3'b100;   // pc+4
        o_ram_we      = 1'b0;
        o_type        = 3'b111;   // ram default
        o_branch      = 1'b1;
        o_jump        = 1'b1;
        o_jalr        = 1'b1;     // rs1+imm
      end
    endcase
  end

  // CL
  assign  o_wa  = i_inst[11:7];
  assign  o_ra1 = i_inst[19:15];
  assign  o_ra2 = i_inst[24:20];
endmodule
//-----------------//


//-----------------//
// imm_extend
module imm_extend
  import rv32i_pkg::*;
(
  input   logic [31:0]    i_inst,
  output  logic [31:0]    o_imm_ext
);
  // logic declaration
  opcode_e  w_opcode;
  assign    w_opcode = opcode_e'(i_inst[6:0]);  // opcode_e' : casting operation

  // CL
  always_comb begin
    o_imm_ext = 32'h0;
    case(w_opcode)
      OP_STYPE      : o_imm_ext = {{20{i_inst[31]}},i_inst[31:25], i_inst[11:7]};                                 // S-type
      OP_ITYPE_ALU  : begin
        if((i_inst[14:12] == 3'b101) || (i_inst[14:12] == 3'b001))
          begin
            o_imm_ext = {27'b0,i_inst[24:20]};
          end
          else begin
            o_imm_ext = {{20{i_inst[31]}},i_inst[31:20]};
          end
        end          // I-type(operation)
      OP_ITYPE_LD   : o_imm_ext = {{20{i_inst[31]}},i_inst[31:20]};                                               // I-type(load)
      OP_BTYPE      : o_imm_ext = {{19{i_inst[31]}},i_inst[31], i_inst[7],i_inst[30:25], i_inst[11:8], 1'b0};     // B-type
      OP_LUI        : o_imm_ext = {i_inst[31:12], 12'b0};                                                         // U-type(LUI)
      OP_AUIPC      : o_imm_ext = {i_inst[31:12], 12'b0};                                                         // U-type(AUIPC)
      OP_JAL        : o_imm_ext = {{11{i_inst[31]}}, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0}; // J-type(JAL)
      OP_JALR       : o_imm_ext = {{20{i_inst[31]}},i_inst[31:20]};                                               // I-type(JALR)
    endcase
  end

endmodule
//-----------------//
