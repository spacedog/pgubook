.section .data
.section .text
.globl _start
_start:
  pushq $2            # Given number

  call square         # Call square function

  addq $8, %rsp       # Restore stack

  movq %rax, %rbx     # Move return value to %rbx
  movq $1, %rax       # Execute exit() system call
  int $0x80           # Interupt
