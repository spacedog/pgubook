.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
#
## Constants
#
.equ ST_FD_IN, -WORD_SIZE
.equ ST_MAX_AGE, -2*WORD_SIZE

.globl _start
_start:
  movq %rsp, %rbp
  push %rbp

  subq $16, %rsp

  movq $0, ST_MAX_AGE(%rbp)

  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  movq $0, %rsi
  movq $0666, %rdx
  syscall

  movq %rax, ST_FD_IN(%rbp)

  movq $SYS_READ, %rax
  movq ST_FD_IN(%rbp), %rdi
  movq $record_buffer, %rsi
  movq $RECORD_SIZE, %rdx
  syscall

  cmpq $RECORD_SIZE, %rax
  jne loop_end

  movb RECORD_AGE + record_buffer, %al
  movq %al, ST_MAX_AGE(%rbp)

  loop_begin:
    movq $SYS_READ, %rax
    movq ST_FD_IN(%rbp), %rdi
    movq $record_buffer, %rsi
    movq $RECORD_SIZE, %rdx
    syscall

    cmpq $RECORD_SIZE, %rax
    jne loop_end

    movb RECORD_AGE + record_buffer, %al
    cmpb ST_MAX_AGE(%rbp), %al
    jle loop_begin

    movb %al, ST_MAX_AGE(%rbp)
    jmp loop_begin

  loop_end:
    movq $SYS_EXIT, %rax
    movq ST_MAX_AGE(%rbp), %rdi
    syscall
