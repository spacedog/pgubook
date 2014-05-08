#PURPOSE:     Given a number, this program computes the
#             factorial.
#
#
.section .data

.section .text

.globl _start

_start:
  pushq $4
  call factorial

  addq $8, %rsp
  movq %rax, %rbx
  movq $1, %rax

  int $0x80

#PURPOSE:     This function actualy computes factorial
#             of a give argument using recursive function
#
#INPUT:
#             arguemnt 1 -  given number to compute factorial
#
#OUTPUT:
#             return factirial value
#VARIABLES:
#
.type factorial, @function

factorial:
  pushq %rbp
  movq %rsp, %rbp

  movq 16(%rbp), %rax

  cmpq $1, %rax
  je end_factorial

  decq %rax
  pushq %rax

  call factorial

  movq 16(%rbp), %rbx
  imulq %rbx, %rax

end_factorial:
  movq %rbp, %rsp
  popq %rbp
  ret
