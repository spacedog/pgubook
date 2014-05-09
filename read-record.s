.include "record-def.s"
.include "linux.s"

#PURPOSE:         That function reads a record from the file
#                 descriptor
#
#INPUT:           The file descriptor and a buffer
#
#OUTPUT:          Writes the data to the buffer and
#                 returns a status code.
#

#
## Constants
#

## Args

.equ ST_READ_BUFFER, 2*WORD_SIZE
.equ ST_FD_IN,     3*WORD_SIZE

.section .text

.globl read_record
.type read_record, @function

read_record:
  pushq %rbp,
  movq %rsp, %rbp

  movq ST_FD_IN(%rbp) , %rdi
  movq ST_READ_BUFFER(%rbp), %rsi
  movq $RECORD_SIZE, %rdx
  movq $SYS_READ, %rax
  syscall

  movq %rbp, %rsp
  popq %rbp
  ret
