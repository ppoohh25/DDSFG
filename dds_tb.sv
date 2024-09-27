`timescale 1ns/1ns

module all_module_tb();
    
    // ----------- registers -----------
    reg Ext_resetn =1;
    reg Ext_clk_27 =0; 
    reg Ext_button_sam =1;
    reg Rot_A = 1;
    reg Rot_B = 1;
    reg Rot_C = 1;
    // ----------- wires -----------
    // wire wpll_clk;
    // wire wpll_reset;
    // wire wFg_resetn;
    // wire wIntButton_sam;
    // wire wFg_clk;
    // wire wpll_lock;
    // wire wEnable;
    // wire wReady;
    // wire [2:0] wMode;
    // wire [31:0] wOut1, wOut2;
    // wire [10:0] waddress;
    // wire wIntButton_rot;
    // wire [11:0] wInterpOut;
    // wire wFreq_Chng ;
    // wire [31:0] wsine1x;
    // wire [31:0] wcos2x;
    // wire wDac_clk;
     wire [11:0] osc_out;
     wire clk_out;
     wire [4:0] Led_Mode;


task change_mode();
    begin
        for (integer i=0; i<10; i++ ) begin
            Ext_button_sam<=~Ext_button_sam;
            @(posedge Ext_clk_27);
        end

        for (integer i=0; i<20; i++ ) begin
            Ext_button_sam<=0;
            @(posedge Ext_clk_27);
        end

        for (integer i=0; i<10; i++ ) begin
            Ext_button_sam<=~Ext_button_sam;
            @(posedge Ext_clk_27);
        end

        Ext_button_sam <=1;


    end
endtask

task rot_plus();
    begin
        Rot_B <= 0;
        repeat(10)@(posedge Ext_clk_27);
        Rot_A <= 0;
        repeat(10)@(posedge Ext_clk_27);
        Rot_B <= 1;
        repeat(10)@(posedge Ext_clk_27);
        Rot_A <= 1;
        repeat(256)@(posedge Ext_clk_27);
    end
endtask

task rot_minus();
    begin
        Rot_A <= 0;
        repeat(10)@(posedge Ext_clk_27);
        Rot_B <= 0;
        repeat(10)@(posedge Ext_clk_27);
        Rot_A <= 1;
        repeat(10)@(posedge Ext_clk_27);
        Rot_B <= 1;
        repeat(256)@(posedge Ext_clk_27);
    end
endtask 

task rot_push();
    begin
        for (integer i=0; i<10; i++ ) begin
            Rot_C<=~Rot_C;
            @(posedge Ext_clk_27);
        end

        for (integer i=0; i<20; i++ ) begin
            Rot_C<=0;
            @(posedge Ext_clk_27);
        end

        for (integer i=0; i<10; i++ ) begin
            Rot_C<=~Rot_C;
            @(posedge Ext_clk_27);
        end

        Rot_C <=1;


    end
endtask 

task full();
    begin
        repeat(2000)@(posedge Ext_clk_27) begin
            rot_plus();
            repeat(100)@(posedge Ext_clk_27);
        end
        change_mode();
        //mode 1
        repeat(2000)@(posedge Ext_clk_27) begin
            rot_minus();
            repeat(100)@(posedge Ext_clk_27);
        end
        change_mode();
        //mode 2
        repeat(2000)@(posedge Ext_clk_27) begin
            rot_plus();
            repeat(100)@(posedge Ext_clk_27);
        end
        change_mode();
        //mode 3
         repeat(2000)@(posedge Ext_clk_27) begin
            rot_minus();
            repeat(100)@(posedge Ext_clk_27);
        end
        change_mode();
        //mode 4
        repeat(2000)@(posedge Ext_clk_27) begin
            rot_plus();
            repeat(100)@(posedge Ext_clk_27);
        end
         repeat(2000)@(posedge Ext_clk_27) begin
            rot_minus();
            repeat(100)@(posedge Ext_clk_27);
        end

        rot_push();
        repeat(100)@(posedge Ext_clk_27);
        repeat(100)@(posedge Ext_clk_27) begin
            rot_plus();
            repeat(100)@(posedge Ext_clk_27);
        end

        rot_push();
        repeat(100)@(posedge Ext_clk_27);
        repeat(100)@(posedge Ext_clk_27) begin
            rot_minus();
            repeat(100)@(posedge Ext_clk_27);
        end

        rot_push();
        repeat(100)@(posedge Ext_clk_27);
        repeat(100)@(posedge Ext_clk_27) begin
            rot_plus();
            repeat(100)@(posedge Ext_clk_27);
        end

    end
endtask


    // ----------- device under test -----------

    // wire wpll_clk;
    // wire wpll_reset;
    // wire wFg_resetn;
    // wire wIntButton_sam;
    // wire wFg_clk;
    // wire wpll_lock;
    // wire wEnable;
    // wire wReady;
    // wire [2:0] wMode;
    // wire [31:0] wOut1, wOut2;
    // wire [10:0] waddress;
    // wire wIntButton_rot;
    // wire wFreq_Chng ;
    // wire [31:0] wsine1x;
    // wire [31:0] wcos2x;
    // wire [4:0] wLed_Mode;

    // ResetGen_Module resetgen (
    //     .ExtRESETn(Ext_resetn),
    //     .CLK(Ext_clk_27),
    //     .PllRESETn(wpll_reset),
    //     .FgRESETn(wFg_resetn),
    //     .PllLocked(wpll_lock)
    // );

    // pll_top pll (
    //     .clkin (Ext_clk_27),
    //     .reset (~wpll_reset),
    //     .clkout (wpll_clk),
    //     .lock (wpll_lock)
    // );

    // clk_div clk_div_inst (
    //     .pll_clk(wpll_clk),
    //     .Resetn(wFg_resetn),
    //     .Fg_clk(wFg_clk),
    //     .Dac_clk(clk_out)
    // );

    // button button_sam (
    //     .Ext_button(Ext_button_sam),
    //     .IntButton(wIntButton_sam),
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn)
    // );

    // SamplingCtrl samCtrl (
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn),
    //     .IntBtn(wIntButton_sam),
    //     .Ready(wReady),
    //     .Enable(wEnable),
    //     .Mode(wMode),
    //     .Led_Mode(wLed_Mode)
    // );

    // Oscillator osc (
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn),
    //     .Enable(wEnable),
    //     .Ready(wReady),
    //     .init1(wsine1x),
    //     .init2(wcos2x),
    //     .FreqChng(wFreq_Chng),
    //     .Mode(wMode),
    //     .out1(wOut1),
    //     .out2(wOut2)
    // );

    // Interpolator interp (
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn),
    //     .Out1(wOut1),
    //     .Out2(wOut2),
    //     .Mode(wMode),
    //     .Enable(wEnable),
    //     .InterpOut(osc_out)
    // );

    // button button_rot (
    //     .Ext_button(Rot_C),
    //     .IntButton(wIntButton_rot),
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn)
    // );

    // Rotary rot (
    //     .Fg_clk(wFg_clk),
    //     .Rot_A(Rot_A),
    //     .Rot_B(Rot_B),
    //     .Rot_C(wIntButton_rot),
    //     .Mode(wMode),
    //     .address(waddress),
    //     .Resetn(wFg_resetn),
    //     .FreqChng(wFreq_Chng)
    // );

    // Table_coef table_in(
    //     .Fg_clk(wFg_clk),
    //     .Resetn(wFg_resetn),
    //     .address(waddress),
    //     .out1(0),
    //     .out2(0),
    //     .sine1x(wsine1x),
    //     .cos2x(wcos2x)
    // );

    dds_top top(
        .Ext_clk_27(Ext_clk_27),
        .Ext_resetn(Ext_resetn),
        .Ext_button_sam(Ext_button_sam),
        .rot_A(Rot_A),
        .rot_B(Rot_B),
        .rot_C(Rot_C),
        .osc_out(osc_out),
        .clk_out(clk_out),
        .Led_Mode(Led_Mode)
    );

    // ----------- system signal generator-----------
    always #(37037/2) Ext_clk_27 = ~Ext_clk_27; //27M

    // ----------- test scenarios -----------
    initial begin
        $display("Starting test");
        repeat(10_000)@(posedge Ext_clk_27);
        #100 Ext_resetn = 0;
        #100 Ext_resetn = 1;
        // change_mode();
        // repeat(2000)begin
        //     rot_plus();
        //     repeat(300)@(posedge Ext_clk_27);
        // end
        // //change_mode();
        // repeat(30000)@(posedge Ext_clk_27);
        // repeat(2000)begin
        //     rot_minus();
        //     repeat(300)@(posedge Ext_clk_27);
        // end
        //rot_push();
        // repeat(2) begin
        //     rot_push();
        //     repeat(3000)@(posedge Ext_clk_27);
        // end

        //----------Critical Error------------------
        // repeat(100)@(posedge Ext_clk_27);
        // repeat(2300)rot_plus();
        // repeat(10000)@(posedge Ext_clk_27);
        // change_mode();
        // repeat(4000)@(posedge Ext_clk_27);

        // repeat(2000)begin
        //      rot_plus();
        //      repeat(100)@(posedge Ext_clk_27);
        // end
        //change_mode();
        //repeat(10000)@(posedge Ext_clk_27);
        //------------ Error at address 1715-1743 -----------------------


        //-------------------------------------------

        //-----------Change Mode Check------------------
        // repeat(100)@(posedge Ext_clk_27);
        // repeat(8)begin
        //     change_mode();
        //     repeat(3000)@(posedge Ext_clk_27);
        // end
        // repeat(50000)@(posedge Ext_clk_27);
        //-----------------------------------------------
        full();
        // repeat(100)@(posedge Ext_clk_27) begin
        //     rot_push();
        //     repeat(100)@(posedge Ext_clk_27);
        // end
        // repeat(250)rot_plus();
        // Ext_resetn = 0;
        // repeat(100)@(posedge Ext_clk_27);
        // Ext_resetn = 1;
        // repeat(250)rot_plus();
        // repeat(2000)@(posedge Ext_clk_27);
        // change_mode();
        
        // repeat(3000)@(posedge Ext_clk_27);
        // change_mode();
        // repeat(3000)@(posedge Ext_clk_27);
        // change_mode();
        //  rot_push();
        // repeat(3000)@(posedge Ext_clk_27);
        // change_mode();
        // rot_push();
        // // repeat(2000)@(posedge Ext_clk_27);
        // // change_mode();
        // for(integer i = 0; i < 18;i++) begin
        //     rot_plus();
        //     repeat(100_000)@(posedge Ext_clk_27);
        // end

        repeat(10000)@(posedge Ext_clk_27);
        $stop;
    end

    // ----------- dumping wave -----------
    initial begin
        $dumpfile("all_module_tb.vcd");
        $dumpvars(0,all_module_tb);
    end
    
endmodule
