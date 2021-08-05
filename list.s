.intel_syntax noprefix

.include "list.macro"

.section .data

sun: .double 2.0
jupiter: .double 4.0
neptune: .double 6.0
uranus: .double 8.0



permutations sun, jupiter, neptune, uranus

.section .text
.global main
main:
  mov rdi, 0
  call exit
