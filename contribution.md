
# Individual Contribution Summary

## Contributor
Muhammad Waseem Akram

## Project
Software CPU Emulator (Micro-VM)

## Contributions

### 1. JMP Instruction
- Implemented unconditional jump functionality.
- Added jump destination handling.
- Added validation for jump destinations.

### 2. Conditional Jump Instructions
- Implemented JE (Jump if Equal).
- Implemented JNE (Jump if Not Equal).
- Used the virtual Zero Flag to control conditional branching.

### 3. Virtual CPU Diagnostics
- Implemented a live diagnostic tracer.
- Displayed the virtual accumulator.
- Displayed the virtual base register.
- Displayed the virtual instruction pointer.
- Displayed the virtual Zero Flag.

### 4. Error Handling
- Added invalid opcode detection.
- Added missing operand detection.
- Added invalid jump target handling.
- Added missing HALT detection.

## Testing
- Tested arithmetic instruction execution.
- Tested unconditional and conditional branching.
- Tested jump destination validation.
- Tested error handling scenarios.

## Notes
All features listed above are subject to final integration and testing.
