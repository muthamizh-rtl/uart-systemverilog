module uart_rx #(
    parameter int CLOCK_FREQ   = 50_000_000,
    parameter int BAUD_RATE    = 9_600,
    parameter int CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       rx,

    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_busy
);

    localparam int HALF_CLKS = CLKS_PER_BIT / 2;
    localparam int COUNT_WIDTH = $clog2(CLKS_PER_BIT);

    logic rx_sync1;
    logic rx_sync2;

    logic [COUNT_WIDTH-1:0] baud_counter;
    logic [2:0] bit_index;
    logic [7:0] data_reg;

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    always_ff @(posedge clk) begin

        if (reset) begin
            rx_sync1     <= 1'b1;
            rx_sync2     <= 1'b1;
            baud_counter <= '0;
            bit_index    <= '0;
            data_reg     <= '0;
            rx_data      <= '0;
            rx_valid     <= 1'b0;
            rx_busy      <= 1'b0;
            state        <= IDLE;
        end

        else begin

            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
            rx_valid <= 1'b0;

            case (state)

                IDLE: begin
                    baud_counter <= '0;
                    bit_index    <= '0;
                    rx_busy      <= 1'b0;

                    if (!rx_sync2) begin
                        rx_busy      <= 1'b1;
                        baud_counter <= '0;
                        state        <= START;
                    end
                end

                START: begin
                    if (baud_counter == HALF_CLKS - 1) begin
                        baud_counter <= '0;

                        if (!rx_sync2) begin
                            bit_index <= '0;
                            state     <= DATA;
                        end
                        else begin
                            rx_busy <= 1'b0;
                            state   <= IDLE;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter       <= '0;
                        data_reg[bit_index] <= rx_sync2;

                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= '0;
                        rx_data      <= data_reg;
                        rx_valid     <= 1'b1;
                        rx_busy      <= 1'b0;
                        state        <= IDLE;
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                default: begin
                    baud_counter <= '0;
                    bit_index    <= '0;
                    rx_busy      <= 1'b0;
                    state        <= IDLE;
                end

            endcase
        end
    end

endmodule