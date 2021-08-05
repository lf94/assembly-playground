.intel_syntax noprefix

.section .rodata
hello_world: .asciz "Hello world"

.section .text
.global main
main:
  push rax
  mov rdi, offset hello_world
  mov al, 0
  call printf
  mov rdi, 0
  call exit
  ret
