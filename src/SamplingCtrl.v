module SamplingCtrl (
  input Fg_clk,
  input Resetn,
  input IntBtn,
  output reg Ready,
  output reg Enable,
  output reg [2:0] Mode  // increased size to 2 bits
);
  reg pulse_in;
  reg [14:0] count;      // size of count matches its usage in case statement
  reg [7:0] rcount;      // size of rcount matches its usage
  integer i;

  

//  Ready signal logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      rcount <= 0;
    end else begin
      if (rcount < 80) begin
        rcount <= rcount + 8'd1;       
      end
    end
  end

//   Ready signal logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Ready <= 0;     
    end else begin
        if (rcount == 78) begin
          Ready <= 1;
        end else begin
          Ready <= 0;
        end  
    end
  end

//   Mode transition logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Mode <= 0;
    end else if (pulse_in && Enable) begin
      if (Mode == 4) begin
        Mode <= 0;
      end else begin
        Mode <= Mode + 3'd1;
      end
    end
  end

//   Pulse generation logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      pulse_in <= 0;
    end else if (IntBtn == 1) begin
      pulse_in <= 1;
    end
    else if(pulse_in && Enable) begin
      pulse_in <= 0;
    end
  end

//   Mode-based count change logic (Combinational)
  always @(*) begin
    case (Mode)
      0: i = 0;
      1: i = 9;
      2: i = 99;
      3: i = 999;
      4: i = 9999;
      default: i = 0;
    endcase
  end

//   Enable signal logic
   always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Enable <= 0;
      count <= 0;
    end else begin
      if (i == 0) begin
        Enable <= 1;
      end else begin
        if (count < i) begin
          count <= count + 15'd1;
          Enable <= 0;
        end else begin
          count <= 0;
          Enable <= 1;
        end
      end
    end
  end
endmodule

/*
Module name : SamplingCtrl
How it work : 
    This module controls sampling behavior using several inputs and outputs. 
    The Ready signal is generated based on a counter (rcount), which counts up to 80 clock cycles before setting Ready to 1. 
    The Mode signal cycles through different modes (0 to 4) when a pulse from IntBtn is detected and the Enable signal is high. 
    Each mode sets a specific count limit (i) that determines the delay before the Enable signal is re-activated. 
    This ensures timed intervals between different operational modes. 
    A pulse (pulse_in) is generated from IntBtn, and the Enable signal is controlled based on the mode and counting logic.
*/