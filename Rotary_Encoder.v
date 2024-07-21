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
  reg Aff1, Aff2;
  reg Bff1, Bff2;
  reg A_fall;
  reg B_fall;
  reg [1:0] state;
  reg [21:0] count_change;
  reg change;

  // Flip-Flops for Rot_A
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Aff1 <= 0;
      Aff2 <= 0;
    end else begin
      Aff1 <= Rot_A;
      Aff2 <= Aff1;
    end
  end

  // Flip-Flops for Rot_B
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Bff1 <= 0;
      Bff2 <= 0;
    end else begin
      Bff1 <= Rot_B;
      Bff2 <= Bff1;
    end
  end

  // Detect A_fall and B_fall
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      A_fall <= 0;
      B_fall <= 0;
    end else begin
      A_fall <= (~Aff1) & Aff2;
      B_fall <= (~Bff1) & Bff2;
    end
  end

  // Change State and Count
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      state <= 0;
      count <= 0; // Initialize count based on Mode
    end else begin
      // Check if switching to Mode 4 with count below 800
      if (Mode == 4 && count < 800) begin
        count <= 800;
      end

      case (state)
        0: begin
          if (B_fall) begin
            state <= 1;
            if ((count + step) > 1800) begin
              count <= 1800;
            end else begin
              count <= count + step;
            end
          end else if (A_fall) begin
            state <= 2;
            if (Mode == 4) begin
              if ((count - step) < 800) begin
                count <= 800;
              end else begin
                count <= count - step;
              end
            end else begin
              if ((count < step)) begin
                count <= 0;
              end else begin
                count <= count - step;
              end
            end
          end
        end
        1: begin
          if (A_fall) begin
            state <= 0;
          end
        end
        2: begin
          if (B_fall) begin
            state <= 0;
          end
        end
      endcase
    end
  end

  // Increase step when Rot_C is pressed
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      step <= 1;
    end else begin
      if (Rot_C == 1) begin
        case (step)
          1: step <= 10;
          10: step <= 100;
          100: step <= 1;
        endcase
      end
    end
  end

  // Generate change pulse every 100 ms (simulated with 2400 clocks)
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      count_change <= 0;
      change <= 0;
    end else begin
      if (count_change == 2400) begin // For simulation, 2400 clocks
        count_change <= 0;
        change <= 1;
      end else begin
        count_change <= count_change + 1;
        change <= 0;
      end
    end
  end

  // Change address when change is 1
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      address <= 0;
    end else begin
      if (change) begin
        address <= count;
      end
    end
  end

  // FreqChng output logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      FreqChng <= 0;
    end else begin
      FreqChng <= (address != count) & (change == 1);
    end
  end
endmodule
