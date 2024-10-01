module clk_div(
    input wire pll_clk,
    input wire Resetn,
    output reg Fg_clk,
    output reg Dac_clk
);
    always @(posedge pll_clk or negedge Resetn) begin
        if(~Resetn) begin
            Fg_clk <= 0;
        end else Fg_clk <= ~Fg_clk;

    end

    always @(negedge pll_clk or negedge Resetn) begin
        if(~Resetn) begin
            Dac_clk <= 0;
        end else Dac_clk <= ~Dac_clk;
    end
endmodule

/*
Module name : clk_div
How it work : 
    This module divides the input clock (pll_clk) to generate two separate clock signals: Fg_clk and Dac_clk. 
    The Fg_clk toggles on the positive edge of pll_clk, effectively dividing its frequency by 2. 
    Similarly, Dac_clk toggles on the negative edge of pll_clk, also dividing the frequency by 2. 
    Both clock signals are reset to 0 when the Resetn signal is low.
*/