//------------------//
// data_ram
module data_ram(
  input   logic         i_clk,
  input   logic         i_ram_we,
  input   logic [31:0]  i_ram_wa,
  input   logic [31:0]  i_ram_wd,
  input   logic [2:0]   i_type,
  output  logic [31:0]  o_ram_rd
);
  // ram declaration
  logic [31:0] d_ram [0:127]; // 512B
  

  // SL
  always_ff @(posedge i_clk) begin
    if(i_ram_we) begin
      case(i_type)
        3'b000: begin // SB
          case(i_ram_wa[1:0])
            2'b00   : d_ram[i_ram_wa[31:2]] <= {d_ram[i_ram_wa[31:2]][31:8],  i_ram_wd[7:0]};
            2'b01   : d_ram[i_ram_wa[31:2]] <= {d_ram[i_ram_wa[31:2]][31:16], i_ram_wd[7:0], d_ram[i_ram_wa[31:2]][7:0]};
            2'b10   : d_ram[i_ram_wa[31:2]] <= {d_ram[i_ram_wa[31:2]][31:24], i_ram_wd[7:0], d_ram[i_ram_wa[31:2]][15:0]};
            2'b11   : d_ram[i_ram_wa[31:2]] <= {i_ram_wd[7:0], d_ram[i_ram_wa[31:2]][23:0]};
            default : d_ram[i_ram_wa[31:2]] <= d_ram[i_ram_wa[31:2]];
          endcase
        end
        3'b001: begin // SH
          case(i_ram_wa[1:0])
            2'b00   : d_ram[i_ram_wa[31:2]] <= {d_ram[i_ram_wa[31:2]][31:16], i_ram_wd[15:0]};
            2'b10   : d_ram[i_ram_wa[31:2]] <= {i_ram_wd[15:0], d_ram[i_ram_wa[31:2]][15:0]};
            default : d_ram[i_ram_wa[31:2]] <= d_ram[i_ram_wa[31:2]];
          endcase
        end
        3'b010: begin // SW
            if(i_ram_wa[1:0] == 2'b00) d_ram[i_ram_wa[31:2]] <=  i_ram_wd;
          end 
        default: d_ram[i_ram_wa[31:2]] <= d_ram[i_ram_wa[31:2]];
      endcase
    end
  end

  // CL
  always_comb begin
    o_ram_rd = 32'h0;
    case(i_type)
      3'b000:begin  // LB
        case(i_ram_wa[1:0])
          2'b00:o_ram_rd = {{24{d_ram[i_ram_wa[31:2]][7]}},   d_ram[i_ram_wa[31:2]][7:0]};
          2'b01:o_ram_rd = {{24{d_ram[i_ram_wa[31:2]][15]}},  d_ram[i_ram_wa[31:2]][15:8]};
          2'b10:o_ram_rd = {{24{d_ram[i_ram_wa[31:2]][23]}},  d_ram[i_ram_wa[31:2]][23:16]};
          2'b11:o_ram_rd = {{24{d_ram[i_ram_wa[31:2]][31]}},  d_ram[i_ram_wa[31:2]][31:24]};
        endcase
      end
      3'b001:begin  // LH
        case(i_ram_wa[1:0])          
          2'b00:o_ram_rd = {{16{d_ram[i_ram_wa[31:2]][15]}}, d_ram[i_ram_wa[31:2]][15:0]};
          2'b10:o_ram_rd = {{16{d_ram[i_ram_wa[31:2]][31]}}, d_ram[i_ram_wa[31:2]][31:16]};
        endcase
      end
      3'b010:begin  // LW
          if(i_ram_wa[1:0] == 2'b00) o_ram_rd = d_ram[i_ram_wa[31:2]];
      end
      3'b100:begin  // LBU
        case(i_ram_wa[1:0])
          2'b00:o_ram_rd = {24'b0,  d_ram[i_ram_wa[31:2]][7:0]};
          2'b01:o_ram_rd = {24'b0,  d_ram[i_ram_wa[31:2]][15:8]};
          2'b10:o_ram_rd = {24'b0,  d_ram[i_ram_wa[31:2]][23:16]};
          2'b11:o_ram_rd = {24'b0,  d_ram[i_ram_wa[31:2]][31:24]};
        endcase
      end
      3'b101:begin  // LHU
        case(i_ram_wa[1:0])
          2'b00:o_ram_rd = {16'b0, d_ram[i_ram_wa[31:2]][15:0]};
          2'b10:o_ram_rd = {16'b0, d_ram[i_ram_wa[31:2]][31:16]};
        endcase
      end
    endcase

  end

endmodule
//------------------//
