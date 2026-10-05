`include "./pkg/rv32i_pkg.sv"
//-----------------//
// control_unit
module control_unit (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_b_taken,
    input  logic [31:0] i_pc_branch,
    input  logic [31:0] i_inst,
    output logic [31:0] o_pc,
    output logic [ 4:0] o_ra1,
    output logic [ 4:0] o_ra2,
    output logic [31:0] o_imm_ext,
    output logic        o_alu_srcsel,
    output logic [ 3:0] o_alu_control,
    output logic        o_ram_we,
    output logic [ 2:0] o_type,
    output logic [31:0] o_pc_delay,
    output logic        o_jalr,
    output logic [ 2:0] o_rf_srcsel,
    output logic        o_we,
    output logic [ 4:0] o_wa,
    output logic        o_en_dof_ex,
    output logic        o_en_ex_wb
);
    // logic declaration
    // FSM
    logic        w_en_if_dof;
    logic        w_en_dof_ex;
    logic        w_en_ex_wb;
    logic        w_pc_en;
    // IF
    logic [31:0] w_pc_if;
    logic [31:0] w_inst_if;
    // DOF
    logic [31:0] w_pc_dof;
    logic [31:0] w_inst_dof;
    logic [ 4:0] w_ra1_dof;
    logic [ 4:0] w_ra2_dof;
    logic [31:0] w_imm_ext_dof;
    logic        w_alu_srcsel_dof;
    logic [ 3:0] w_alu_control_dof;
    logic        w_ram_we_dof;
    logic [ 2:0] w_type_dof;
    logic        w_branch_dof;
    logic        w_jump_dof;
    logic        w_jalr_dof;
    logic [ 2:0] w_rf_srcsel_dof;
    logic        w_we_dof;
    logic [ 4:0] w_wa_dof;
    // EX
    logic [31:0] w_pc_ex;
    logic [ 3:0] w_alu_control_ex;
    logic        w_ram_we_ex;
    logic [ 2:0] w_type_ex;
    logic        w_branch_ex;
    logic        w_jump_ex;
    logic        w_jalr_ex;
    logic [ 2:0] w_rf_srcsel_ex;
    logic        w_we_ex;
    logic [ 4:0] w_wa_ex;
    // WB
    logic [ 2:0] w_rf_srcsel_wb;
    logic        w_we_wb;
    logic [ 4:0] w_wa_wb;

    // CL(enable signal)
    assign o_en_dof_ex = w_en_dof_ex;
    assign o_en_ex_wb = w_en_ex_wb;

    // fsm instantiation
    fsm U_FSM (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .o_en_if_dof(w_en_if_dof),
        .o_en_dof_ex(w_en_dof_ex),
        .o_en_ex_wb (w_en_ex_wb),
        .o_pc_en    (w_pc_en)
    );

    // program_counter instantiation
    program_counter U_PROGRAM_COUNTER (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_pc_en    (w_pc_en),
        .i_branch   (w_branch_ex),
        .i_b_taken  (i_b_taken),
        .i_jump     (w_jump_ex),
        .i_pc_branch(i_pc_branch),
        .o_pc       (w_pc_if)
    );

    // CL(IF)
    assign o_pc      = w_pc_if;
    assign w_inst_if = i_inst;

    // register_en(IF -> DOF) instantiation
    register_en #(
        .DATA_WIDTH(32)
    ) U_REG_EN_PC_IF_TO_DOF (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_if_dof),
        .i_in   (w_pc_if),
        .o_out  (w_pc_dof)
    );
    register_en #(
        .DATA_WIDTH(32)
    ) U_REG_EN_INST_IF_TO_DOF (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_if_dof),
        .i_in   (w_inst_if),
        .o_out  (w_inst_dof)
    );

    // imm_extend instantiation
    imm_extend U_IMM_EXTEND (
        .i_inst   (w_inst_dof),
        .o_imm_ext(w_imm_ext_dof)
    );

    // instrunction_decoder instantiation
    instruction_decoder U_INSTRUNCTION_DECODER (
        .i_inst       (w_inst_dof),
        .o_ra1        (w_ra1_dof),
        .o_ra2        (w_ra2_dof),
        .o_alu_srcsel (w_alu_srcsel_dof),
        .o_alu_control(w_alu_control_dof),
        .o_ram_we     (w_ram_we_dof),
        .o_type       (w_type_dof),
        .o_branch     (w_branch_dof),
        .o_jump       (w_jump_dof),
        .o_jalr       (w_jalr_dof),
        .o_rf_srcsel  (w_rf_srcsel_dof),
        .o_we         (w_we_dof),
        .o_wa         (w_wa_dof)
    );

    // CL(DOF)
    assign o_ra1 = w_ra1_dof;
    assign o_ra2 = w_ra2_dof;
    assign o_imm_ext = w_imm_ext_dof;
    assign o_alu_srcsel = w_alu_srcsel_dof;

    // register_en(DOF -> EX) instantiation
    register_en #(
        .DATA_WIDTH(32)
    ) U_REG_EN_PC_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_pc_dof),
        .o_out  (w_pc_ex)
    );
    register_en #(
        .DATA_WIDTH(4)
    ) U_REG_EN_ALU_CONTROL_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_alu_control_dof),
        .o_out  (w_alu_control_ex)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_RAM_WE_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_ram_we_dof),
        .o_out  (w_ram_we_ex)
    );
    register_en #(
        .DATA_WIDTH(3)
    ) U_REG_EN_TYPE_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_type_dof),
        .o_out  (w_type_ex)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_BRANCH_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_branch_dof),
        .o_out  (w_branch_ex)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_JUMP_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_jump_dof),
        .o_out  (w_jump_ex)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_JALR_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_jalr_dof),
        .o_out  (w_jalr_ex)
    );
    register_en #(
        .DATA_WIDTH(3)
    ) U_REG_EN_RF_SRCSEL_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_rf_srcsel_dof),
        .o_out  (w_rf_srcsel_ex)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_WE_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_we_dof),
        .o_out  (w_we_ex)
    );
    register_en #(
        .DATA_WIDTH(5)
    ) U_REG_EN_WA_DOF_TO_EX (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_dof_ex),
        .i_in   (w_wa_dof),
        .o_out  (w_wa_ex)
    );

    // CL(EX)
    assign o_pc_delay = w_pc_ex;
    assign o_alu_control = w_alu_control_ex;
    assign o_ram_we = w_ram_we_ex;
    assign o_type = w_type_ex;
    assign o_jalr = w_jalr_ex;

    // register_en(EX -> WB) instantiation
    register_en #(
        .DATA_WIDTH(3)
    ) U_REG_EN_RF_SRCSEL_EX_TO_WB (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_ex_wb),
        .i_in   (w_rf_srcsel_ex),
        .o_out  (w_rf_srcsel_wb)
    );
    register_en #(
        .DATA_WIDTH(1)
    ) U_REG_EN_WE_EX_TO_WB (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_ex_wb),
        .i_in   (w_we_ex),
        .o_out  (w_we_wb)
    );
    register_en #(
        .DATA_WIDTH(5)
    ) U_REG_EN_WA_EX_TO_WB (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (w_en_ex_wb),
        .i_in   (w_wa_ex),
        .o_out  (w_wa_wb)
    );

    // CL(WB)
    assign o_rf_srcsel = w_rf_srcsel_wb;
    assign o_we = w_we_wb;
    assign o_wa = w_wa_wb;
endmodule
//-----------------//

//-----------------//
// fsm
module fsm (
    input  logic i_clk,
    input  logic i_rst_n,
    output logic o_en_if_dof,
    output logic o_en_dof_ex,
    output logic o_en_ex_wb,
    output logic o_pc_en
);

    // FSM state
    typedef enum logic [1:0] {
        IF  = 2'b00,
        DOF = 2'b01,
        EX  = 2'b10,
        WB  = 2'b11
    } state_t;

    // state declaration
    state_t c_state, n_state;

    // FSM logic(SL)
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) c_state <= IF;
        else c_state <= n_state;
    end

    // FSM logic(CL)
    always_comb begin
        n_state = c_state;
        o_en_if_dof = 0;
        o_en_dof_ex = 0;
        o_en_ex_wb = 0;
        o_pc_en = 0;
        case (c_state)
            IF: begin
                n_state = DOF;
                o_en_if_dof = 1;
            end
            DOF: begin
                n_state = EX;
                o_en_dof_ex = 1;
            end
            EX: begin
                n_state = WB;
                o_en_ex_wb = 1;
            end
            WB: begin
                n_state = IF;
                o_pc_en = 1;
            end
        endcase
    end
endmodule
//-----------------//

//-----------------//
// program_counter
module program_counter (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_pc_en,
    input  logic        i_branch,
    input  logic        i_b_taken,
    input  logic        i_jump,
    input  logic [31:0] i_pc_branch,
    output logic [31:0] o_pc
);

    // logic declaration
    logic [31:0] n_pc;

    // CL 
    always_comb begin
        if (i_branch && (i_b_taken | i_jump)) n_pc = i_pc_branch;
        else n_pc = o_pc + 4;
    end

    // register_en instantiation
    register_en #(
        .DATA_WIDTH(32)
    ) U_REG_EN_PC (
        .i_clk  (i_clk),
        .i_rst_n(i_rst_n),
        .i_en   (i_pc_en),
        .i_in   (n_pc),
        .o_out  (o_pc)
    );
endmodule
//-----------------//

//-----------------//
// imm_extend
module imm_extend
    import rv32i_pkg::*;
(
    input  logic [31:0] i_inst,
    output logic [31:0] o_imm_ext
);
    // logic declaration
    opcode_e w_opcode;
    assign w_opcode = opcode_e'(i_inst[6:0]);  // opcode_e' : casting operation

    // CL
    always_comb begin
        o_imm_ext = 32'h0;
        case (w_opcode)
            OP_STYPE:
            o_imm_ext = {
                {20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]
            };  // S-type
            OP_ITYPE_ALU: begin
                if((i_inst[14:12] == 3'b101) || (i_inst[14:12] == 3'b001))
          begin
                    o_imm_ext = {27'b0, i_inst[24:20]};
                end else begin
                    o_imm_ext = {{20{i_inst[31]}}, i_inst[31:20]};
                end
            end  // I-type(operation)
            OP_ITYPE_LD:
            o_imm_ext = {{20{i_inst[31]}}, i_inst[31:20]};  // I-type(load)
            OP_BTYPE:
            o_imm_ext = {
                {19{i_inst[31]}},
                i_inst[31],
                i_inst[7],
                i_inst[30:25],
                i_inst[11:8],
                1'b0
            };  // B-type
            OP_LUI: o_imm_ext = {i_inst[31:12], 12'b0};  // U-type(LUI)
            OP_AUIPC: o_imm_ext = {i_inst[31:12], 12'b0};  // U-type(AUIPC)
            OP_JAL:
            o_imm_ext = {
                {11{i_inst[31]}},
                i_inst[31],
                i_inst[19:12],
                i_inst[20],
                i_inst[30:21],
                1'b0
            };  // J-type(JAL)
            OP_JALR:
            o_imm_ext = {{20{i_inst[31]}}, i_inst[31:20]};  // I-type(JALR)
        endcase
    end
endmodule
//-----------------//


//-----------------//
// instruction_decoder
module instruction_decoder
    import rv32i_pkg::*;
(
    input  logic [31:0] i_inst,
    output logic [ 4:0] o_ra1,
    output logic [ 4:0] o_ra2,
    output logic        o_alu_srcsel,
    output logic [ 3:0] o_alu_control,
    output logic        o_ram_we,
    output logic [ 2:0] o_type,
    output logic        o_branch,
    output logic        o_jump,
    output logic        o_jalr,
    output logic [ 2:0] o_rf_srcsel,
    output logic        o_we,
    output logic [ 4:0] o_wa
);
    // logic declaration
    opcode_e w_opcode;
    assign w_opcode = opcode_e'(i_inst[6:0]);

    // for debugging
    rv32i_inst_r     w_inst_r;
    rv32i_inst_s     w_inst_s;
    rv32i_inst_i_alu w_inst_i_alu;
    rv32i_inst_i_ld  w_inst_i_ld;
    rv32i_inst_b     w_inst_b;
    assign w_inst_r = rv32i_inst_r'({i_inst[30], i_inst[14:12]});  // type-R
    assign w_inst_s = rv32i_inst_s'(i_inst[14:12]);  // type-S
    assign w_inst_i_alu = rv32i_inst_i_alu'({
        i_inst[30], i_inst[14:12]
    });  // type-I(ALU)
    assign w_inst_i_ld = rv32i_inst_i_ld'(i_inst[14:12]);  // type-I(LD)
    assign w_inst_b = rv32i_inst_b'(i_inst[14:12]);  // type-B

    // CL
    always_comb begin
        o_we          = 1'b0;
        o_alu_srcsel  = 1'b0;
        o_alu_control = 4'b0_000;
        o_rf_srcsel   = 3'b000;
        o_ram_we      = 1'b0;
        o_type        = 3'b111;  // ram default
        o_branch      = 1'b0;
        o_jump        = 1'b0;
        o_jalr        = 1'b0;
        case (w_opcode)
            OP_RTYPE: begin  // R-type
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b0;
                o_alu_control = {i_inst[30], i_inst[14:12]};
                o_rf_srcsel   = 3'b000;
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b0;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_STYPE: begin  // S-type
                o_we          = 1'b0;
                o_alu_srcsel  = 1'b1;
                o_alu_control = 4'b0_000;  // add
                o_rf_srcsel   = 3'b000;  // don't care
                o_ram_we      = 1'b1;
                o_type        = i_inst[14:12];  // store
                o_branch      = 1'b0;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_ITYPE_ALU: begin  // I-type(operation)
                o_we         = 1'b1;
                o_alu_srcsel = 1'b1;
                if (i_inst[14:12] == 3'b101)
                    o_alu_control = {i_inst[30], i_inst[14:12]};
                else o_alu_control = {1'b0, i_inst[14:12]};
                o_rf_srcsel = 3'b000;  // alu_result
                o_ram_we    = 1'b0;
                o_type      = 3'b111;  // ram default
                o_branch    = 1'b0;
                o_jump      = 1'b0;
                o_jalr      = 1'b0;
            end
            OP_ITYPE_LD: begin  // I-type(load)
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b1;
                o_alu_control = 4'b0_000;  // add
                o_rf_srcsel   = 3'b001;  // i_ram_rd
                o_ram_we      = 1'b0;
                o_type        = i_inst[14:12];
                o_branch      = 1'b0;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_BTYPE: begin  // B-type
                o_we          = 1'b0;
                o_alu_srcsel  = 1'b0;
                o_alu_control = {1'b0, i_inst[14:12]};
                o_rf_srcsel   = 3'b000;  // don't care
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b1;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_LUI: begin  // U-type(LUI)
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b0;  // don't care
                o_alu_control = 4'b0_000;  // don't care
                o_rf_srcsel   = 3'b010;  // imm
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b0;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_AUIPC: begin  // U-type(AUIPC)
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b0;  // don't care
                o_alu_control = 4'b0_000;  // don't care
                o_rf_srcsel   = 3'b011;  // pc+imm
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b0;
                o_jump        = 1'b0;
                o_jalr        = 1'b0;
            end
            OP_JAL: begin  // J-type(JAL)
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b0;  // don't care
                o_alu_control = 4'b0_000;  // don't care
                o_rf_srcsel   = 3'b100;  // pc+4
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b1;
                o_jump        = 1'b1;
                o_jalr        = 1'b0;  //  pc+imm
            end
            OP_JALR: begin  // I-type(JALR)
                o_we          = 1'b1;
                o_alu_srcsel  = 1'b0;  // don't care
                o_alu_control = 4'b0_000;  // don't care
                o_rf_srcsel   = 3'b100;  // pc+4
                o_ram_we      = 1'b0;
                o_type        = 3'b111;  // ram default
                o_branch      = 1'b1;
                o_jump        = 1'b1;
                o_jalr        = 1'b1;  // rs1+imm
            end
        endcase
    end

    // CL
    assign o_wa  = i_inst[11:7];
    assign o_ra1 = i_inst[19:15];
    assign o_ra2 = i_inst[24:20];
endmodule
//-----------------//


