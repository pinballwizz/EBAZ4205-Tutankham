//============================================================================
// 
//  Tutankham top-level module
//  Copyright (C) 2021 Ace
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//============================================================================

//Module declaration, I/O ports
module Tutankham
(
	input                reset,
	input                clk_49m,                  //Actual frequency: 49.152MHz
	input          [1:0] coin,                     //0 = coin 1, 1 = coin 2
	input          [1:0] start_buttons,            //0 = Player 1, 1 = Player 2
	input          [3:0] p1_joystick, p2_joystick, //0 = up, 1 = down, 2 = left, 3 = right
//	input                p1_fire,
//	input                p2_fire,
	input                m_fire1_l, m_fire1_r, m_flash1, // P1: fire left, fire right, flash bomb
	input                m_fire2_l, m_fire2_r, m_flash2, // P2: fire left, fire right, flash bomb
	output               video_hsync, video_vsync,
	output               video_hblank, video_vblank,
	output         [4:0] video_r, video_g, video_b,
	output signed [15:0] sound,
	output        [15:0] AD
);
//--------------------------------------------------------------
wire [15:0] cpu_A;
wire  btn_service = 1'b0;
wire [15:0] dip_sw;
wire  ce_pix;
wire [3:0] v_center = 4'b0;
wire [3:0] h_center = 4'b0;
wire pause = 1'b0;
wire video_csync;
wire underclock = 1'b0;

wire        [15:0] hs_address = 16'b0;
wire         [7:0] hs_data_in = 8'b0;
wire         [7:0] hs_data_out;
wire          hs_write =1'b0;

assign dip_sw[15:8] = 8'b01101011;
assign dip_sw [7:0] = 8'b11111111;

//---------------------------------------------------------------
//Linking signals between PCBs
wire A5, A6, irq_trigger, cs_sounddata, cs_controls_dip1, cs_dip2;
wire [7:0] controls_dip, cpubrd_D;

//Instantiate main PCB
Tutankham_CPU main_pcb
(
	.reset(reset),
	.clk_49m(clk_49m),
	.red(video_r),
	.green(video_g),
	.blue(video_b),
	.video_hsync(video_hsync),
	.video_vsync(video_vsync),
	.video_csync(video_csync),
	.video_hblank(video_hblank),
	.video_vblank(video_vblank),
	.ce_pix(ce_pix),	
	.h_center(h_center),
	.v_center(v_center),	
	.controls_dip(controls_dip),
	.dip_sw(dip_sw),
	.p1_fire_ext({m_flash1, m_fire1_r, m_fire1_l}),
	.p2_fire_ext({m_flash2, m_fire2_r, m_fire2_l}),
	.p1_joy({~p1_joystick[1], ~p1_joystick[0], ~p1_joystick[3], ~p1_joystick[2]}),
	.p2_joy({~p2_joystick[1], ~p2_joystick[0], ~p2_joystick[3], ~p2_joystick[2]}),
	.cpubrd_Dout(cpubrd_D),
	.cpubrd_A5(A5),
	.cpubrd_A6(A6),
	.cs_sounddata(cs_sounddata),
	.irq_trigger(irq_trigger),
	.cs_dip2(cs_dip2),
	.cs_controls_dip1(cs_controls_dip1),
	.pause(pause),
	.hs_address(hs_address),
	.hs_data_out(hs_data_out),
	.hs_data_in(hs_data_in),
	.hs_write(hs_write)
);

//Instantiate sound PCB
TimePilot_SND sound_pcb
(
	.reset(reset),
	.clk_49m(clk_49m),
	.irq_trigger(irq_trigger),
	.cs_sounddata(cs_sounddata),
	.dip_sw(dip_sw),
	.coin(coin),
	.start_buttons(start_buttons),
	.p1_joystick(p1_joystick),
	.p2_joystick(p2_joystick),
	.p1_fire(~m_fire1_l),
	.p2_fire(~m_fire2_l),
	.btn_service(btn_service),	
	.cs_controls_dip1(cs_controls_dip1),
	.cs_dip2(cs_dip2),
	.cpubrd_A5(A5),
	.cpubrd_A6(A6),
	.cpubrd_Din(cpubrd_D),	
	.controls_dip(controls_dip),
	.sound(sound),	
	.underclock(underclock),
	.AD(AD)
);

endmodule