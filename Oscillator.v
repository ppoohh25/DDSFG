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

  // Output register logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      out1 <= 0;
    end else if (Ready || do_update) begin
      if (dir) out1 <= init1;
      else     out1 <= ~init1 + 1;
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
  end

  always @(*) begin
    out1_a <= c[60:29]; //60:29
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
  always @(*)begin 
        
        if (Mode == 4) begin //mode 4
            if((out1 [31:23] == 9'b000000000)||(out1 [31:23] == 9'b111111111)) zcross <= 1;
            else zcross <= 0;
        end
        else begin //mode 0-3
            if((out1 [31:22] == 10'b0000000000)||(out1 [31:22] == 10'b1111111111)) zcross <= 1;
            else zcross <= 0;
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
endmodule

// module Oscillator (Fg_clk, Resetn, Enable, Ready, init1, init2, Mode, FreqChng, out1, out2);
//     input Fg_clk;
//     input Resetn;
//     input Enable;
//     input Ready;
//     input [31:0] init1;//sin1x
//     input [31:0] init2;//cos2x

//     input [2:0]Mode;
//     input FreqChng;

//     output reg [31:0] out1;
//     output reg [31:0] out2;

//     reg [31:0] a;
//     reg [31:0] b;
//     reg [63:0] c;
//     reg [31:0] out;
//     reg [31:0] out1_a;
    
//     reg zcross;
//     reg dir;
//     reg do_update;
//     reg update_wait;

//     always @(*)begin //combination
//         c       <=  $signed(a)*$signed(out1);
//         out1_a  <=  c[60:29];
//     end

//     always @(*)begin //combination
//         out     <= out1_a-out2;
//     end

//     always @(posedge Fg_clk or negedge Resetn)begin //sequential
//         if      (~Resetn)   out1 <= 0;
//         else if (Ready | do_update)     begin
//             // out1 <= init1; //sin(B)
//             if (dir) out1 <= init1;
//             else     out1 <= ~init1 + 1;
//         end
//         else if (Enable)    out1 <= out;
//     end

//     always @(posedge Fg_clk or negedge Resetn)begin //sequential
//         if      (~Resetn)   out2 <= 0;
//         else if (Ready | do_update)     out2 <= 0;
//         else if (Enable)    out2 <= out1;
//     end

//     always @(posedge Fg_clk or negedge Resetn)begin //sequential
//         if      (~Resetn)   a <= 0;
//         else if (Ready | do_update)     a <= init2;
//     end

//     //zcross crossing
//     always @(*)begin 
        
//             if (Mode == 4) begin //mode 4
//             if((out1 [31:23] == 9'd0)||(out1 [31:23] == {9{1'b1}})) zcross <= 1;
//             else zcross <= 0;
//         end
//         else begin //mode 0-3
//             if((out1 [31:22] == 10'd0)||(out1 [31:22] == {10{1'b1}})) zcross <= 1;
//             else zcross <= 0;
//         end
        
//     end

//     //dir 
//     always @(*)begin 
//         if (out2[31]) dir <= 1; //up
//         else          dir <= 0; //down
//     end

//     always @(posedge Fg_clk or negedge Resetn)begin 
//         if      (~Resetn)    update_wait <= 0;
//         else if (FreqChng) update_wait <= 1;
//         else if (do_update)     update_wait <= 0;
//     end

//     always @(*)begin //combination
//         if(zcross & update_wait) do_update <= 1;
//         else do_update <= 0;
//     end
// endmodule