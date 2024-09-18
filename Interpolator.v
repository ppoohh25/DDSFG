module Interpolator (
  input Fg_clk,
  input Resetn,
  input [31:0] Out1,   
  input [31:0] Out2,   
  input [2:0] Mode,
  input Enable,
  output reg [11:0] InterpOut // Output 12-bit
);

  reg Enable_d;
  reg [31:0] const;
  reg [31:0] out; // Output 32-bit
  reg [63:0] delta; 
  reg [11:0] InterpOut1;

//   Compute delta combinationally
  always @(*) begin
    case(Mode) 
      0 : const = 32'd1;
      1 : const = 32'd53687091;
      2 : const = 32'd5368709;
      3 : const = 32'd536871;
      4 : const = 32'd53687;
      default : const = 32'd1;
    endcase
  end

  always @(*) begin
    delta <= ($signed(Out1) - $signed(Out2)) * $signed(const);
  end

  // Resetting and updating Enable_d
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Enable_d <= 0;
    end else begin
      Enable_d <= Enable;
    end
  end

  // Resetting and updating out
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      out <= 0;
    end else if (Enable_d) begin
      out <= Out2;
    end else begin
      out <= out + delta[60:29]; // 60:29
    end
  end

  // Compute InterpOut1 combinationally
  always @(*) begin
    InterpOut1 = out[29:18]; // 29:18
  end 

  // Updating InterpOut
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      InterpOut <= 0;
    end else begin
      InterpOut <= {~InterpOut1[11], InterpOut1[10:0]};
    end
  end

endmodule