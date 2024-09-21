
module Led (
  input [2:0] Mode,
  input Fg_clk,
  input Resetn,
  output reg [4:0] Led_Mode
);
  always @(posedge Fg_clk or negedge Resetn) begin
    if(~Resetn) begin
        Led_Mode <= 5'b00001;
        end
    else begin
        case(Mode)
        3'd0 : Led_Mode <= 5'b00001;
        3'd1 : Led_Mode <= 5'b00010;
        3'd2 : Led_Mode <= 5'b00100;
        3'd3 : Led_Mode <= 5'b01000;
        3'd4 : Led_Mode <= 5'b10000;
        default : Led_Mode <= 5'b00001;
      endcase
      end
end
endmodule