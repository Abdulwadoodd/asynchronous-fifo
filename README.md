# asynchronous-fifo
Modules with brief explaination are given below.

## rptr_ctrl
This module implements the logic to:
- Generate the read address to the FIFO memory.
- Generate Gray-scale encoded read pointer for comparison in write domain.
- Generate the FIFO empty status by comparing the gray-scale encoded read and write pointers.

## wptr_ctrl
This module implements the logic to:
- Generate the write enable signal and the write address to the FIFO memory.
- Generate the Gray-scale encoded write pointer for comparison in read domain.
- Generate the FIFO full status by comparing the gray-scale encoded read and write pointers.

> An extra MSB is added to read and write pointers to check the FIFO full condition. That single bit reduces the overhead of additional subtractor, gra-scale decoder and the comparator. 

## sync
This module implements the logic the synchronize the read pointer in write domain and vice versa.

## fifo_mem
This module contains the dual port memory buffer to store the data.

## async_fifo
All the previous modules are instantiated in this module. It also instantiates an extra module `PLLE2_BASE` from 7 series FPGA clock resources, to generate the read and write domain clocks of desired frequency, ofcourse, bounded the clk frequency range of the FPGA and the VCO of PLL.
