module dds_top(
    input Ext_clk_27,
    input Ext_resetn,
    input Ext_button_sam,
    input rot_A,
    input rot_B,
    input rot_C,
    output [4:0] led_Mode,
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
    wire wFreq_Chng ;
    wire [31:0] wsine1x;
    wire [31:0] wcos2x;

    ResetGen_Module resetgen (
        .ExtRESETn(Ext_resetn),
        .CLK(Ext_clk_27),
        .PllRESETn(wpll_reset),
        .FgRESETn(wFg_resetn),
        .PllLocked(wpll_lock)
    );

    pll_module pll (
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
        .init1(wsine1x),
        .init2(wcos2x),
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
        .Ext_button(rot_C),
        .IntButton(wIntButton_rot),
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn)
    );

    Rotary rot (
        .Fg_clk(wFg_clk),
        .Rot_A(rot_A),
        .Rot_B(rot_B),
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
        .out1(0),
        .out2(0),
        .sine1x(wsine1x),
        .cos2x(wcos2x)
    );
    Led led(
        .Fg_clk(wFg_clk),
        .Resetn(wFg_resetn),
        .Mode(wMode),
        .Led_Mode(led_Mode)
    );
endmodule