.section .data

.section .text

.globl maximum

.type maximum, @function

maximum:
  pushq %rbp
  movq %rsp, %rbp

  subq $8, %rsp             # local variable to store max value

  movq 16(%rbp), %rbx       # get address of first element
  movq (%rbx), %rax         # save as a max value
  movq %rax, -8(%rbp)

maximum_loop:
  cmpq $0, %rax             # 0 - end of the list
  je end_maximum

  addq $8, %rbx             #getting the address of next element
  movq (%rbx), %rax
  cmpq -8(%rbp), %rax       # compare if the element if larger
  jle maximum_loop

  movq %rax, -8(%rbp)       # move max value to local variable
  jmp maximum_loop

end_maximum:
  movq -8(%rbp), %rax
  movq %rbp, %rsp
  popq %rbp
  ret
