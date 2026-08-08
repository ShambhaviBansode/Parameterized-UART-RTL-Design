`timescale 1ns / 1ps

module uart_receiver_block #
(
    parameter DATA_WIDTH = 8,
    parameter [1:0] PARITY_MODE = 2'd0
)
(
    input clk,
    input rst,
    input rx,
    input rdy_clr,
    input clk_en,

    output reg rx_done,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg parity_bit,
    output reg stop_bit
);

localparam idle_state   = 3'b000;
localparam start_state  = 3'b001;
localparam data_state   = 3'b010;
localparam parity_state = 3'b011;
localparam stop_state   = 3'b100;


reg [2:0] state;
reg [3:0] sample;
reg [2:0] index;
reg [DATA_WIDTH-1:0] temp_register;


always @(posedge clk)
begin

    if(rst)
    begin
        rx_done       <= 1'b0;
        data_out      <= {DATA_WIDTH{1'b0}};
        parity_bit    <= 1'b0;
        stop_bit      <= 1'b1;

        state         <= idle_state;
        sample        <= 4'd0;
        index         <= 3'd0;
        temp_register <= {DATA_WIDTH{1'b0}};
    end

    else
    begin

        if(rdy_clr)
            rx_done <= 1'b0;


        if(clk_en)
        begin

            case(state)


            idle_state:
            begin
                sample <= 4'd0;

                if(rx == 1'b0)
                    state <= start_state;
            end


            start_state:
            begin
                sample <= sample + 1'b1;

                if(sample == 4'd15)
                begin
                    sample <= 4'd0;
                    index <= 3'd0;
                    temp_register <= {DATA_WIDTH{1'b0}};
                    state <= data_state;
                end
            end


            data_state:
            begin
                sample <= sample + 1'b1;

                if(sample == 4'd8)
                    temp_register[index] <= rx;


                if(sample == 4'd15)
                begin
                    sample <= 4'd0;

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


            parity_state:
            begin
                sample <= sample + 1'b1;


                if(sample == 4'd8)
                    parity_bit <= rx;


                if(sample == 4'd15)
                begin
                    sample <= 4'd0;
                    state <= stop_state;
                end

            end


            stop_state:
            begin

                stop_bit <= rx;

                data_out <= temp_register;
                rx_done <= 1'b1;


                state <= idle_state;
                sample <= 4'd0;
                index <= 3'd0;

            end


            default:
            begin
                state <= idle_state;
                sample <= 4'd0;
                index <= 3'd0;
            end


            endcase

        end

    end

end

endmodule