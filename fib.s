.intel_syntax noprefix

.include "std.macro"

  .section .text
fib: op1 = rdi; op2 = rsi; iterations = rcx
  xadd op2, op1
  loop fib 
  ret
  
  .global main
main:
  λ fib 1, 1, 100
  λ exit, 0
