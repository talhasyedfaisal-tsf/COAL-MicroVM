
; Software CPU Emulator (Micro-VM)
; EL-2003 COAL Lab, FAST-NUCES Karachi
; Group 4 - BCS-3E

.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc

.data

Bytecode BYTE 10h, 5, 20h, 5, 40h, 8, 10h, 99, 10h, 3, 50h, 14, 10h, 88, 20h, 3, 50h, 20, 10h, 2, 40h, 24, 30h, 24, 0FFh
BytecodeLength DWORD ($ - Bytecode)

VirtualAccumulator DWORD 0
VirtualBaseRegister DWORD 0
VirtualInstructionPointer DWORD 0
VirtualZeroFlag BYTE 1

JumpTarget DWORD 0
InvalidOpcodeValue DWORD 0
CycleCount DWORD 0
CycleLimit DWORD 1000
StepMode BYTE 0
TraceFileHandle DWORD 0
TraceBuffer DWORD 0, 0, 0, 0

TitleText BYTE "Software CPU Emulator (Micro-VM)", 0
RunningText BYTE "Execution started", 0

AccumulatorText BYTE "Accumulator: ", 0
BaseText BYTE "Base Register: ", 0
InstructionText BYTE "Instruction Pointer: ", 0
ZeroFlagText BYTE "Zero Flag: ", 0

HaltedText BYTE "HALT reached", 0
InvalidText BYTE "Invalid opcode: ", 0
InvalidTargetText BYTE "Invalid jump target: ", 0
MissingOperandText BYTE "Error: Missing operand.", 0
MissingHaltText BYTE "Error: Program ended without HALT.", 0
CycleLimitText BYTE "Error: Execution cycle limit reached.", 0
ModeText BYTE "Execution mode: 1 = Auto, 2 = Step: ", 0
StepText BYTE "Press S for step, R for run, or Q for quit.", 0
TraceFileName BYTE "MicroVM_trace.bin", 0
TraceSavedText BYTE "Execution trace saved to MicroVM_trace.bin", 0

OP_ADD EQU 10h
OP_SUB EQU 20h
OP_JMP EQU 30h
OP_JE EQU 40h
OP_JNE EQU 50h
OP_HALT EQU 0FFh

.code

FetchNext PROC
    mov al, [esi]
    inc esi
    ret
FetchNext ENDP


ExecuteADD PROC
    push ebx

    movzx ebx, al
    add VirtualAccumulator, ebx
    mov VirtualBaseRegister, ebx

    cmp VirtualAccumulator, 0
    sete BYTE PTR VirtualZeroFlag

    pop ebx
    ret
ExecuteADD ENDP


ExecuteSUB PROC
    push ebx

    movzx ebx, al
    sub VirtualAccumulator, ebx
    mov VirtualBaseRegister, ebx

    cmp VirtualAccumulator, 0
    sete BYTE PTR VirtualZeroFlag

    pop ebx
    ret
ExecuteSUB ENDP


ValidateTarget PROC
    push ebx
    push edi

    mov ebx, JumpTarget

    cmp ebx, BytecodeLength
    jae InvalidTarget

    xor edi, edi

ValidateLoop:
    cmp edi, ebx
    je ValidTarget

    ja InvalidTarget

    cmp edi, BytecodeLength
    jae InvalidTarget

    movzx eax, BYTE PTR [Bytecode+edi]

    cmp al, OP_ADD
    je TargetTwoByte
    cmp al, OP_SUB
    je TargetTwoByte
    cmp al, OP_JMP
    je TargetTwoByte
    cmp al, OP_JE
    je TargetTwoByte
    cmp al, OP_JNE
    je TargetTwoByte

    cmp al, OP_HALT
    je TargetOneByte

    jmp InvalidTarget

TargetTwoByte:
    add edi, 2
    jmp ValidateLoop

TargetOneByte:
    inc edi
    jmp ValidateLoop

ValidTarget:
    mov eax, 1
    jmp ValidationDone

InvalidTarget:
    mov eax, 0

ValidationDone:
    pop edi
    pop ebx
    ret
ValidateTarget ENDP


TraceState PROC
    pushad

    inc CycleCount

    mov edx, OFFSET AccumulatorText
    call WriteString
    mov eax, VirtualAccumulator
    call WriteDec
    call Crlf

    mov edx, OFFSET BaseText
    call WriteString
    mov eax, VirtualBaseRegister
    call WriteDec
    call Crlf

    mov edx, OFFSET InstructionText
    call WriteString
    mov eax, VirtualInstructionPointer
    call WriteDec
    call Crlf

    mov edx, OFFSET ZeroFlagText
    call WriteString
    movzx eax, BYTE PTR VirtualZeroFlag
    call WriteDec
    call Crlf
    call Crlf

    cmp StepMode, 0
    je TraceDone
StepWait:
    mov edx, OFFSET StepText
    call WriteString
    call Crlf
    call ReadChar
    and al, 0DFh
    cmp al, 'S'
    je TraceDone
    cmp al, 'R'
    je RunFromStep
    cmp al, 'Q'
    jne StepWait
    popad
    exit
RunFromStep:
    mov StepMode, 0
TraceDone:
    popad
    ret
TraceState ENDP


