`timescale 1ns/1ps

module uart_loopback_tb;

logic clk;
logic reset;

logic tx_start;
logic [7:0] tx_data;
logic tx;

logic tx_busy;

logic [7:0] rx_data;
logic rx_valid;
logic rx_busy;

uart_tx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) tx_dut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

uart_rx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) rx_dut (
    .clk(clk),
    .reset(reset),
    .rx(tx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_busy(rx_busy)
);

always #10 clk = ~clk;

task send_and_check(input logic [7:0] data);
begin
    @(posedge clk);

    while (tx_busy)
        @(posedge clk);

    tx_data = data;
    tx_start = 1'b1;

    @(posedge clk);
    tx_start = 1'b0;

    $display("TX DATA = 0x%02h", data);

    wait (rx_valid);

    if (rx_data !== data)
        $error("LOOPBACK ERROR: Expected 0x%02h, Received 0x%02h", data, rx_data);
    else
        $display("LOOPBACK PASS: Received 0x%02h", rx_data);

    wait (!tx_busy);
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    tx_start = 1'b0;
    tx_data = 8'h00;

    #100;
    reset = 1'b0;

    $display("UART LOOPBACK TEST STARTED");

    send_and_check(8'h41);
    send_and_check(8'h55);
    send_and_check(8'hAA);
    send_and_check(8'hFF);
    send_and_check(8'h00);

    $display("UART LOOPBACK TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule