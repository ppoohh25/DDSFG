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
//--------------------- debug -----------------------------
  // real cos2x_f;
  // always @(*) begin
  //   cos2x_f <= $itor(cos2x)/536870912;
  // end
  //---------------------------------------------------------
  // Instantiate the ROM module
  romcoef_module romcoef_module(
    .dout(coefficient),
    .clk(Fg_clk),
    .oce(1'b0),         // Output clock enable is set to 0
    .ce(1'b1),         // Use binary literals for consistency
    .reset(~Resetn),
    .ad(address)
  );

  // Assign outputs with bit manipulation
  assign sine1x = {4'b0000, coefficient[47:24], 4'b0000};
  assign cos2x = {6'b001111, coefficient[23:0], 2'b00};

  

endmodule

// module lookup_table(Fg_clk, Resetn, address, out1, out2, sine1x, cos2x);
//     input Fg_clk;
//     input Resetn;
//     input wire [10:0] address;
//     input out1;
//     input out2;

//     output [31:0] sine1x;
//     output [31:0] cos2x;

//     // wire [31:0] sin1x;
//     // wire [31:0] cos2x;

//     wire [47:0] coef;

//     romcoef_module romcoefmod(
//         .dout(coef), //output [47:0] dout

//         .clk(Fg_clk), //input clk
//         .oce(1'd1), //input oce
//         .ce(1'd1), //input ce
//         .reset(~Resetn), //input reset
//         .ad(address) //input [10:0] ad
//     );
   

//     assign sine1x = {4'b0000  , coef[47:24], 4'b0000};
//     assign cos2x = {6'b001111, coef[23: 0], 2'b00  };


// endmodule