bits 64
default rel ; make NASM emit PC-relative addressing
extern read, strchr, printf ; dependencies from libc

; params: rdi, rsi, rdx, rcx, r8, r9, stack (rax for number of vector varargs)
; preserve: rbx, rsp, rbp, r12, r13, r14, r15
; free use: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11
; return: rax (higher bits in rdx)

section .text
global main
main: ; for C runtime
	push rbx ; buffer
	push rbp ; width incl. LF
	push r12 ; height
	push r13 ; y index
	push r14 ; x index
	push r15 ; sums
	sub rsp, 8
	lea rbx, [buffer]
	xor r15d, r15d

	xor edi, edi ; STDIN_FILENO
	mov rsi, rbx
	mov edx, buffersize
	call read wrt ..plt
	mov r12d, eax ; input size

	mov rdi, rbx
	mov esi, `\n`
	call strchr wrt ..plt
	sub rax, rbx
	lea ebp, [eax+1] ; width incl. LF
	xor edx, edx
	mov eax, r12d
	div ebp
	mov r12d, eax ; height

	xor r13d, r13d
.yloop:
	lea r14d, [rbp-2]
.xloop:
	mov eax, r13d
	mul ebp
	add eax, r14d
	movzx ecx, byte [rbx+rax]
	sub ecx, '0'
	jnz .xcontinue
	mov edi, r14d
	mov esi, r13d
	call score_and_rate
	movq xmm0, rax ; move integers into lower half of vector
	movq xmm1, r15 ; zeros upper half
	paddd xmm0, xmm1 ; ADD Packed Doublewords
	movq r15, xmm0
.xcontinue:
	sub r14d, 1
	jge .xloop
	inc r13d
	cmp r13d, r12d
	jl .yloop

	lea rdi, [fmtstring]
	mov esi, r15d
	shr r15, 32
	mov edx, r15d
	xor eax, eax
	call printf wrt ..plt

	xor eax, eax
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
	ret

; struct { int part1, part2; } score_and_rate(int x, int y)
static score_and_rate
score_and_rate:
	; TODO
	xor eax, eax
	ret

section .rodata
fmtstring: db `Part 1: %d\nPart 2: %d\n\0`

section .bss
buffer: resb 4000 ; reserve 4000 bytes
buffersize: equ $-buffer
