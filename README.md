# Software CPU Emulator (Micro-VM)

EL-2003 Computer Organization and Assembly Language Lab  
FAST-NUCES Karachi, Fall 2026  
Group 4, BCS-3E

## Project

A console-based virtual CPU implemented in x86 assembly using MASM and the Irvine32 library. The emulator executes custom bytecode through a fetch-decode-execute cycle with virtual Accumulator, Base Register, Instruction Pointer, and Zero Flag values.

## Features

- ADD, SUB, and HALT instructions
- JMP, JE, and JNE control flow
- Live virtual CPU state tracing
- Invalid opcode, operand, target, missing-HALT, and cycle-limit handling
- Step, run, and quit execution controls
- Execution trace export to `MicroVM_trace.bin`

## Source

The complete assembly source is in `src/MicroVM.asm`.

## Build

1. Create an x86 Visual Studio console project.
2. Configure MASM and the Irvine32 library.
3. Add `src/MicroVM.asm`.
4. Set `main` as the entry procedure.
5. Build and run the project in Windows.

## Repository Contents

- `src/MicroVM.asm`
- `README.md`
- `.gitignore`
