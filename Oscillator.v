module Oscillator (
  input Fg_clk,
  input Resetn,
  input Enable,
  input Ready,
  input [2:0] Mode,
  input [31:0] init1,
  input [31:0] init2,
  input FreqChng,
  output reg [31:0] out1,
  output reg [31:0] out2
);
  reg [31:0] out;
  reg [31:0] a;
  reg [63:0] c;
  reg [31:0] out1_a;
  reg update_wait;
  reg do_update;
  reg zcross;
  reg dir;
  reg [31:0] sine;

  // Output register logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      out1 <= 0;
    end else if (Ready || do_update) begin
      out1 <= sine;
    end else if (Enable) begin
      out1 <= out;
    end
  end
  
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      out2 <= 0;
    end else if (Ready || do_update) begin
      out2 <= 0;
    end else if (Enable) begin
      out2 <= out1;
    end
  end

  // Update coefficient `a`
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      a <= 0;
    end else if (Ready || do_update) begin
      a <= init2;
    end
  end

  // Multiply `a` with `out1` and store result in `out1_a`
  always @(*) begin
    c <= $signed(a) * $signed(out1);
    out1_a <= c[60:29];
  end

  // Calculate `out`
  always @(*) begin
    out <= out1_a - out2;
  end

  // Update wait logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      update_wait <= 0;
    end else if (FreqChng == 1) begin
      update_wait <= 1;
    end else if (do_update == 1) begin
      update_wait <= 0;
    end
  end

  // Determine if an update should be performed
  always @(*) begin
    if (zcross && update_wait) begin
      do_update <= 1;
    end else begin
      do_update <= 0;
    end
  end

  // Zero-crossing detection
  always @(*) begin
    if ((Mode != 4) && 
        ((out1[31:22] == 10'b0000000000) || (out1[31:22] == 10'b1111111111)) || 
        ((out1[31:23] == 9'b000000000) || (out1[31:23] == 9'b111111111))) begin
      zcross <= 1;
    end else begin
      zcross <= 0;
    end
  end

  // Determine direction
  always @(*) begin
    if (out2[31] == 1) begin
      dir <= 1;
    end else begin
      dir <= 0;
    end
  end

  // Determine sine value
  always @(*) begin
    sine <= (dir == 1) ? init1 : ~init1 + 1;
  end
endmodule
