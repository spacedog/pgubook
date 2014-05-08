#PURPOSE:       Retruns a square of a given number
#
#
.section .data

.section .text
.globl square

.type square, @function

square:
  pushq %rbp          # Push old %rpb
  movq %rsp, %rbp     # Setup %rpb

  movq 16(%rbp), %rax  # Move arg1 to %rax
  imulq %rax, %rax    # Multiply %rax

  movq %rbp, %rsp     # Move %rsp to %rbp
  popq %rbp           # Restor %rbp
  ret                 # Reutrn %rax and go back to code
