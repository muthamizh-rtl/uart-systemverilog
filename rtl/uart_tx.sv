module uart_tx #(
    parameter int CLOCK_FREQ   = 50_000_000,
    parameter int BAUD_RATE    = 9_600,
    parameter int CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       tx_start,
    input  logic [7:0] tx_data,

    output logic       tx,
    output logic       tx_busy
);

    // Baud-rate counter
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_counter;

    // UART states
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    // Data and bit counter
    logic [7:0] data_reg;
    logic [2:0] bit_index;

    // Sequential logic
    always_ff @(posedge clk) begin

        if (reset) begin
            state        <= IDLE;
            baud_counter <= '0;
            data_reg     <= '0;
            bit_index    <= '0;
            tx           <= 1'b1;
            tx_busy      <= 1'b0;
        end

        else begin

            case (state)

                IDLE: begin
                    tx           <= 1'b1;
                    tx_busy      <= 1'b0;
                    baud_counter <= '0;
                    bit_index    <= '0;

                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1'b1;
                        state    <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= '0;
                        bit_index    <= '0;
                        state        <= DATA;
                    end

                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_index];

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= '0;

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
                    tx <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= '0;
                        tx_busy      <= 1'b0;
                        state        <= IDLE;
                    end

                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                default: begin
                    state        <= IDLE;
                    baud_counter <= '0;
                    tx           <= 1'b1;
                    tx_busy      <= 1'b0;
                end

            endcase
        end
    end

endmodule