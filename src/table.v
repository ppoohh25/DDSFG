module Table_coef (
  input Fg_clk,
  input Resetn,
  input [10:0] address,
  input [31:0] out1,
  input [31:0] out2,
  output [31:0] sine1x,
  output [31:0] cos2x
);

  wire [47:0] coefficient;
  // Instantiate the ROM module
  romcoef_module romcoef_module(
    .dout(coefficient),
    .clk(Fg_clk),
    .oce(1'b1),         // Output clock enable is set to 0
    .ce(1'b1),         // Use binary literals for consistency
    .reset(~Resetn),
    .ad(address)
  );

  // Assign outputs with bit manipulation
  assign sine1x = {4'b0000, coefficient[47:24], 4'b0000};
  assign cos2x = {6'b001111, coefficient[23:0], 2'b00};

  

endmodule