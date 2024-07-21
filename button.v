module button (
  input Ext_button,
  input Fg_clk,
  input Resetn,
  output reg IntButton
);
  reg Ds, Dout, Dout1;
  reg [24:0] count;

  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Ds <= 0;
      Dout <= 0;
      Dout1 <= 0;
      count <= 0;
      IntButton <= 0;
    end else begin
      Ds <= Ext_button;
      Dout <= Ds;
      Dout1 <= Dout;

      if (count > 0 && count <= 24*10**2/*If test change 24*10^6 --> 24*10^2 */) begin
        count <= count + 1;
      end else begin
        count <= 0;
      end

      if (Dout1 == 1 && Dout == 0 && count == 0) begin
        IntButton <= 1;
        count <= 1;
      end else begin
        IntButton <= 0;
      end
    end
  end
endmodule