SaveTrace PROC
    mov eax, VirtualAccumulator
    mov TraceBuffer, eax
    mov eax, VirtualBaseRegister
    mov [TraceBuffer+4], eax
    mov eax, VirtualInstructionPointer
    mov [TraceBuffer+8], eax
    movzx eax, BYTE PTR VirtualZeroFlag
    mov [TraceBuffer+12], eax

    mov edx, OFFSET TraceFileName
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je TraceSaveDone

    mov TraceFileHandle, eax
    mov edx, OFFSET TraceBuffer
    mov ecx, 16
    mov eax, TraceFileHandle
    call WriteToFile

    mov eax, TraceFileHandle
    call CloseFile

    mov edx, OFFSET TraceSavedText
    call WriteString
    call Crlf
TraceSaveDone:
    ret
SaveTrace ENDP

main PROC
    call Clrscr

    mov edx, OFFSET TitleText
    call WriteString
    call Crlf

    mov edx, OFFSET RunningText
    call WriteString
    call Crlf

    mov edx, OFFSET ModeText
    call WriteString
    call ReadInt
    mov StepMode, 0
    cmp eax, 2
    jne StartExecution
    mov StepMode, 1
StartExecution:
    call Crlf

    mov esi, OFFSET Bytecode

    mov VirtualAccumulator, 0
    mov VirtualBaseRegister, 0
    mov VirtualInstructionPointer, 0
    mov VirtualZeroFlag, 1
    mov CycleCount, 0


FetchDecodeExecute:
    mov eax, CycleCount
    cmp eax, CycleLimit
    jae CycleLimitReached

    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingHalt

    call FetchNext

    cmp al, OP_ADD
    je HandleAdd

    cmp al, OP_SUB
    je HandleSub

    cmp al, OP_JMP
    je HandleJmp

    cmp al, OP_JE
    je HandleJE

    cmp al, OP_JNE
    je HandleJNE

    cmp al, OP_HALT
    je HandleHalt

    movzx eax, al
    mov InvalidOpcodeValue, eax

    mov edx, OFFSET InvalidText
    call WriteString

    mov eax, InvalidOpcodeValue
    call WriteDec
    call Crlf

    exit


HandleAdd:
    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingOperand

    call FetchNext
    call ExecuteADD

    mov eax, esi
    sub eax, OFFSET Bytecode
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


HandleSub:
    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingOperand

    call FetchNext
    call ExecuteSUB

    mov eax, esi
    sub eax, OFFSET Bytecode
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


HandleJmp:
    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingOperand

    call FetchNext

    movzx eax, al
    mov JumpTarget, eax

    call ValidateTarget

    cmp eax, 1
    jne InvalidJump

    mov esi, OFFSET Bytecode
    add esi, JumpTarget

    mov eax, JumpTarget
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


HandleJE:
    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingOperand

    call FetchNext

    movzx eax, al
    mov JumpTarget, eax

    cmp VirtualZeroFlag, 1
    jne JENotTaken

    call ValidateTarget

    cmp eax, 1
    jne InvalidJump

    mov esi, OFFSET Bytecode
    add esi, JumpTarget

    mov eax, JumpTarget
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


JENotTaken:
    mov eax, esi
    sub eax, OFFSET Bytecode
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


HandleJNE:
    mov eax, esi
    sub eax, OFFSET Bytecode

    cmp eax, BytecodeLength
    jae MissingOperand

    call FetchNext

    movzx eax, al
    mov JumpTarget, eax

    cmp VirtualZeroFlag, 0
    je JNETaken

    mov eax, esi
    sub eax, OFFSET Bytecode
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


JNETaken:
    call ValidateTarget

    cmp eax, 1
    jne InvalidJump

    mov esi, OFFSET Bytecode
    add esi, JumpTarget

    mov eax, JumpTarget
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp FetchDecodeExecute


HandleHalt:
    mov eax, esi
    sub eax, OFFSET Bytecode
    mov VirtualInstructionPointer, eax

    call TraceState
    jmp ProgramComplete


InvalidJump:
    mov edx, OFFSET InvalidTargetText
    call WriteString

    mov eax, JumpTarget
    call WriteDec
    call Crlf

    exit


MissingOperand:
    mov edx, OFFSET MissingOperandText
    call WriteString
    call Crlf

    exit


MissingHalt:
    mov edx, OFFSET MissingHaltText
    call WriteString
    call Crlf

    exit


CycleLimitReached:
    mov edx, OFFSET CycleLimitText
    call WriteString
    call Crlf

    exit


ProgramComplete:
    mov edx, OFFSET HaltedText
    call WriteString
    call Crlf

    mov edx, OFFSET AccumulatorText
    call WriteString
    mov eax, VirtualAccumulator
    call WriteDec
    call Crlf

    mov edx, OFFSET BaseText
    call WriteString
    mov eax, VirtualBaseRegister
    call WriteDec
    call Crlf

    mov edx, OFFSET InstructionText
    call WriteString
    mov eax, VirtualInstructionPointer
    call WriteDec
    call Crlf

    mov edx, OFFSET ZeroFlagText
    call WriteString
    movzx eax, BYTE PTR VirtualZeroFlag
    call WriteDec
    call Crlf

    call SaveTrace

    exit

main ENDP

END main
