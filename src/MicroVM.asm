; Software CPU Emulator (Micro-VM)
; EL-2003 COAL Lab, FAST-NUCES Karachi
; Core implementation - Talha Syed Faisal (25K-0614)

.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc

.data
Bytecode BYTE 10h, 5, 20h, 2, 0FFh
BytecodeLength DWORD ($ - Bytecode)

VirtualAccumulator DWORD 0
VirtualBaseRegister DWORD 0
VirtualInstructionPointer DWORD 0

TitleText         BYTE "Software CPU Emulator (Micro-VM)", 0
RunningText       BYTE "Execution started", 0
AccumulatorText   BYTE "Accumulator: ", 0
BaseText          BYTE "Base Register: ", 0
InstructionText   BYTE "Instruction Pointer: ", 0
HaltedText        BYTE "HALT reached", 0
InvalidText       BYTE "Invalid opcode: ", 0

OP_ADD  EQU 10h
OP_SUB  EQU 20h
OP_HALT EQU 0FFh

.code
FetchNext PROC
    mov al, [esi]
    inc esi
    ret
FetchNext ENDP

ExecuteADD PROC
    movzx ebx, al
    add VirtualAccumulator, ebx
    mov VirtualBaseRegister, ebx
    ret
ExecuteADD ENDP

ExecuteSUB PROC
    movzx ebx, al
    sub VirtualAccumulator, ebx
    mov VirtualBaseRegister, ebx
    ret
ExecuteSUB ENDP

main PROC
    call Clrscr

    mov edx, OFFSET TitleText
    call WriteString
    call Crlf
    mov edx, OFFSET RunningText
    call WriteString
    call Crlf

    mov esi, OFFSET Bytecode
    mov VirtualInstructionPointer, 0

FetchDecodeExecute:
    mov eax, esi
    sub eax, OFFSET Bytecode
    cmp eax, BytecodeLength
    jae ProgramComplete

    call FetchNext
    mov VirtualInstructionPointer, esi
    sub VirtualInstructionPointer, OFFSET Bytecode

    cmp al, OP_ADD
    je HandleAdd
    cmp al, OP_SUB
    je HandleSub
    cmp al, OP_HALT
    je HandleHalt

    mov edx, OFFSET InvalidText
    call WriteString
    movzx eax, al
    call WriteDec
    call Crlf
    jmp ProgramComplete

HandleAdd:
    mov eax, esi
    sub eax, OFFSET Bytecode
    cmp eax, BytecodeLength
    jae ProgramComplete

    call FetchNext
    call ExecuteADD
    jmp FetchDecodeExecute

HandleSub:
    mov eax, esi
    sub eax, OFFSET Bytecode
    cmp eax, BytecodeLength
    jae ProgramComplete

    call FetchNext
    call ExecuteSUB
    jmp FetchDecodeExecute

HandleHalt:
    jmp ProgramComplete

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

    exit
main ENDP
END main
