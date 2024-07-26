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

  // Internal registers
  reg [10:0] count;
  reg [7:0] step;
  reg [2:0] Aff, Bff;
  reg A_fall, B_fall;
  reg [1:0] state;
  reg [21:0] count_change;
  reg change;

  // Flip-Flops for Rot_A and Rot_B
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Aff <= 3'b0;
      Bff <= 3'b0;
    end else begin
      Aff <= {Aff[1:0], Rot_A};
      Bff <= {Bff[1:0], Rot_B};
    end
  end

  // Detect A_fall and B_fall
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      A_fall <= 0;
      B_fall <= 0;
    end else begin
      A_fall <= ~Aff[1] & Aff[2];
      B_fall <= ~Bff[1] & Bff[2];
    end
  end

  // State and Count Management
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      state <= 0;
      count <= 0;
    end else begin
      if (Mode == 4 && count < 800) count <= 800;
      else begin
      case (state)
        0: begin
          if (B_fall) begin
            state <= 1;
            count <= (count + step > 1800) ? 1800 : count + step;
          end else if (A_fall) begin
            state <= 2;
            if (Mode == 4) count <= (count - step < 800) ? 800 : count - step;
            else count <= (count < step) ? 0 : count - step;
          end
        end
        1: if (A_fall) state <= 0;
        2: if (B_fall) state <= 0;
        default : state <= 0;
      endcase
      end
    end
  end

  // Step Management
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

  // Change Pulse Generation
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      count_change <= 0;
      change <= 0;
    end else begin
      if (count_change == 2400-1) begin //If sim 24000000 --> 2400
        count_change <= 0;
        change <= 1;
      end else begin
        count_change <= count_change + 1;
        change <= 0;
      end
    end
  end

  // address and FreqChng Logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) address <= 0;
    else if (change) address <= count;
  end

  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) FreqChng <= 0;
    else FreqChng <= (address != count) & change;
  end

endmodule

// module Rotary(Fg_clk, Resetn, Rot_A, Rot_B, Rot_C, address, FreqChng);
//     input Fg_clk;
//     input Resetn;
//     input Rot_A;
//     input Rot_B;
//     input Rot_C;

//     output reg [10:0] address; // 0-1800
//     output reg FreqChng;

//     reg [11:0] count; // 0-1800 [10:0]can over flow, 0-100 =-99 
//     reg [1:0] step_exp; // 0->1, 1->10, 2->100
//     reg [1:0] state; //  minus, idle, plus

//     reg A1;
//     reg A2;
//     reg A3;
//     reg A_pulse;
//     reg B1;
//     reg B2;
//     reg B3;
//     reg B_pulse;
//     reg [21:0] counter;
//     reg counter_pulse;
//     `ifdef TEST_MODE parameter counter_100ms = 3000;// for test
//     `else            parameter counter_100ms = 2400000;// 100ms
//     `endif 

//     //syn Rot_A (A1, A2) and make pulse from falling edge(A3)
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn) begin
//             A1 <= 0;
//             A2 <= 0;
//             A3 <= 0;
//             A_pulse <= 0;
//         end
//         else begin 
//             A1 <= Rot_A;
//             A2 <= A1;
//             A3 <= A2;
//             A_pulse <= (~A2 & A3);
//         end
//     end 

//     //syn Rot_B (B1, B2) and make pulse from falling edge(B3)
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn) begin
//             B1 <= 0;
//             B2 <= 0;
//             B3 <= 0;
//             B_pulse <= 0;
//         end
//         else begin 
//             B1 <= Rot_B;
//             B2 <= B1;
//             B3 <= B2;
//             B_pulse <= (~B2 & B3);
//         end
//     end 
    

//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn) begin
//             state <= 2'b00;
//             count <= 0;
//         end
//         else begin
//             case (state)
//                 2'b10 : begin //minus
//                     if (B_pulse) begin 
//                         state <= 2'b00;
//                         // count <= count - 10**step_exp;
//                         // if ($signed(count) <= 0) count <= 0;// case count less than 0
//                         if ($signed(count - 10**step_exp) >= 0) count <= count - 10**step_exp;
//                         else                                    count <= 0;
//                     end
//                 end

//                 2'b00 : begin //idle
//                     if (A_pulse) state <= 2'b10;
//                     if (B_pulse) state <= 2'b01;
//                 end

//                 2'b01 : begin //plus
//                     if (A_pulse) begin 
//                         state <= 2'b00;
//                         // count <= count + 10**step_exp;
//                         if (count + 10**step_exp <= 1800) count <= count + 10**step_exp;
//                         else count <= 1800;// case count more than 1800
//                     end
//                 end
//                 default : state <= 2'b00;
//             endcase
//         end
//     end

//     // button Rot_C
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn) step_exp <= 0;
//         else if(Rot_C) begin 
//             if(step_exp < 2) step_exp <= step_exp + 1;
//             else step_exp <= 0;
//         end
//     end
    
//     // make pulse every 100 ms
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn) begin 
//             counter <= 0;
//             counter_pulse <= 0;
//         end
//         else begin
//             counter <= counter + 1; 
//             if      (counter == 2400000 -1)   counter_pulse <= 1;
//             else if (counter >= 2400000) begin
//                 counter <= 0;
//                 counter_pulse <= 0; 
//             end
//         end
//     end

//     // output address every 100 ms
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if      (~Resetn)       address <= 0; 
//         else if (counter_pulse) address <= count[10:0];
//     end

//     // if output Adddress have change ,then this block generate pulse
//     always @(posedge Fg_clk or negedge Resetn) begin
//         if(~Resetn)                                     FreqChng <= 0;
//         else if ((address != count[10:0]) & counter_pulse )   FreqChng <= 1;
//         else                                            FreqChng <= 0;
//     end
// endmodule