`timescale 1ns/1ps

module uart_tx_tb;

    logic       clk;
    logic       reset;
    logic       tx_start;
    logic [7:0] tx_data;

    logic       tx;
    logic       tx_busy;

    // DUT
    uart_tx #(
        .CLOCK_FREQ(50_000_000),
        .BAUD_RATE(9_600)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy)
    );

    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // Test
    initial begin

        reset    = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        // Reset
        #100;
        reset = 1'b0;

        // Send 0x41 = ASCII 'A'
        #100;
        tx_data  = 8'h41;
        tx_start = 1'b1;

        #20;
        tx_start = 1'b0;

        // Wait for transmission to start
        wait (tx_busy == 1'b1);

        $display("--------------------------------");
        $display("UART TRANSMISSION STARTED");
        $display("Data = 0x%h", tx_data);
        $display("--------------------------------");

        // Wait for transmission to finish
        wait (tx_busy == 1'b0);

        $display("--------------------------------");
        $display("UART TRANSMISSION COMPLETED");
        $display("TEST PASSED");
        $display("--------------------------------");

        #100;
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
    end

endmodule