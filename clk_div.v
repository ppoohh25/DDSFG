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