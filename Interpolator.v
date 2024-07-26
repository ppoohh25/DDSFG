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

  // Compute delta combinationally
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
    delta = $signed(Out1 - Out2) * $signed(const);
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
  /*
  ---------------------------- Error at address 1700-1800 -----------------------------
    progress --> if (address > 1699) InterpOut1 = out[31:20]; fix some issue but not all.
  -------------------------------------------------------------------------------------
  */

  // Updating InterpOut
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      InterpOut <= 0;
    end else begin
      InterpOut <= {~InterpOut1[11], InterpOut1[10:0]};
    end
  end

endmodule

// module Interpolator(Fg_clk, Resetn, Out1, Out2, Mode, Enable, InterpOut);
//     input Fg_clk;
//     input Resetn;
//     input [31:0] Out1;
//     input [31:0] Out2;
//     input [2:0] Mode;
//     input Enable;

//     output wire [11:0] InterpOut; //12 bit unsigned

//     reg Enable_delay;
//     reg [31:0] delta_y;
//     reg [31:0] interpOut_buffer;
//     reg [31:0] delta_y_buffer;
//     reg [11:0] interpOut; // 12 bit signed

//     assign InterpOut =  {~interpOut[11], interpOut[10:0]}; //offset binary, unsigned
  

//     always @(*)begin //combination
//         delta_y_buffer <=  $signed(Out1-Out2)/$signed(10**Mode);
//     end

//     always@(posedge Fg_clk or negedge Resetn)begin
//         if(~Resetn) Enable_delay <= 0;
//         else        Enable_delay <= Enable;
//     end

//     always@(posedge Fg_clk or negedge Resetn)begin
//         if(~Resetn) delta_y <= 0;
//         else        delta_y <= delta_y_buffer;//delta_y <= (Out2-Out1)/(10**Mode);//! /,** ไม่น่าทำงานได้ ต้องทำใหม่
            

//     end

//     always @(posedge Fg_clk or negedge Resetn)begin
//         if(~Resetn) begin
//             interpOut_buffer <= 0; //! Out1, Out2 ต้องresetไหม
//             interpOut <= 0;

//         end
//         else if (Enable_delay) begin
//             interpOut_buffer <= Out2;
//             interpOut <= interpOut_buffer[29:18];
//         end
//         else begin
//             interpOut_buffer <= interpOut_buffer + delta_y;
//             interpOut <= interpOut_buffer[29:18];//{~interpOut_buffer[31], interpOut_buffer[30:0]};
//         end

//     end


// endmodule