//---------------//
// register
module register #(
    parameter DATA_WIDTH = 32
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic [DATA_WIDTH - 1 : 0] i_in,
    output logic [DATA_WIDTH - 1 : 0] o_out
);
    // SL
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) o_out <= 0;
        else o_out <= i_in;
    end
endmodule
//---------------//

//---------------//
// register_en
module register_en #(
    parameter DATA_WIDTH = 32
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic                      i_en,
    input  logic [DATA_WIDTH - 1 : 0] i_in,
    output logic [DATA_WIDTH - 1 : 0] o_out
);
    // SL
    always_ff @(posedge i_clk) begin
        if (!i_rst_n) o_out <= 0;
        else begin
            if(i_en) o_out <= i_in;
        end
    end
endmodule
//---------------//