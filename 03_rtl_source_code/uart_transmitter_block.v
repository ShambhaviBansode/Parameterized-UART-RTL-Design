`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2026 10:28:16 AM
// Design Name: 
// Module Name: uart_transmitter_block
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


module uart_transmitter_block #
(
    parameter DATA_WIDTH = 8,
    parameter [1:0] PARITY_MODE = 2'd0     // 0 = None, 1 = Even, 2 = Odd
)
(
    input clk,
    input rst,
    input wr_enb,
    input enb,
    input [DATA_WIDTH-1:0] data_in,

    output reg tx,
    output busy
);

localparam idle_state   = 3'd0;
localparam start_state  = 3'd1;
localparam data_state   = 3'd2;
localparam parity_state = 3'd3;
localparam stop_state   = 3'd4;

reg [DATA_WIDTH-1:0] data;
reg [2:0] index;
reg parity_bit;
reg [2:0] state;

assign busy = (state != idle_state);

// UART Transmitter FSM
always @(posedge clk)
begin

    if(rst)
    begin
        tx         <= 1'b1;
        data       <= {DATA_WIDTH{1'b0}};
        index      <= 3'd0;
        parity_bit <= 1'b0;
        state      <= idle_state;
    end

    else
    begin

        case(state)

        // Idle State
        idle_state:
        begin
            tx <= 1'b1;

            if(wr_enb)
            begin
                data  <= data_in;
                index <= 3'd0;

               case(PARITY_MODE)
                 2'd0: parity_bit <= 1'b0;
                 2'd1: parity_bit <= ^data_in;
                 2'd2: parity_bit <= ~(^data_in);
                 default: parity_bit <= 1'b0;
endcase

                state <= start_state;
            end
        end

        // Start Bit
        start_state:
        begin
            if(enb)
            begin
                tx <= 1'b0;
                state <= data_state;
            end
        end

        // Data Bits
        data_state:
        begin
            if(enb)
            begin
                tx <= data[index];

                if(index == DATA_WIDTH-1)
                begin
                    if(PARITY_MODE == 2'd0)
                        state <= stop_state;
                    else
                        state <= parity_state;
                end
                else
                begin
                    index <= index + 1'b1;
                end
            end
        end

        // Parity Bit
        parity_state:
        begin
            if(enb)
            begin
                tx <= parity_bit;
                state <= stop_state;
            end
        end

        // Stop Bit
        stop_state:
        begin
            if(enb)
            begin
                tx <= 1'b1;
                state <= idle_state;
                index <= 3'd0;
            end
        end

        default:
        begin
            tx <= 1'b1;
            index <= 3'd0;
            state <= idle_state;
        end

        endcase

    end

end

endmodule