#PURPOSE:   Program to illustrate how functions works
#           This program will compute the value of
#           2^3 + 5^2
#
#Everything in the main program is stored in registers,
#so the data section doesn't have anything
.section .data

.section .text

.globl _start
_start:
  pushq $0                #push second argument
  pushq $2                #push first argument
  call power              #call function
  addq $16, %rsp          #move the stack pointer back
  pushq %rax              #save the first answer before
                          #calling the next function

  pushq $2                #push second argument
  pushq $5                #push first argument
  call power              #call function
  addq $16, %rsp          #move the stack pointer back
  popq %rbx               #the second answer is already
                          #in %rax. We saved the
                          #first answer onto the stack,
                          #sow now we can just pop it
                          #out into %rbx
  addq %rax, %rbx         #add them togather
                          #the result is in %rbx
  movq $1, %rax            #exit
  int $0x80

  #PURPOSE:   This function is used to compute
  #           the value of a number raised to a power
  #
  #INPUT:
  #           First argument - the base number
  #           Second argument - the power to
  #                             raise it to
  #
  #OUTPUT:
  #           Will give the result as a return value
  #
  #NOTES:     The power must be 1 or greater
  #
  #VARIABLES:
  #           %rbx - holds the base number
  #           %rcx - holds the power
  #           -4(%rbp) - holds the current result
  #           %rax  is used for temporary storage
  .type power,@function
  power:
    pushq %rbp            #save old base pointer
    movq %rsp, %rbp       #make stack pointer the base pointer
    subq $8, %rsp         #get room for our storage

    movq 16(%rbp), %rbx    #put first arguemnt in %rbx
    movq 24(%rbp), %rcx   #put second argument in %rcx

    cmpq $0, %rcx
    je end_power_1

    movq %rbx, -8(%rbp)   #store current result

  power_loop_start:
    cmpq $1, %rcx         # if the power is 1 we are done
    je end_power
    movq -8(%rbp), %rax   #move the current result int %rax
    imulq %rbx, %rax      #multiply current result by
                          #the base number
    movq %rax, -8(%rbp)   #store the current result
    decq %rcx             #decrement the power
    jmp power_loop_start  #run for the next power

  end_power:
    movq -8(%rbp), %rax   #return value goes in %rax
    movq %rbp, %rsp       #restore the stack ponter
    popq %rbp             #restore the base pointer
    ret
  end_power_1:
    movq $1, %rax
    movq %rbp, %rsp       #restore the stack ponter
    popq %rbp             #restore the base pointer
    ret
