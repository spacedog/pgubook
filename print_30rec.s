.include "linux.s"
.include "record-def.s"

.section .data

record1:
  .ascii "Frederick\0"
  .rept 31 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "Bartlett\0"
  .rept 31 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "4242 S Prairie\nTulsa, OK 55555\0"
  .rept 209 #padding to 240 bytes
  .byte 0
  .endr

  .ascii "rb@gmail.com\0"
  .rept 29
  .byte 0
  .endr

  .quad 45

file_name:
  .ascii "30records.txt\0"

.section .text
  .equ ST_FD_IN, -WORD_SIZE

.globl _start
_start:
  movq %rsp, %rbp
  pushq %rbp

  subq $WORD_SIZE, %rsp

  # Open file
  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  movq $0101, %rsi
  movq $0666, %rdx
  syscall

  movq %rax, ST_FD_IN(%rbp)

  movq $30, %rbx
  loop_begin:

    cmpq $0, %rbx
    je loop_end

    movq $SYS_WRITE, %rax
    movq ST_FD_IN(%rbp), %rdi
    movq $record1, %rsi
    movq $RECORD_SIZE, %rdx
    syscall

    decq %rbx
    jmp loop_begin

  loop_end:
    movq $SYS_CLOSE, %rax
    movq ST_FD_IN(%rbp), %rdi
    syscall

    addq $WORD_SIZE, %rsp

    movq $SYS_EXIT, %rax
    movq $0, %rdi
    syscall
