.include "linux.s"
.include "record-def.s"

.section .data

file_name:
.ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text

.globl _start

_start:
  .equ ST_INPUT_FD, -WORD_SIZE
  .equ ST_OUTPUT_FD, -2*WORD_SIZE

  movq %rsp, %rbp

  subq $16, %rsp

  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  movq $0, %rsi
  movq $0666, %rdx
  syscall

  movq %rax, ST_INPUT_FD(%rbp)

  movq $STDOUT, ST_OUTPUT_FD(%rbp)

  record_read_loop:
    pushq ST_INPUT_FD(%rbp)
    pushq $record_buffer
    call read_record
    addq $16, %rsp

    cmpq $RECORD_SIZE, %rax
    jne finished_reading
    
    pushq $RECORD_FIRSTNAME + record_buffer
    call count_chars
    addq $8, %rsp

    movq %rax, %rdx
    movq ST_OUTPUT_FD(%rbp), %rdi
    movq $SYS_WRITE, %rax
    movq $RECORD_FIRSTNAME + record_buffer, %rsi
    syscall

    pushq ST_OUTPUT_FD(%rbp)
    call write_newline
    addq $8, %rsp

    jmp record_read_loop

  finished_reading:
    movq $SYS_EXIT, %rax
    movq $0, %rdi
    syscall
