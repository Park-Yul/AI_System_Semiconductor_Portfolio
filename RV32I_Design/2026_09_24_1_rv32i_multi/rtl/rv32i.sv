//------------------//
// top_rv32i
`define DEBUG 
module top_rv32i (
`ifdef DEBUG
    input logic i_clk,
    input logic i_rst_n,
    output logic [6:0] o_debug
`else
    input logic i_clk,
    input logic i_rst_n
`endif
);

    // logic declaration
    logic [31:0] w_pc;
    logic [31:0] w_inst;
    logic        w_ram_we;
    logic [31:0] w_ram_wa;
    logic [31:0] w_ram_wd;
    logic [31:0] w_ram_rd;
    logic [ 2:0] w_type;


`ifdef DEBUG
    // assignment for debugging
    assign o_debug[0] = w_pc[0];
    assign o_debug[1] = w_inst[0];
    assign o_debug[2] = w_ram_we;
    assign o_debug[3] = w_ram_wa[0];
    assign o_debug[4] = w_ram_wd[0];
    assign o_debug[5] = w_ram_rd[0];
    assign o_debug[6] = w_type[0];
`endif

    // instrunction_rom instantiation
    instrunction_rom U_INSTRUNCTION_ROM (
        .i_pc  (w_pc),
        .o_inst(w_inst)
    );

    // rv32i_cpu instantiation
    rv32i_cpu U_RV32I_CPU (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_inst  (w_inst),
        .i_ram_rd(w_ram_rd),
        .o_pc    (w_pc),
        .o_ram_we(w_ram_we),
        .o_ram_wa(w_ram_wa),
        .o_ram_wd(w_ram_wd),
        .o_type  (w_type)
    );

    // data_ram instantiation
    data_ram U_DATA_RAM (
        .i_clk   (i_clk),
        .i_ram_we(w_ram_we),
        .i_ram_wa(w_ram_wa),
        .i_ram_wd(w_ram_wd),
        .i_type  (w_type),
        .o_ram_rd(w_ram_rd)
    );
endmodule
//------------------//


//------------------//
// rv32i_cpu
module rv32i_cpu (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [31:0] i_inst,
    input  logic [31:0] i_ram_rd,
    output logic [31:0] o_pc,
    output logic        o_ram_we,
    output logic [31:0] o_ram_wa,
    output logic [31:0] o_ram_wd,
    output logic [ 2:0] o_type
);
    // logic declaration
    logic        w_b_taken;
    logic [31:0] w_pc_branch;
    logic [ 4:0] w_ra1;
    logic [ 4:0] w_ra2;
    logic [31:0] w_imm_ext;
    logic        w_alu_srcsel;
    logic [ 3:0] w_alu_control;
    logic [31:0] w_pc_delay;
    logic        w_jalr;
    logic [ 2:0] w_rf_srcsel;
    logic        w_we;
    logic [ 4:0] w_wa;
    logic        w_en_dof_ex;
    logic        w_en_ex_wb;

    // control_unit instantiation
    control_unit U_CONTROL_UNIT (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_b_taken    (w_b_taken),
        .i_pc_branch  (w_pc_branch),
        .i_inst       (i_inst),
        .o_pc         (o_pc),
        .o_ra1        (w_ra1),
        .o_ra2        (w_ra2),
        .o_imm_ext    (w_imm_ext),
        .o_alu_srcsel (w_alu_srcsel),
        .o_alu_control(w_alu_control),
        .o_ram_we     (o_ram_we),
        .o_type       (o_type),
        .o_pc_delay   (w_pc_delay),
        .o_jalr       (w_jalr),
        .o_rf_srcsel  (w_rf_srcsel),
        .o_we         (w_we),
        .o_wa         (w_wa),
        .o_en_dof_ex  (w_en_dof_ex),
        .o_en_ex_wb   (w_en_ex_wb)
    );
    // datapath instantiation
    datapath U_DATAPAHT (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_ra1        (w_ra1),
        .i_ra2        (w_ra2),
        .i_imm_ext    (w_imm_ext),
        .i_alu_srcsel (w_alu_srcsel),
        .i_alu_control(w_alu_control),
        .i_ram_rd     (i_ram_rd),
        .i_pc_delay   (w_pc_delay),
        .i_jalr       (w_jalr),
        .i_rf_srcsel  (w_rf_srcsel),
        .i_we         (w_we),
        .i_wa         (w_wa),
        .i_en_dof_ex  (w_en_dof_ex),
        .i_en_ex_wb   (w_en_ex_wb),
        .o_ram_wa     (o_ram_wa),
        .o_ram_wd     (o_ram_wd),
        .o_b_taken    (w_b_taken),
        .o_pc_branch  (w_pc_branch)
    );
endmodule
//------------------//
