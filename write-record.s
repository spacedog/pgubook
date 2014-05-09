.include "linux.s"
.include "record-def.s"

#PURPOSE:   This function writes a record to
#           a given fiel descriptor
#
#INPUT:     The file descriptor and a buffer
#
#OUTPUT:    This function produces a status code

#
## Constants
#
.equ ST_WRITE_BUFFER, 2*WORD_SIZE
.equ ST_FD_OUT, 3*WORD_SIZE

.section .text
.globl write_record
.type write_record, @function

write_record:
  pushq %rbp
  movq %rsp, %rbp

  movq $SYS_WRITE, %rax
  movq ST_FD_OUT(%rbp), %rdi
  movq ST_WRITE_BUFFER(%rbp), %rsi
  movq $RECORD_SIZE, %rdx
  syscall

  movq %rbp, %rsp
  popq %rbp
  ret
