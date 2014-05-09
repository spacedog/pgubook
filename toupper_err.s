#PURPOSE:     This program converts an input file
#             to an output file with all letters
#             converted to uppercase
#
#PROCESSING:  1) Open the input file
#             2) Open the output file
#             4) While we're not at the end of the input file
#               a) read part of file into our memory buffer
#               b) go through each byte of memory
#                   if the byte is a lower-case letter
#                   convert it to uppercase
#               c) write the memory buffer to output file

.section .data

error_message:
  .ascii "Error!\n\0"
#
## CONSTANTS
#

## word size
.equ WORD_SIZE,             8
## system call numbers
.equ SYS_READ,              0
.equ SYS_WRITE,             1
.equ SYS_OPEN,              2
.equ SYS_CLOSE,             3
.equ SYS_EXIT,              60

## open mode options
.equ O_RDONLY,              0
.equ O_CREAT_WRONLY_TRUNC,  03101

## standard file descriptors
.equ STDIN,                 0
.equ STDOUT,                1
.equ STDERR,                2

## system call interrupt
.equ LINUX_SYSCALL,         0x80

## other
.equ END_OF_FILE,           0
.equ NUMBER_ARGUMENTS ,     2

.section .bss

.equ BUFFER_SIZE,           500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

## stack positions
.equ ST_SIZE_RESERVE,       2*WORD_SIZE
.equ ST_FD_IN,              -WORD_SIZE
.equ ST_FD_OUT,             -2*WORD_SIZE
.equ ST_ARGC,               0
.equ ST_ARGV_0,             WORD_SIZE
.equ ST_ARGV_1,             WORD_SIZE*2
.equ ST_ARGV_2,             WORD_SIZE*3

.globl _start
_start:
  #
  ## INITIALIZE PROGRAM
  #
  ## save the stack pointer
  movq %rsp, %rbp

  ## allocate space for our FDs on the stack
  subq $ST_SIZE_RESERVE, %rsp

  open_files:
  open_fd_in:
    #
    ## OPEN INPUT FILE
    #
    ## open syscall
    movq $SYS_OPEN,       %rax        # move 5 to %rax
    movq ST_ARGV_1(%rbp), %rdi        # move filename to %rbx
    movq $O_RDONLY,       %rsi        # read-only flag
    movq $0666,           %rdx        # permissions
    syscall                # call Linux

    # Check for error
    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

  store_fd_in:
    movq %rax,            ST_FD_IN(%rbp)  # save FD_IT to stack

  open_fd_out:
    #
    ## OPEN OUTPUT FILE
    #
    ## open syscall
    movq $SYS_OPEN,             %rax  # move 5 to %rax
    movq ST_ARGV_2(%rbp),       %rdi  # movee filename to %rbx
    movq $O_CREAT_WRONLY_TRUNC, %rsi  # write mode
    movq $0666,                 %rdx  # permissions
    syscall                # call Linux

    # Check for error
    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

  store_fd_out:
    movq %rax,                  ST_FD_OUT(%rbp) # save FD_OUT to stack

  #
  ## MAIN LOOP
  #
  read_loop_begin:
    movq $SYS_READ,             %rax  # read(2) syscall
    movq ST_FD_IN(%rbp),        %rdi  # move FD_IN to %rbx
    movq $BUFFER_DATA ,         %rsi  # move buf addr to %rcx
    movq $BUFFER_SIZE,          %rdx  # move buf size to %rdx
    syscall                # call linux


    # check for error
    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

    ## check if we reach end of file
    cmpq $END_OF_FILE,          %rax
    jle end_loop

  continue_read_loop:
    pushq $BUFFER_DATA                # push location of buffer
    pushq %rax                        # size of the byffer being read
    call convert_to_upper             # call a function
    popq %rax                         # get size back
    addq $WORD_SIZE,            %rsp  # resotre %rsp
    #
    ## write data to output file
    #
    movq %rax,                  %rdx # move size of buffer read
    movq $SYS_WRITE,            %rax # move write(2) syscall to %rax
    movq ST_FD_OUT(%rbp),       %rdi # move name of the file
    movq $BUFFER_DATA,          %rsi # move buf address
    syscall                          # call linux

    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

    jmp read_loop_begin              # comtinue loop

  end_loop:
    #
    ## closing the files
    ## FD_IN
    movq $SYS_CLOSE,            %rax
    movq ST_FD_IN(%rbp),        %rdi
    syscall

    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

    ## FD_OUT
    movq $SYS_CLOSE,            %rax
    movq ST_FD_OUT(%rbp),       %rdi
    syscall

    pushq %rax
    call check_for_error
    addq $WORD_SIZE, %rsp

    # exit
    movq $SYS_EXIT,             %rax
    movq $0,                    %rdi
    syscall

  #PURPOSE:   This function actually does the
  #           conversion to upper case for a block
  #
  #INPUT:     The first parameter is the location
  #           of the block of memory to convert
  #           The second argumenr is the lenght of
  #           that buffer
  #
  #OUTPUT:    This function overwrites the current
  #           buffer with the upper-casifien version
  #
  #VARIABLES:
  #           %rax - beginning of buffer
  #           %rbx - lengh of a buffer
  #           %rdi - current buffer offser
  #           %cl  - current byte being examined
  #                     (first part of %rcx)

  #
  ## Constants
  #
  .equ LOWERCASE_A, 'a'
  .equ LOWERCAZE_Z, 'z'
  .equ UPPER_COVERSION, 'A' - 'a'

  #
  ## stack
  #
  .equ ST_BUFFER_LEN, WORD_SIZE*2 #ARG2
  .equ ST_BUFFER,     WORD_SIZE*3 #ARG1

  .type convert_to_upper, @function

  convert_to_upper:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_BUFFER(%rbp) , %rax
    movq ST_BUFFER_LEN(%rbp), %rbx

    movq $0, %rdi

    cmpq $0, %rbx
    je end_convert_loop

  convert_loop:
    movb (%rax, %rdi,1), %cl    # get byte

    cmpb $LOWERCASE_A,   %cl
    jl next_byte
    cmpb $LOWERCAZE_Z,   %cl
    jg next_byte

    addb $UPPER_COVERSION, %cl
    movb %cl, (%rax,%rdi,1)
  next_byte:
    incq %rdi
    cmpq %rdi, %rbx

    jne convert_loop

  end_convert_loop:
    movq %rbp, %rsp
    popq %rbp
    ret
  #PURPOSE:       Exit the program is error occures
  #               After syscall
  #INPUT:
  #         arg1 - returned value
  .equ ST_ERR_CODE , 2*WORD_SIZE # store error code in arg1

  .type check_for_error, @function

  check_for_error:
    pushq %rbp
    movq %rsp, %rbp

    movq ST_ERR_CODE(%rbp), %rax
    cmpq $0, %rax
    jge success

    error:
      # Display error message
      movq $SYS_WRITE, %rax
      movq $2, %rdi
      movq $error_message, %rsi
      movq $10, %rdx
      syscall

      movq ST_ERR_CODE(%rbp), %rdi  # move err code to %rdi
      movq $SYS_EXIT, %rax
      syscall
    success:
      movq %rbp, %rsp
      popq %rbp
      ret
