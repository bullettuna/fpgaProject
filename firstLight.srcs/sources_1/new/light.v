`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/25 16:34:30
// Design Name: 
// Module Name: light
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module light #(
    parameter integer CLK_FREQ_HZ      = 50_000_000,
    parameter integer PWM_BITS         = 10,
    parameter integer BREATH_PERIOD_MS = 4000
)(
    input  wire clk,
    output wire led1,
    output wire led2,
    output wire led3,
    output wire led4
);

localparam integer PWM_LEVELS = (1 << PWM_BITS);

// A complete breath contains one rising ramp and one falling ramp.
localparam integer STEP_DIV =
    (64'd1 * CLK_FREQ_HZ * BREATH_PERIOD_MS) /
    (2 * (PWM_LEVELS - 1) * 1000);

localparam [PWM_BITS-1:0] PWM_MAX = {PWM_BITS{1'b1}};

reg [PWM_BITS-1:0] pwm_counter = {PWM_BITS{1'b0}};
reg [PWM_BITS-1:0] brightness  = {PWM_BITS{1'b0}};
reg [31:0]         step_counter = 32'd0;
reg                ramp_up      = 1'b1;

always @(posedge clk) begin
    // Free-running PWM carrier. The counter wraps automatically.
    pwm_counter <= pwm_counter + 1'b1;

    // Update the duty cycle at a much slower, clock-enabled rate.
    if (step_counter == STEP_DIV - 1) begin
        step_counter <= 32'd0;

        if (ramp_up) begin
            if (brightness == PWM_MAX) begin
                ramp_up   <= 1'b0;
                brightness <= brightness - 1'b1;
            end
            else begin
                brightness <= brightness + 1'b1;
            end
        end
        else begin
            if (brightness == {PWM_BITS{1'b0}}) begin
                ramp_up   <= 1'b1;
                brightness <= brightness + 1'b1;
            end
            else begin
                brightness <= brightness - 1'b1;
            end
        end
    end
    else begin
        step_counter <= step_counter + 1'b1;
    end
end

// All four PL LEDs are active-low on the Mizar-Z7 board.
// LED2 is on while the PWM comparison is true.
assign led2 = (pwm_counter < brightness) ? 1'b0 : 1'b1;

// Keep the other PL LEDs off.
assign led1 = 1'b1;
assign led3 = 1'b1;
assign led4 = 1'b1;

endmodule
