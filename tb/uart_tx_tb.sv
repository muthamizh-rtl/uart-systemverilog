`timescale 1ns/1ps

module uart_tx_tb;

logic clk;
logic reset;
logic tx_start;
logic [7:0] tx_data;
logic tx;
logic tx_busy;

uart_tx #(
    .CLOCK_FREQ(50_000_000),
    .BAUD_RATE(9_600)
) dut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

always #10 clk = ~clk;

task send_byte(input logic [7:0] data);
begin
    @(posedge clk);

    while (tx_busy)
        @(posedge clk);

    tx_data = data;
    tx_start = 1'b1;

    @(posedge clk);
    tx_start = 1'b0;

    if (!tx_busy)
        $error("TX busy did not assert for data 0x%02h", data);

    $display("Sending data = 0x%02h", data);

    wait (!tx_busy);

    if (tx !== 1'b1)
        $error("TX is not HIGH after transmission");

    $display("Completed data = 0x%02h", data);
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    tx_start = 1'b0;
    tx_data = 8'h00;

    #100;
    reset = 1'b0;

    if (tx !== 1'b1)
        $error("TX is not HIGH after reset");

    if (tx_busy !== 1'b0)
        $error("TX busy is not LOW after reset");

    $display("UART ASSERTION TEST STARTED");

    send_byte(8'h41);
    send_byte(8'h55);
    send_byte(8'hAA);
    send_byte(8'hFF);
    send_byte(8'h00);

    $display("UART ASSERTION TEST COMPLETED");
    $display("TEST PASSED");

    #100;
    $finish;
end

endmodule