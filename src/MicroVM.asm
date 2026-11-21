
; Software CPU Emulator (Micro-VM)
; EL-2003 COAL Lab, FAST-NUCES Karachi
; Group 4 - BCS-3E

.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc

.data

Bytecode BYTE 10h, 5, 30h, 8, 20h, 2, 40h, 10, 10h, 3, 0FFh
BytecodeLength DWORD ($ - Bytecode)

VirtualAccumulator DWORD 0
VirtualBaseRegister DWORD 0
VirtualInstructionPointer DWORD 0
VirtualZeroFlag BYTE 1

JumpTarget DWORD 0
InvalidOpcodeValue DWORD 0

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

OP_ADD EQU 10h
OP_SUB EQU 20h
OP_JMP EQU 30h
OP_JE EQU 40h
OP_HALT EQU 0FFh

.code

; --------------------------------
; FETCH NEXT BYTE
; --------------------------------

FetchNext PROC

    mov al, [esi]
    inc esi
    ret

FetchNext ENDP


; --------------------------------
; EXECUTE ADD
; --------------------------------

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


; --------------------------------
; EXECUTE SUB
; --------------------------------

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


; --------------------------------
; VALIDATE JUMP TARGET
; Target must be an instruction boundary.
; --------------------------------

ValidateTarget PROC

    push ebx
    push ecx
    push edx
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

    movzx edx, BYTE PTR [Bytecode+edi]

    cmp dl, OP_HALT
    je InvalidTarget

    cmp dl, OP_ADD
    je TwoByteInstruction

    cmp dl, OP_SUB
    je TwoByteInstruction

    cmp dl, OP_JMP
    je TwoByteInstruction

    cmp dl, OP_JE
    je TwoByteInstruction

    jmp InvalidTarget

TwoByteInstruction:

    mov ecx, edi
    inc ecx

    cmp ecx, BytecodeLength
    jae InvalidTarget

    add edi, 2
    jmp ValidateLoop

ValidTarget:

    mov eax, 1
    jmp ValidationDone

InvalidTarget:

    mov eax, 0

ValidationDone:

    pop edi
    pop edx
    pop ecx
    pop ebx

    ret

ValidateTarget ENDP


; --------------------------------
; LIVE DIAGNOSTIC TRACER
; --------------------------------

TraceState PROC

    pushad

    mov edx, AccumulatorText
    call WriteString

    mov eax, VirtualAccumulator
    call WriteDec
    call Crlf

    mov edx, BaseText
    call WriteString

    mov eax, VirtualBaseRegister
    call WriteDec
    call Crlf

    mov edx, InstructionText
    call WriteString

    mov eax, VirtualInstructionPointer
    call WriteDec
    call Crlf

    mov edx, ZeroFlagText
    call WriteString

    movzx eax, BYTE PTR VirtualZeroFlag
    call WriteDec
    call Crlf
    call Crlf

    popad
    ret

TraceState ENDP


; --------------------------------
; MAIN PROGRAM
; --------------------------------

main PROC

    call Clrscr

    mov edx, OFFSET TitleText
    call WriteString
    call Crlf

    mov edx, OFFSET RunningText
    call WriteString
    call Crlf
    call Crlf

    mov esi, OFFSET Bytecode

    mov VirtualAccumulator, 0
    mov VirtualBaseRegister, 0
    mov VirtualInstructionPointer, 0
    mov VirtualZeroFlag, 1

; --------------------------------
; FETCH-DECODE-EXECUTE LOOP
; --------------------------------

FetchDecodeExecute:

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


; --------------------------------
; HANDLE ADD
; --------------------------------

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


; --------------------------------
; HANDLE SUB
; --------------------------------

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


; --------------------------------
; HANDLE JMP
; --------------------------------

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


; --------------------------------
; HANDLE JE
; --------------------------------

HandleJE:

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

    cmp VirtualZeroFlag, 1
    jne JENotTaken

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


; --------------------------------
; HANDLE HALT
; --------------------------------

HandleHalt:

    mov eax, esi
    sub eax, OFFSET Bytecode

    mov VirtualInstructionPointer, eax

    call TraceState

    jmp ProgramComplete


; --------------------------------
; ERROR HANDLERS
; --------------------------------

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


; --------------------------------
; PROGRAM COMPLETE
; --------------------------------

ProgramComplete:

    mov edx, OFFSET HaltedText
    call WriteString
    call Crlf

    exit

main ENDP

END main
