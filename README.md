# Software CPU Emulator (Micro-VM)

EL-2003 COAL Lab, FAST-NUCES Karachi  
Group 4, BCS-3E

## Group

- Talha Syed Faisal (25K-0614), group leader
- Muhammad Waseem Akram (25K-0655), member

## Core Features for Talha's Handoff

| Feature | Implementation |
|---|---|
| Fetch-decode-execute cycle | Instruction pointer, opcode fetch, decoder, and execution loop |
| ADD | Reads an operand and adds it to the virtual Accumulator |
| SUB | Reads an operand and subtracts it from the virtual Accumulator |
| HALT | Stops execution and prints the virtual CPU state |
| Console output | Prints Accumulator, Base Register, and instruction pointer |

Waseem will add the proposed control-flow and tracer extensions after this core is pushed and tested.

## Repository Layout

```text
MicroVM/
├── README.md
├── HANDOFF.md
├── .gitignore
└── src/
    └── MicroVM.asm
```

## Member Responsibilities

### Talha Syed Faisal

Owns the bytecode memory layout, virtual Accumulator and Base Register variables, instruction pointer, opcode fetch/decode loop, ADD, SUB, HALT, and final console output.

Do not overwrite or rename these core symbols when integrating an extension:

- `Bytecode`
- `VirtualAccumulator`
- `VirtualBaseRegister`
- `VirtualInstructionPointer`
- `FetchNext`
- `ExecuteADD`
- `ExecuteSUB`
- `FetchDecodeExecute`
- `main`

### Muhammad Waseem Akram

Add control flow and diagnostic tracing in separate, focused changes after the core loop is verified.

Before changing the core, Waseem should preserve:

- `ESI` pointing to the next bytecode position
- the `AL` convention used by `FetchNext`
- ADD/SUB handlers as calls to `ExecuteADD` and `ExecuteSUB`
- `main` as the entry label
- virtual register variables in the `.data` section

## Core Bytecode Format

The handoff program uses opcode/operand pairs:

```text
10h 05h 20h 02h FFh
```

This means:

```text
ADD 5
SUB 2
HALT
```

The starting Accumulator is 0, so the final result is 3.

## Build Instructions

This source is MASM/Irvine32 syntax for a Windows Visual Studio x86 console project.

1. Create a Visual Studio **Empty Project** or equivalent MASM project.
2. Set the target platform to **x86**.
3. Configure `.asm` as a **Microsoft Macro Assembler** item.
4. Add `src/MicroVM.asm` to the project.
5. Configure the Irvine32 include and library paths used in the lab environment.
6. Set `main` as the entry procedure.
7. Build and run the project.

The source has not been built on this macOS workspace because Visual Studio and an Irvine32 Windows runtime are not available here.

## Integration Notes for Waseem

Do not replace Talha's core implementation wholesale. Add extension opcodes and helpers beneath the reserved section and update only the decoder/loop branches required for them.

Suggested branch module interface:

- keep branch targets as bytecode offsets
- validate every target before changing `ESI`
- save and restore registers used by branching/tracing procedures
- use a separate tracer procedure that reads virtual registers without changing their values

## Submission Status

- Core assembly source is present for Visual Studio setup.
- Windows build and runtime verification are still required.
- ADD, SUB, and HALT must be tested before the handoff commit.
- Screenshots should come from the tested core build.
- Report text and source appendix must match the final submitted commit exactly.
