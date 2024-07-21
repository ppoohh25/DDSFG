module SamplingCtrl (
  input Fg_clk,
  input Resetn,
  input IntBtn,
  output reg Ready,
  output reg Enable,
  output reg [2:0] Mode  // increased size to 3 bits
);
  reg pulse_in;
  reg [14:0] count;      // size of count matches its usage in case statement
  reg [7:0] rcount;      // size of rcount matches its usage
  integer i;

  // Reset logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Ready <= 0;
      Enable <= 0;
      Mode <= 0;
      pulse_in <= 0;
      count <= 0;
      rcount <= 0;
      i <= 0;
    end
  end

  // Ready signal logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Ready <= 0;
      rcount <= 0;
    end else begin
      if (rcount < 80) begin
        rcount <= rcount + 1;
        if (rcount == 78) begin
          Ready <= 1;
        end else begin
          Ready <= 0;
        end
      end else begin
        rcount <= 80;
      end
    end
  end

  // Mode transition logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Mode <= 0;
    end else if (pulse_in && Enable) begin
      if (Mode == 4) begin
        Mode <= 0;
      end else begin
        Mode <= Mode + 1;
      end
      pulse_in <= 0;
    end
  end

  // Pulse generation logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      pulse_in <= 0;
    end else if (IntBtn == 1) begin
      pulse_in <= 1;
    end
  end

  // Mode-based count change logic (Combinational)
  always @(*) begin
    case (Mode)
      0: i = 0;
      1: i = 10;
      2: i = 100;
      3: i = 1000;
      4: i = 10000;
      default: i = 0;
    endcase
  end

  // Enable signal logic
  always @(posedge Fg_clk or negedge Resetn) begin
    if (~Resetn) begin
      Enable <= 0;
      count <= 0;
    end else begin
      if (i == 0) begin
        Enable <= 1;
      end else begin
        if (count < i ) begin
          count <= count + 1;
          Enable <= 0;
        end else begin
          count <= 0;
          Enable <= 1;
        end
      end
    end
  end
endmodule
