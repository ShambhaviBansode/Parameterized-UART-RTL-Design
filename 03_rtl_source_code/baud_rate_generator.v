`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2026 10:25:27 AM
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_rate_generator
#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)
(
    input clk,
    input rst,
    output tx_enb,
    output rx_enb
);

localparam TX_DIV = CLK_FREQ / BAUD_RATE;
localparam RX_DIV = TX_DIV / 16;

reg [12:0] tx_counter;
reg [9:0] rx_counter;

// Generates baud enable pulse for transmitter
always @(posedge clk)
begin
    if (rst)
        tx_counter <= 13'd0;
    else if (tx_counter == TX_DIV - 1)
        tx_counter <= 13'd0;
    else
        tx_counter <= tx_counter + 1'b1;
end

// Generates 16x baud enable pulse for receiver
always @(posedge clk)
begin
    if (rst)
        rx_counter <= 10'd0;
    else if (rx_counter == RX_DIV - 1)
        rx_counter <= 10'd0;
    else
        rx_counter <= rx_counter + 1'b1;
end

assign tx_enb = (tx_counter == 13'd0);
assign rx_enb = (rx_counter == 10'd0);

endmodule
