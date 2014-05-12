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

  subq $16, %rsp                # Reserve space for local vars

  movq $SYS_OPEN, %rax          # Open test.dat file
  movq $file_name, %rdi
  movq $0, %rsi
  movq $0666, %rdx
  syscall

  movq %rax, ST_INPUT_FD(%rbp)  # Save FD

  movq $STDOUT, ST_OUTPUT_FD(%rbp) # Outupt to STDOUT

  record_read_loop:             # Read reacords
    pushq ST_INPUT_FD(%rbp)     # ARG2
    pushq $record_buffer        # ARG1
    call read_record            # call function
    addq $16, %rsp              # Restore %rsp

    cmpq $RECORD_SIZE, %rax     # Error or null
    jne finished_reading

    pushq $RECORD_FIRSTNAME + record_buffer
    call count_chars
    addq $8, %rsp

    movq %rax, %rdx             # Lenght of first name
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
