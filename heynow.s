#PURPOSE:     Prints "Hey diddle diddle" into
#             heynow.txt
#
.section .data

string_to_write:
.ascii "Hey diddle diddle!\n\0"

file_name:
.ascii "heynow.txt\0"


.section .text

.equ SYS_WRITE, 1
.equ SYS_OPEN,  2
.equ SYS_EXIT,  60

.equ O_CREAT_WRONLY_TRUNC,  03101


.globl _start

_start:
  pushq %rbp
  movq %rsp, %rbp

  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  movq $O_CREAT_WRONLY_TRUNC, %rsi
  movq $0666, %rdx
  syscall


  movq %rax, %rdi
  movq $SYS_WRITE, %rax
  movq $string_to_write, %rsi
  movq $20 , %rdx
  syscall

  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall


