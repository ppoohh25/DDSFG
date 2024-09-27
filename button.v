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
    end else begin
        Ds <= Ext_button;
        Dout <= Ds;
        Dout1 <= Dout;
    end
end

always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
        count <= 0;
    end 
    else if(IntButton == 1)begin
      count <= 1;
    end
    else begin
        if (count > 0 && count < 24000000) begin //if sim 24000000 --> 2400
            count <= count + 25'd1;
        end else if(count >= 24000000) begin
            count <= 0;
        end
    end
end

always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
        IntButton <= 0;
    end else begin
        if (Dout1 == 1 && Dout == 0 && count == 0) begin
            IntButton <= 1;
        end else begin
            IntButton <= 0;
        end
    end
end

endmodule

