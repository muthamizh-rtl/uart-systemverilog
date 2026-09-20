# UART Controller - SystemVerilog

## Overview

A configurable UART controller implemented in SystemVerilog RTL for reliable asynchronous serial communication.

The design is developed with a modular architecture and a verification-driven approach, with emphasis on timing accuracy, deterministic control, and reusable RTL.

## UART Specification

| Parameter | Value |
|---|---|
| Data bits | 8 |
| Baud rate | 9600 |
| Clock frequency | 50 MHz |
| Start bits | 1 |
| Stop bits | 1 |
| Parity | None |
| Data order | LSB first |

## Architecture

The UART design is organized into independent transmitter and receiver blocks.

```text
                 UART Controller
                       |
              +--------+--------+
              |                 |
          UART TX            UART RX
              |                 |
          Serial TX         Serial RX
        