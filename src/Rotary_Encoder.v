module Rotary (
  input Fg_clk,
  input Resetn,
  input [2:0] Mode,
  input Rot_A,
  input Rot_B,
  input Rot_C,
  output reg [10:0] address,
  output reg FreqChng
);

   //Internal registers
  reg [10:0] count;
  reg [7:0] step;
  reg [2:0] Aff, Bff;
  reg A_fall, B_fall;
  reg A_rise, B_rise;
  reg [2:0] state;
  reg [21:0] count_change;
  reg change;
  
  reg [10:0] cool_cnt;

   //Flip-Flops for Rot_A and Rot_B
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Aff <= 3'b0;
      Bff <= 3'b0;
    end else begin
      Aff <= {Aff[1:0], Rot_A};
      Bff <= {Bff[1:0], Rot_B};
    end
  end

//   Detect A_fall and B_fall
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      A_fall <= 0;
      B_fall <= 0;
    end else begin
      A_fall <= ~Aff[1] & Aff[2];
      B_fall <= ~Bff[1] & Bff[2];
    end
  end
   always @(posedge Fg_clk or negedge Resetn) begin
     if (~Resetn) begin
       state    <= 0;
       count    <= 0;
       cool_cnt <= 0;
     end 
     else begin
       if ((Mode==4) & (count<800)) count <= 800; // If Mode changes to 4 and old count is <800, set to 800 immediately !!!
       else begin
          case (state)
            0: begin  // Idle
                 if      (B_fall) state <= 1; // Go to increase state
                 else if (A_fall) state <= 2; // Go to decrease state         
               end
            1: begin  // increase state
                  if (A_fall) begin
                      state <= 3; // cool down stage
                      count <= ($unsigned(count+step)>1799)  ? 11'd1799      : // No over 1800 all mode 
                                                               count+step; // 
                  end
               end  
            2: begin  // decrease state
                  if (B_fall) begin
                      state <= 3; // cool down stage
                      count <= ((Mode==4) & (count<=800))         ?         11'd800 : // No less than 800 in mode4
                               ($unsigned(count)<=$unsigned(step))?           11'd0 : // if count<=step, set to 0 to avoid overflow
                                                                     count-step ;
                  end
               end 
            3: begin  // cool down stage to avoid glitch
                  if ((cool_cnt>=256) & (Aff[2]==1) & (Bff[2]==1)) begin // cool down for 256 clock (can be adjusted if not smooth)  
                      cool_cnt <= 0;                                     // Also wait until A and B are 1 (idle stage)
                      state    <= 0; // back to idle
                  end
                  else begin 
                      cool_cnt <= (cool_cnt<256) ? cool_cnt+11'd1 : cool_cnt;
                  end
               end 
          endcase
       end
     end
 end

   always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) step <= 1;
    else if (Rot_C == 1) begin
      case (step)
          1: step <= 10;
         10: step <= 100;
        100: step <= 1;
      endcase
    end
  end

//   Change Pulse Generation
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      count_change <= 0;
      change <= 0;
    end else begin
      if (count_change >= 2400) begin //If sim 2400000 --> 2400
        count_change <= 0;
        change <= 1;
      end else begin
        count_change <= count_change + 22'd1;
        change <= 0;
      end
    end
  end

//   address and FreqChng Logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) address <= 0;
    else if (change) address <= count;
  end

  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) FreqChng <= 0;
    else FreqChng <= (address != count) & change;
  end

endmodule