.intel_syntax noprefix

.include "std.macro"

SPACECODE         = 0x20
POSITIVE          = 0x2B
NEGATIVE          = 0x2D
ASCII_DIGIT_BEGIN = 0x30
ASCII_DIGIT_END   = 0x39

atoi: strPtr = rdi ; push esp
  charcode   = rsi ; mov charcode, 0
  beginpos   = rdx ; mov beginpos, 0
  numlen     = r8  ; mov numlen, 0
  signfactor = r9  ; mov signfactor, 0

  str_length = rcx
  fn str_len, strPtr ; → str_length

1: idx = r11 ; mov idx, 0
  fn char_code_at, strPtr, idx ; → charcode
  cmp signfactor, 0       ; je 1b
  cmp beginpos, 0         ; je 1b
  cmp charcode, SPACECODE ; je 1b

  cmp charcode, ASCII_DIGIT_BEGIN ; jge 2f
  cmp charcode, ASCII_DIGIT_END   ; jle 2f
  jmp check_negative_sign

found_number:
  cmp beginpos, 0 ; jne 2f
  mov beginpos, idx
2:
  inc numlen
  
check_negative_sign:
check_positive_sign:


  loop 1b
  pop esp; ret
  
