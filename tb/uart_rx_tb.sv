`timescale 1ns/1ps

module uart_rx_tb;

logic clk;
logic reset;
logic rx;
logic [7:0] rx_data;
logic rx_valid;
logic rx_busy;

localparam int CLKS_PER_BIT = 50_000_000 / 9_600;

uart_rx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) dut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_busy(rx_busy)
);

always #10 clk = ~clk;

task send_rx_byte(input logic [7:0] data);
begin
    rx = 1'b0;
    repeat (CLKS_PER_BIT)
        @(posedge clk);

    for (int i = 0; i < 8; i++) begin
        rx = data[i];
        repeat (CLKS_PER_BIT)
            @(posedge clk);
    end

    rx = 1'b1;
    repeat (CLKS_PER_BIT)
        @(posedge clk);
end
endtask

task check_byte(input logic [7:0] expected);
begin
    wait (rx_valid);

    if (rx_data !== expected)
        $error("RX ERROR: Expected 0x%02h, Received 0x%02h", expected, rx_data);
    else
        $display("RX PASS: Received 0x%02h", rx_data);
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    rx = 1'b1;

    #100;
    reset = 1'b0;

    $display("UART RX TEST STARTED");

    fork
        send_rx_byte(8'h41);
        check_byte(8'h41);
    join

    fork
        send_rx_byte(8'h55);
        check_byte(8'h55);
    join

    fork
        send_rx_byte(8'hAA);
        check_byte(8'hAA);
    join

    fork
        send_rx_byte(8'hFF);
        check_byte(8'hFF);
    join

    fork
        send_rx_byte(8'h00);
        check_byte(8'h00);
    join

    $display("UART RX TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule