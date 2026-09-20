# UART Verification

## Verification Scope

The UART controller was verified using SystemVerilog simulation.

## Tests

|        Test                      | Result|
|----------------------------------|-------|
| UART TX single-byte transmission | PASS  |
| UART TX multi-byte transmission  | PASS  |
| UART TX reset behavior           | PASS  |
| UART RX reception                | PASS  |
| TX/RX loopback                   | PASS  |
| Functional coverage              | 100%  |

## Data Patterns

The following data patterns were verified:

- `0x00`
- `0x41`
- `0x55`
- `0xAA`
- `0xFF`

## Functional Coverage

All defined data-pattern coverage points were exercised successfully.

```text
0x00 coverage = 1
0xFF coverage = 1
0x55 coverage = 1
0xAA coverage = 1
0x41 coverage = 1

FUNCTIONAL COVERAGE = 100%