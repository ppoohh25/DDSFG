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

/*
Module name : button
How it work : 
    This module debounces an external button (Ext_button) to produce a clean internal signal (IntButton). 
    It uses a 3-stage flip-flop chain to synchronize the external button input with the system clock (Fg_clk) and remove any bouncing. 
    A 25-bit counter is used to create a delay to prevent multiple triggers during bouncing. 
    The internal button signal (IntButton) is a single pulse generated on the falling edge of the debounced signal, ensuring the button press is registered cleanly.
*/