//-----------------------//
// tb_top_rv32i
// `define VERDI
module tb_top_rv32i ;
  // interface
  logic i_clk=1'b0, i_rst_n=1'b0;

  // DUT
  top_rv32i DUT(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n)
  );

  // clock generation
  always #5 i_clk = ~i_clk;

  // drive & run
  initial begin
    #10;
    i_rst_n = 1'b1;
    #20000;
    $finish;
  end

  // waveform for verdi
  `ifdef VERDI
  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, tb_top_rv32i);
  end
  `endif

endmodule
//-----------------------//
