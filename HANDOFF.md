# Handoff: Talha to Waseem

## Already Complete

Talha's core branch contains:

- Fetch-decode-execute loop
- `ADD`, `SUB`, and `HALT`
- `VirtualAccumulator`
- `VirtualBaseRegister`
- `VirtualInstructionPointer`
- Bytecode array and basic console output

The core program currently uses:

```text
10h 05h 20h 02h FFh
```

The verified result should be:

```text
Accumulator: 3
Base Register: 2
Instruction Pointer: 5
HALT reached
```

## Waseem's Assigned Scope

Implement and test only the following first:

1. **JMP control flow**
   - Add a `JMP` opcode and handler.
   - Make it set `VirtualInstructionPointer` to a valid bytecode offset.
   - Reject out-of-range offsets safely.

2. **JE control flow**
   - Add a zero-status byte or register for comparison.
   - Add a `JE` opcode and handler.
   - Jump only when the condition is true.

3. **Live diagnostic tracer**
   - Print virtual Accumulator, Base Register, and instruction pointer after each cycle.
   - Do not alter register values while tracing.

4. **Testing**
   - Test one normal ADD/SUB/HALT program.
   - Test JMP skipping an instruction.
   - Test JE both taken and not taken.
   - Capture one clean screenshot for each working feature.

## Source Boundaries

Preserve these names and interfaces unless Talha and Waseem deliberately agree to change them:

- `Bytecode`
- `VirtualAccumulator`
- `VirtualBaseRegister`
- `VirtualInstructionPointer`
- `FetchNext`
- `ExecuteADD`
- `ExecuteSUB`
- `FetchDecodeExecute`
- `main`

Waseem should place branch and tracer procedures after `ExecuteSUB`, and add only the decoder branches needed in `FetchDecodeExecute`.

## Git Workflow

Before starting:

```bash
git pull origin main
git switch -c waseem/extensions
```

After one completed, tested feature:

```bash
git add src/MicroVM.asm
git commit -m "Add JMP and JE control flow"
git push origin waseem/extensions
```

After tracer and screenshots are ready:

```bash
git add src/MicroVM.asm screenshots/
git commit -m "Add live diagnostic tracer"
git push origin waseem/extensions
```

## Final Merge

1. Open a Pull Request from `waseem/extensions` into `main`.
2. Talha reviews and pulls the branch.
3. Both members build and test the exact merged source in Visual Studio.
4. If anything fails, fix it on the branch and push another commit.
5. Merge only after the combined build works.

Do not include Visual Studio output folders, `.suo`, `.obj`, `.exe`, `.pdb`, or `.vs` files.
