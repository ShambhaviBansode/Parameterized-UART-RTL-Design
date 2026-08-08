
`timescale 1ns / 1ps

module uart_top_tb;

parameter DATA_WIDTH  = 8;
parameter CLK_FREQ    = 50000000;
parameter BAUD_RATE   = 9600;
parameter PARITY_MODE = 2'd1;

reg clk;
reg rst;
reg wr_en;
reg rdy_clr;
reg [DATA_WIDTH-1:0] data_in;
reg rx_serial_tb;
reg loopback_enable;

wire tx_serial;
wire tx_busy;

wire rx_done;
wire [DATA_WIDTH-1:0] data_out;

wire parity_error;
wire framing_error;

uart_top_module
#(
    .DATA_WIDTH(DATA_WIDTH),
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .PARITY_MODE(PARITY_MODE)
)
dut
(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rdy_clr(rdy_clr),
    .data_in(data_in),

    .rx_serial(loopback_enable ? tx_serial : rx_serial_tb),

    .tx_serial(tx_serial),
    .tx_busy(tx_busy),

    .rx_done(rx_done),
    .data_out(data_out),

    .parity_error(parity_error),
    .framing_error(framing_error)
);

always
begin
    #10 clk = ~clk;
end

integer total_tests;
integer passed_tests;
integer failed_tests;

reg [DATA_WIDTH-1:0] expected_data;

task reset_dut;
begin

    rst = 1'b1;
    wr_en = 1'b0;
    rdy_clr = 1'b0;
    data_in = 8'd0;

    repeat(5)
        @(posedge clk);

    rst = 1'b0;

    repeat(5)
        @(posedge clk);

end
endtask

task send_byte;

input [7:0] tx_data;

begin

    @(posedge clk);

    while(tx_busy)
        @(posedge clk);

    data_in = tx_data;
    wr_en = 1'b1;

    @(posedge clk);

    wr_en = 1'b0;

end

endtask

task clear_ready;

begin

    @(posedge clk);

    rdy_clr = 1'b1;

    @(posedge clk);

    rdy_clr = 1'b0;

end

endtask

task inject_uart_frame;

input [7:0] frame_data;
input parity;
input stop;

integer i;

begin

    // Start bit
    rx_serial_tb = 1'b0;
    #(104160);

    // Data bits (LSB first)
    for(i=0;i<8;i=i+1)
    begin
        rx_serial_tb = frame_data[i];
        #(104160);
    end


    // Parity bit
    if(PARITY_MODE != 0)
    begin
        rx_serial_tb = parity;
        #(104160);
    end


    // Stop bit
    rx_serial_tb = stop;
    #(104160);


    // Return to idle
    rx_serial_tb = 1'b1;

end

endtask
task check_data;

input [7:0] expected;

begin

    wait(rx_done);

    if(data_out == expected)
    begin

        $display("--------------------------------------");
        $display("PASS");
        $display("Expected = %h", expected);
        $display("Received = %h", data_out);
        $display("--------------------------------------");

        passed_tests = passed_tests + 1;

    end
    else
    begin

        $display("--------------------------------------");
        $display("FAIL");
        $display("Expected = %h", expected);
        $display("Received = %h", data_out);
        $display("--------------------------------------");

        failed_tests = failed_tests + 1;

    end

    total_tests = total_tests + 1;

    clear_ready();

end

endtask

initial
begin

clk = 1'b0;

rst = 1'b0;
wr_en = 1'b0;
rdy_clr = 1'b0;
data_in = 8'd0;
rx_serial_tb = 1'b1;
loopback_enable = 1'b1;

total_tests = 0;
passed_tests = 0;
failed_tests = 0;

reset_dut();

$display("--------------------------------------------");
$display("UART VERIFICATION STARTED");
$display("--------------------------------------------");
    // Test 1 : Single Byte Transmission

    $display("Test 1 : Single Byte Transmission");

    send_byte(8'h55);
    check_data(8'h55);



    // Test 2 : Continuous Multiple Byte Transmission

    $display("Test 2 : Continuous Multiple Byte Transmission");

    send_byte(8'h12);
    check_data(8'h12);

    send_byte(8'h34);
    check_data(8'h34);

    send_byte(8'h56);
    check_data(8'h56);

    send_byte(8'h78);
    check_data(8'h78);



    // Test 3 : Receiver Data Validation

    $display("Test 3 : Receiver Data Validation");

    send_byte(8'hA5);
    check_data(8'hA5);

    send_byte(8'h5A);
    check_data(8'h5A);



    // Test 4 : Random Data Transmission

    $display("Test 4 : Random Data Transmission");

    repeat(10)
    begin

        expected_data = $random;

        send_byte(expected_data);

        check_data(expected_data);

    end



    // Test 5 : Back-to-Back Packet Transfer

    $display("Test 5 : Back-to-Back Packet Transfer");

    send_byte(8'h11);
    send_byte(8'h22);
    send_byte(8'h33);
    send_byte(8'h44);

    check_data(8'h11);
    check_data(8'h22);
    check_data(8'h33);
    check_data(8'h44);



 // Test 6 : Parity Error Detection

$display("Test 6 : Parity Error Detection");

if(PARITY_MODE != 2'd0)
begin

    loopback_enable = 1'b0;

    inject_uart_frame(
        8'hAA,
        ~(^8'hAA),
        1'b1
    );

    wait(rx_done);

    if(parity_error)
    begin
        $display("PASS : Parity Error Detected");
        passed_tests = passed_tests + 1;
    end
    else
    begin
        $display("FAIL : Parity Error Not Detected");
        failed_tests = failed_tests + 1;
    end

    total_tests = total_tests + 1;

    clear_ready();

    loopback_enable = 1'b1;

end
else
begin

    $display("Parity Disabled. Test Skipped.");

end



// Test 7 : Framing Error Detection

$display("Test 7 : Framing Error Detection");


loopback_enable = 1'b0;


inject_uart_frame(
    8'h55,
    ^8'h55,
    1'b0
);


wait(rx_done);


if(framing_error)
begin
    $display("PASS : Framing Error Detected");
    passed_tests = passed_tests + 1;
end
else
begin
    $display("FAIL : Framing Error Not Detected");
    failed_tests = failed_tests + 1;
end


total_tests = total_tests + 1;


clear_ready();


loopback_enable = 1'b1;    
    
    
        $display(" ");
    $display("============================================");
    $display("         UART VERIFICATION SUMMARY");
    $display("============================================");

    $display("Total Test Cases  : %0d", total_tests);
    $display("Passed Test Cases : %0d", passed_tests);
    $display("Failed Test Cases : %0d", failed_tests);

    if(failed_tests == 0)
    begin
        $display(" ");
        $display("********************************************");
        $display("*      ALL TEST CASES PASSED SUCCESSFULLY  *");
        $display("********************************************");
    end
    else
    begin
        $display(" ");
        $display("********************************************");
        $display("*        SOME TEST CASES HAVE FAILED        *");
        $display("********************************************");
    end

    #100;

    $finish;

end

endmodule

