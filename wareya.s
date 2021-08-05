.intel_syntax noprefix
.global main

.section .data

format:
.asciz "%.016f\n"

sun:
.double 9999.9
scratch:
.double 0.0

.section .text

main:
  push rax /* align stack */

  push 0
  push offset sun
	
	sub rsp, 8
	mov al, 0
	lea rdi, [format]
	mov rsi, [scratch]
	call printf
	add rsp, 8
	
	pop rax
stop: /* expect offset sun here NOT zero */

	pop rdx
	add rax, qword ptr 80
	
	add rdx, qword ptr 1
	push rdx
	push rax

  mov rdi, 0
  call exit
