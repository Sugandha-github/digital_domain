# Asynchronous FIFO

A parameterizable asynchronous FIFO (dual-clock FIFO) for safely transferring data between two independent clock domains, using gray-code pointer synchronization to avoid metastability.

## Features

- Independent read and write clock domains (`wr_clk`, `rd_clk`)
- Gray-coded read/write pointers with two-flop synchronizers for safe CDC
- Configurable data width and FIFO depth
- Full and empty flag generation
- Optional almost-full / almost-empty flags
- Synchronous active-low (or active-high) reset per domain

## Parameters

| Parameter    | Description                                   | Default |
|--------------|-----------------------------------------------|---------|
| `DATA_WIDTH` | Width of each data word                       | 32      |
| `ADDR_WIDTH` | Address width; FIFO depth = 2^ADDR_WIDTH - 1  | 6       |

## Port List

| Port          | Direction | Width          | Clock Domain | Description                     |
|---------------|-----------|----------------|--------------|----------------------------------|
| `wr_clk`      | input     | 1              | Write        | Write domain clock              |
| `wr_rst_n`    | input     | 1              | Write        | Write domain reset (active-low) |
| `wr_en`       | input     | 1              | Write        | Write enable                    |
| `wr_data`     | input     | `DATA_WIDTH`   | Write        | Data to write                   |
| `full`        | output    | 1              | Write        | FIFO full flag                  |
| `rd_clk`      | input     | 1              | Read         | Read domain clock               |
| `rd_rst_n`    | input     | 1              | Read         | Read domain reset (active-low)  |
| `rd_en`       | input     | 1              | Read         | Read enable                     |
| `rd_data`     | output    | `DATA_WIDTH`   | Read         | Data read out                   |
| `empty`       | output    | 1              | Read         | FIFO empty flag                 |

## Design Overview

- **Memory array:** Dual-port RAM, written on `wr_clk` and read on `rd_clk`.
- **Pointers:** Binary write/read pointers are converted to gray code before crossing clock domains, then synchronized with two-flop synchronizers on the opposite domain.
- **Full/Empty logic:** `full` is generated in the write domain by comparing the write pointer to the synchronized (gray) read pointer; `empty` is generated in the read domain by comparing the read pointer to the synchronized (gray) write pointer.
- **Reset:** Each domain resets its own pointers independently; reset should be asserted asynchronously and deasserted synchronously to its respective clock.

## Directory Structure

```
.
├── rtl/
│   └── a_fifo_top.v          # FIFO RTL
├── tb/
│   └── tb_a_fifo_top.sv      # Testbench 
└── README.md
└── Block Diagram of FIFO
└── Simulation Waveform
```
