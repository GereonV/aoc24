bits 64
default rel ; make NASM emit PC-relative addressing
extern read, strchr, memset, printf ; dependencies from libc

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
	lea rdi, [endpoint]
	xor esi, esi
	mov edx, buffersize
	call memset wrt ..plt
	mov edi, r14d
	mov esi, r13d
	mov edx, ebp
	mov ecx, r12d
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

; struct { int part1, part2; } score_and_rate(int x, int y, int width, int height)
static score_and_rate
score_and_rate:
	push rbx ; index in arrays
	mov eax, esi
	imul eax, edx ; unsigned but we want to keep edx
	lea ebx, [edi+eax] ; index in arrays
	lea r8, [buffer]
	cmp byte [r8+rbx], '9'
	jne .search
	lea r8, [endpoint]
	movzx eax, byte [r8+rbx]
	mov byte [r8+rbx], 1
	mov rbx, 1<<32|1 ; refunction as constant
	xor rax, rbx
	pop rbx
	ret
.search:
	push rbp ; current pointer in offset table
	push r12 ; end pointer of offset table
	push r13 ; x
	push r14 ; y
	push r15 ; accumulator
	sub rsp, 8
	lea rbp, [offsets]
	lea r12, [offsets_end]
	mov r13d, edi
	mov r14d, esi
	xor r15d, r15d
.offsetloop:
	; careful!!! signed 32bit values
	mov edi, r13d ; x
	mov esi, r14d ; y
	add edi, [rbp] ; + x offset
	add esi, [rbp+4] ; + y offset
	cmp edi, 0
	jl .continue
	cmp esi, 0
	jl .continue
	lea r9d, [edx-1]
	cmp edi, r9d
	jge .continue
	cmp esi, ecx
	jge .continue
	mov r9d, edx
	imul r9d, [rbp+4] ; index delta caused by y
	add r9d, [rbp] ; index delta caused by x
	add r9d, ebx ; index
	lea r8, [buffer]
	mov al, byte [r8+r9] ; offset value
	sub al, byte [r8+rbx] ; - current value
	movzx eax, al
	cmp eax, 1
	jne .continue
	call score_and_rate
	movq xmm0, rax
	movq xmm1, r15
	paddd xmm0, xmm1
	movq r15, xmm0
.continue:
	add rbp, 8 ; advance by two ints
	cmp rbp, r12
	jne .offsetloop
	mov rax, r15
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
	ret

section .rodata
fmtstring: db `Part 1: %d\nPart 2: %d\n\0`
offsets:
	dd  1,  0
	dd -1,  0
	dd  0,  1
	dd  0, -1
offsets_end:

section .bss
buffer: resb 4000 ; reserve 4000 bytes
buffersize: equ $-buffer
endpoint: resb buffersize ; way easier this way, but could theoretically be compacted by factor 8
