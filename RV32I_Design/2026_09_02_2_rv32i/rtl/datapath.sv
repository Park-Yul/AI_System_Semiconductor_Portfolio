//------------------//
// datapath
//`define SIMULATION
`include "define.svh"
module datapath(
  input   logic         i_clk,
  input   logic         i_rst_n,
  input   logic         i_we,
  input   logic [4:0]   i_wa,
  input   logic [4:0]   i_ra1,
  input   logic [4:0]   i_ra2,
  input   logic         i_alu_srcsel,
  input   logic [31:0]  i_imm_ext,
  input   logic [3:0]   i_alu_control,
  input   logic [2:0]   i_rf_srcsel,
  input   logic [31:0]  i_ram_rd,
  input   logic [31:0]  i_pc_imm,
  input   logic [31:0]  i_pc_4,
  output  logic [31:0]  o_ram_wa,
  output  logic [31:0]  o_ram_wd,
  output  logic         o_b_taken,
  output  logic [31:0]  o_rs1
);

  // logic delcaration
  logic [31:0]    w_reg_out1, w_reg_out2;
  logic [31:0]    w_imm_ext;
  logic [31:0]    w_mux_alu_out;
  logic [31:0]    w_alu_result;
  logic [31:0]    w_mux_rf_out;

  // reg_file instantiation
  reg_file U_REG_FILE(
    .*,
    .i_we (i_we),
    .i_wa (i_wa),
    .i_wd (w_mux_rf_out),
    .i_ra1(i_ra1),
    .i_ra2(i_ra2),
    .o_rd1(w_reg_out1),
    .o_rd2(w_reg_out2)
  );

  // mux_2x1 instantiation
  mux_2x1 U_MUX_2X1_ALU(
    .i_mux_in0(w_reg_out2),
    .i_mux_in1(w_imm_ext),
    .i_mux_sel(i_alu_srcsel),
    .o_mux_out(w_mux_alu_out)
  );


  // alu instantiation
  alu U_ALU(
    .i_alu_in1    (w_reg_out1),
    .i_alu_in2    (w_mux_alu_out),
    .i_alu_control(i_alu_control),
    .o_alu_result (w_alu_result),
    .o_b_taken    (o_b_taken)
  );

  // mux_5x1 instantiation
  mux_5x1 U_MUX_5X1_RF(
    .i_mux_in0(w_alu_result),
    .i_mux_in1(i_ram_rd),
    .i_mux_in2(w_imm_ext),
    .i_mux_in3(i_pc_imm),
    .i_mux_in4(i_pc_4),
    .i_mux_sel(i_rf_srcsel),
    .o_mux_out(w_mux_rf_out)
  );

  // CL
  assign  w_imm_ext   = i_imm_ext;
  assign  o_rs1       = w_reg_out1;
  assign  o_ram_wa    = w_alu_result;
  assign  o_ram_wd    = w_reg_out2;

endmodule
//------------------//


//-----------------//
// reg_file
module reg_file(
  input   logic         i_clk,
  input   logic         i_rst_n,
  input   logic         i_we,
  input   logic [4:0]   i_wa,
  input   logic [31:0]  i_wd,
  input   logic [4:0]   i_ra1,
  input   logic [4:0]   i_ra2,
  output  logic [31:0]  o_rd1,
  output  logic [31:0]  o_rd2
);
  // ram delcaration
  logic [31:0] ram_file [1:31];

  // integer for loop
  int i;

  // SL
  always_ff @(posedge i_clk) begin
    if(!i_rst_n) begin  // temp reset for machine code test
    `ifdef  SIMULATION
      for(i=1 ; i < 32 ; i=i+1) begin
        ram_file[i] <=  i;
      end
    `endif
    end
    else begin
      if(i_we) ram_file[i_wa] <=  i_wd;
    end
  end

  // CL
  assign o_rd1 = ( i_ra1 != 0 ) ? ram_file[i_ra1] : 32'h0;
  assign o_rd2 = ( i_ra2 != 0 ) ? ram_file[i_ra2] : 32'h0;

endmodule
//-----------------//


//-----------------//
// alu
module alu (
  input   logic [31:0]  i_alu_in1,
  input   logic [31:0]  i_alu_in2,
  input   logic [3:0]   i_alu_control,
  output  logic [31:0]  o_alu_result,
  output  logic         o_b_taken
);
  // CL
  always_comb begin
    o_alu_result = 32'h0000_0000;
    case(i_alu_control)
      `ADD  : o_alu_result = i_alu_in1 +  i_alu_in2;   // add
      `SUB  : o_alu_result = i_alu_in1 -  i_alu_in2;   // sub
      `XOR  : o_alu_result = i_alu_in1 ^  i_alu_in2;   // xor
      `OR   : o_alu_result = i_alu_in1 |  i_alu_in2;   // or
      `AND  : o_alu_result = i_alu_in1 &  i_alu_in2;   // and
      `SLL  : o_alu_result = i_alu_in1 << i_alu_in2;   // sll
      `SRL  : o_alu_result = i_alu_in1 >> i_alu_in2;   // srl
      `SRA  : o_alu_result = $signed(i_alu_in1) >>>i_alu_in2;   // sra
      `SLT  : o_alu_result = ($signed(i_alu_in1)    < $signed(i_alu_in2))   ? 32'h1 : 32'h0;  // slt
      `SLTU : o_alu_result = ($unsigned(i_alu_in1)   < $unsigned(i_alu_in2)) ? 32'h1 : 32'h0;  // sltu
    endcase
  end

  // CL
  always_comb begin
    o_b_taken = 1'b0;
    case(i_alu_control)
      `BEQ  : begin // beq
        if(i_alu_in1 == i_alu_in2)  o_b_taken = 1'b1;
        else                        o_b_taken = 1'b0;
      end
      `BNE  : begin // bne
        if(i_alu_in1 != i_alu_in2)  o_b_taken = 1'b1;
        else                        o_b_taken = 1'b0;
      end
      `BLT  : begin // blt
        if($signed(i_alu_in1) < $signed(i_alu_in2)) o_b_taken = 1'b1;
        else                                        o_b_taken = 1'b0;
      end
      `BGE  : begin // bge
        if($signed(i_alu_in1) >= $signed(i_alu_in2))  o_b_taken = 1'b1;
        else                                          o_b_taken = 1'b0;
      end
      `BLTU : begin // bltu
        if($unsigned(i_alu_in1) < $unsigned(i_alu_in2)) o_b_taken = 1'b1;
        else                                            o_b_taken = 1'b0;
      end
      `BGEU : begin // bgeu
        if($unsigned(i_alu_in1) >= $unsigned(i_alu_in2))  o_b_taken = 1'b1;
        else                                              o_b_taken = 1'b0;
      end
    endcase
  end
endmodule
//-----------------//


//-----------------//
// mux_2x1
module mux_2x1(
  input   logic [31:0]      i_mux_in0,
  input   logic [31:0]      i_mux_in1,
  input   logic             i_mux_sel,
  output  logic [31:0]      o_mux_out
);
  // CL
  assign o_mux_out = (i_mux_sel) ? i_mux_in1 : i_mux_in0;

endmodule
//-----------------//


//-----------------//
// mux_5x1
module mux_5x1(
  input   logic [31:0]      i_mux_in0,
  input   logic [31:0]      i_mux_in1,
  input   logic [31:0]      i_mux_in2,
  input   logic [31:0]      i_mux_in3,
  input   logic [31:0]      i_mux_in4,
  input   logic [2:0]       i_mux_sel,
  output  logic [31:0]      o_mux_out
);
  // CL
  always_comb begin
    o_mux_out = i_mux_in0;
    case(i_mux_sel)
      3'b000: o_mux_out = i_mux_in0;
      3'b001: o_mux_out = i_mux_in1;
      3'b010: o_mux_out = i_mux_in2;
      3'b011: o_mux_out = i_mux_in3;
      3'b100: o_mux_out = i_mux_in4;
    endcase
  end
endmodule
//-----------------//
