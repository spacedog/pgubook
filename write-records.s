.include "linux.s"
.include "record-def.s"


.section .data

# Constant data of the record we want to write
# Each text data item is padded to the proper
# lenght with null (i.e. 0) bytes

# . rept is use to pad each item. .rept tells
#  the assembler to repeat the section between
# .rept and .endr the number of times specified.
# This is used int the program to add extra null
# characters at the end of each field to fill it up

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

record2:
  .ascii "Marilyn\0"
  .rept 32 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "Taylor\0"
  .rept 33 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "2224 S Johannan St\nChicago, IL 12345\0"
  .rept 203 #padding to 240 bytes
  .byte 0
  .endr

  .ascii "mt@gmail.com\0"
  .rept 29
  .byte 0
  .endr

  .quad 29

record3:
  .ascii "Derrick\0"
  .rept 32 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "McIntire\0"
  .rept 31 #padding to 40 bytes
  .byte 0
  .endr

  .ascii "500 W Oakland\nSan Diego, CA 54321\0"
  .rept 206 #padding to 240 bytes
  .byte 0
  .endr

  .ascii "mt@gmail.com\0"
  .rept 29
  .byte 0
  .endr


  .quad 36
file_name:
  .ascii "test.dat\0"
  .equ ST_FD, -WORD_SIZE

.globl _start
_start:
  movq %rsp, %rbp
  subq $8, %rsp     # space for local variable

  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  movq $0101, %rsi
  movq $0666, %rdx
  syscall

  movq %rax, ST_FD(%rbp)

  # Write first record
  pushq ST_FD(%rbp)
  pushq $record1
  call write_record
  addq $16, %rsp

  # Write second record
  pushq ST_FD(%rbp)
  pushq $record2
  call write_record
  addq $16, %rsp

  # Write third record
  pushq ST_FD(%rbp)
  pushq $record3
  call write_record
  addq $16, %rsp

  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall


