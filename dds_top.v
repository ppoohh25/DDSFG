module dds_top(
    input Ext_clk_27,
    input Ext_resetn,
    input Ext_button_sam,
    input Rot_A,
    input Rot_B,
    input Rot_C,
    output [11:0] osc_out,
    output clk_out
);
    wire wpll_clk;
    wire wpll_reset;
    wire wFg_resetn;
    wire wIntButton_sam;
    wire wFg_clk;
    wire wpll_lock;
    wire wEnable;
    wire wReady;
    wire [2:0] wMode;
    wire [31:0] wOut1, wOut2;
    wire [10:0] waddress;
    wire wIntButton_rot;
    wire [11:0] wInterpOut;
    wire wFreq_Chng ;
    wire [31:0] wsine1x;
    wire [31:0] wcos2x;
    wire wDac_clk;

    pll_top pll (
        .clkin (Ext_clk_27),
        .reset (~wpll_reset),
        .clkout (wpll_clk),
        .lock (wpll_lock)
    );

    clk_div clk_div_inst (
        .pll_clk(wpll_clk),
        .Resetn(wFg_resetn),
        .Fg_clk(wFg_clk),
        .Dac_clk(clk_out)
    );

    ResetGen_Module resetgen (
        .ExtRESETn(Ext_resetn),
        .CLK(Ext_clk_27),
        .PllRESETn(wpll_reset),
        .FgRESETn(wFg_resetn),
        .PllLocked(wpll_lock)
    );

    button button_sam (
        .Ext_button(Ext_button_sam),
        .IntButton(wIntButton_sam),
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn)
    );

    SamplingCtrl samCtrl (
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn),
        .IntBtn(wIntButton_sam),
        .Ready(wReady),
        .Enable(wEnable),
        .Mode(wMode)
    );

    Oscillator osc (
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn),
        .Enable(wEnable),
        .Ready(wReady),
        .init1(/*32'd96878045*/wsine1x),
        .init2(/*32'd1054193702*/wcos2x),
        .FreqChng(wFreq_Chng),
        .Mode(wMode),
        .out1(wOut1),
        .out2(wOut2)
    );

    Interpolator interp (
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn),
        .Out1(wOut1),
        .Out2(wOut2),
        .Mode(wMode),
        .Enable(wEnable),
        .InterpOut(osc_out)
    );

    button button_rot (
        .Ext_button(Rot_C),
        .IntButton(wIntButton_rot),
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn)
    );

    Rotary rot (
        .Fg_clk(wFg_clk),
        .Rot_A(Rot_A),
        .Rot_B(Rot_B),
        .Rot_C(wIntButton_rot),
        .Mode(wMode),
        .address(waddress),
        .Resetn(wFg_resetn),
        .FreqChng(wFreq_Chng)
    );

    Table_coef table_in(
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn),
        .address(waddress),
        .out1(),
        .out2(),
        .sine1x(wsine1x),
        .cos2x(wcos2x)
    );

endmodule