`timescale 1ns/1ps

module uart_coverage_tb;

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

covergroup uart_coverage;

    cp_data: coverpoint tx_data {
        bins all_zero = {8'h00};
        bins all_one  = {8'hFF};
        bins pattern_55 = {8'h55};
        bins pattern_AA = {8'hAA};
        bins ascii_A = {8'h41};
    }

endgroup

uart_coverage cov = new();

task send_and_check(input logic [7:0] data);
begin
    @(posedge clk);

    while (tx_busy)
        @(posedge clk);

    tx_data = data;
    tx_start = 1'b1;

    @(posedge clk);
    tx_start = 1'b0;

    cov.sample();

    wait (rx_valid);

    if (rx_data !== data)
        $error("COVERAGE TEST ERROR: Expected 0x%02h, Received 0x%02h", data, rx_data);
    else
        $display("COVERAGE TEST PASS: 0x%02h", rx_data);

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

    $display("UART FUNCTIONAL COVERAGE TEST STARTED");

    send_and_check(8'h00);
    send_and_check(8'hFF);
    send_and_check(8'h55);
    send_and_check(8'hAA);
    send_and_check(8'h41);

    $display("Coverage = %0.2f%%", cov.get_inst_coverage());
    $display("UART FUNCTIONAL COVERAGE TEST COMPLETED");

    #100;
    $finish;
end

endmodule