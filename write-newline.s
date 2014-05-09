.include "linux.s"

.globl write_newline
.type write_newline, @function

# Data
.section .data
newline:
  .ascii "\n"

# Code
.section .text

#
## Constants
#
.equ ST_FD, 2*WORD_SIZE

write_newline:
  pushq %rbp
  movq %rsp, %rbp

  movq $SYS_WRITE, %rax
  movq ST_FD(%rbp), %rdi
  movq $newline, %rsi
  movq $1, %rdx
  syscall

  movq %rsp, %rbp
  popq %rbp
  ret

