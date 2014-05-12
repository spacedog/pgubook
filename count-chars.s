.include "linux.s"
#PURPOSE:   Count the characters until a null byte us reached
#
#INPUT:     Ths address of the character string
#
#OUTPUT:    Returns the count tn %rax
#
#PROCESS:
#   Registers used:
#     %rcs - character count
#     %al  - current character
#     %edx - current character address

.type count_chars, @function
.globl count_chars

.equ ST_STRING_START_ADDR, 2*WORD_SIZE # ARG1

count_chars:
  push %rbp
  movq %rsp, %rbp

  movq $0, %rcx
  movq ST_STRING_START_ADDR(%rbp), %rdx

  count_loop_begin:
    movb (%rdx), %al

    cmpb $0, %al
    je count_loop_end
    incq %rcx
    incq %rdx
    jmp count_loop_begin

  count_loop_end:
    movq %rcx, %rax
    popq %rbp
    ret

