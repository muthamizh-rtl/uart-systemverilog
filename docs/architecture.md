# UART Controller Architecture

## Design Overview

The UART controller implements asynchronous serial communication using independent transmit and receive datapaths.

|    Parameter    |  Value |
|-----------------|--------|
| Clock Frequency | 50 MHz |
| Baud Rate       | 9600   |
| Data Width      | 8 bits |
| Parity          | None   |
| Stop Bits       |    1   |
| Bit Order       | LSB First |

## Architecture

```text
                    UART Controller
                           |
              +------------+------------+
              |                         |
              v                         v
       +-------------+           +-------------+
       | UART TX     |           | UART RX     |
       |             |           |             |
       | Control FSM |           | Synchronizer|
       | Baud Counter|           | Control FSM |
       | Data Reg    |           | Baud Counter|
       +------+------+           | Data Reg    |
              |                  +------+------+
              |                         ^
              +------ Serial Line ------+