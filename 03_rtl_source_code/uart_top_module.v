`timescale 1ns / 1ps

module uart_top_module #
(
    parameter DATA_WIDTH = 8,
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600,
    parameter [1:0] PARITY_MODE = 2'd0
)
(
    input clk,
    input rst,
    input wr_en,
    input rdy_clr,

    input [DATA_WIDTH-1:0] data_in,
    input rx_serial,

    output tx_serial,
    output tx_busy,

    output rx_done,
    output [DATA_WIDTH-1:0] data_out,

    output parity_error,
    output framing_error
);


// Internal signals
wire tx_clk_en;
wire rx_clk_en;

wire parity_bit;
wire stop_bit;


//================================================
// Baud Rate Generator
//================================================

baud_rate_generator #
(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
)
bg
(
    .clk(clk),
    .rst(rst),

    .tx_enb(tx_clk_en),
    .rx_enb(rx_clk_en)
);


//================================================
// UART Transmitter
//================================================

uart_transmitter_block #
(
    .DATA_WIDTH(DATA_WIDTH),
    .PARITY_MODE(PARITY_MODE)
)
ut
(
    .clk(clk),
    .rst(rst),

    .wr_enb(wr_en),
    .enb(tx_clk_en),

    .data_in(data_in),

    .tx(tx_serial),
    .busy(tx_busy)
);


//================================================
// UART Receiver
//================================================

uart_receiver_block #
(
    .DATA_WIDTH(DATA_WIDTH),
    .PARITY_MODE(PARITY_MODE)
)
ur
(
    .clk(clk),
    .rst(rst),

    .rx(rx_serial),

    .rdy_clr(rdy_clr),
    .clk_en(rx_clk_en),

    .rx_done(rx_done),

    .data_out(data_out),

    .parity_bit(parity_bit),
    .stop_bit(stop_bit)
);


//================================================
// Error Detection Logic
//================================================

error_detection_2 #
(
    .DATA_WIDTH(DATA_WIDTH)
)
ed
(
    .data(data_out),

    .received_parity(parity_bit),

    .stop_bit(stop_bit),

    .parity_mode(PARITY_MODE),

    .parity_error(parity_error),

    .framing_error(framing_error)
);


endmodule