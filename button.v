module button (
  input Ext_button,
  input Fg_clk,
  input Resetn,
  output reg IntButton
);
  reg [2:0] sync;
  reg [24:0] count;

  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      sync <= 3'b000;
      count <= 0;
      IntButton <= 0;
    end else begin
      // Synchronize Ext_button
      sync <= {sync[1:0], Ext_button};

      // Manage count for debouncing
      if (count != 0) begin
        count <= count + 1;
        if (count == 2400) // Simulation: 2400, Real: 24000000
          count <= 0;
      end

      // Detect falling edge of Ext_button
      if (sync[2:1] == 2'b10 && count == 0) begin
        IntButton <= 1;
        count <= 1;
      end else begin
        IntButton <= 0;
      end
    end
  end
endmodule
