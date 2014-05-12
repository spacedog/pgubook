.include "linux.s"
.include "record-def.s"


.section .data
input_file_name:
  .ascii "test.dat\0"

output_file_name:
  .ascii "testout.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.equ ST_FD_INPUT, -WORD_SIZE
.equ ST_FD_OUTPUT, -2*WORD_SIZE

.section .text
.globl _start
_start:
  movq %rsp, %rbp
  subq $16, %rsp

  # Open test.dat
  movq $SYS_OPEN, %rax
  movq $input_file_name, %rdi
  movq $0, %rsi
  movq $0x666, %rdx
  syscall

  movq %rax, ST_FD_INPUT(%rbp)

  # Open testout.dat
  movq $SYS_OPEN, %rax
  movq $output_file_name, %rdi
  movq $0101, %rsi
  movq $0x666, %rdx
  syscall

  movq %rax, ST_FD_OUTPUT(%rbp)

  loop_begin:
    pushq ST_FD_INPUT(%rbp)
    pushq $record_buffer
    call read_record

    addq $16,  %rsp

    cmpq $RECORD_SIZE, %rax
    jne loop_end

    incq record_buffer + RECORD_AGE

    pushq ST_FD_OUTPUT(%rbp)
    pushq $record_buffer
    call write_record

    addq $16, %rsp

    jmp loop_begin
  loop_end:
    movq $SYS_EXIT, %rax
    movq $0, %rdi
    syscall




