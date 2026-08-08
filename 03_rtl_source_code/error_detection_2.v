`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2026 12:14:24 PM
// Design Name: 
// Module Name: error_detection_2
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


module error_detection_2
(
    data,
    received_parity,
    stop_bit,
    parity_mode,
    parity_error,
    framing_error
);

parameter DATA_WIDTH = 8;

input [DATA_WIDTH-1:0] data;
input received_parity;
input stop_bit;
input [1:0] parity_mode;

output reg parity_error;
output reg framing_error;

reg calculated_parity;

always @(*)
begin

    parity_error = 1'b0;
    framing_error = 1'b0;

    case(parity_mode)

        2'd0:
            parity_error = 1'b0;

        2'd1:
        begin
            calculated_parity = ^data;

            if(received_parity != calculated_parity)
                parity_error = 1'b1;
        end

        2'd2:
        begin
            calculated_parity = ~(^data);

            if(received_parity != calculated_parity)
                parity_error = 1'b1;
        end

        default:
            parity_error = 1'b0;

    endcase

    if(stop_bit != 1'b1)
        framing_error = 1'b1;

end

endmodule
