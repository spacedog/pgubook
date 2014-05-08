#PURPOS:    This progmram finds the maximum number of a #           set of data items #
#VARIABLES: The registers have te followin uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The follwoing memory location are used:
#
# data_items - contains the item date. A 0 is used
#              to terminate the data
#
.section .data

data_items:                        # These are the data items
  .long 3,67,34,222,45,75,54,34,44,33,22,11,66
end_of_data:

.section .text
.globl _start

_start:
  movl $0, %edi                  # move 0 int the index register
  movl data_items(,%edi,4), %eax # load the first byte of data
  movl %eax, %ebx                # since this is the first item, %eax is
                                 # the biggest
  movl $end_of_data, %eax
  cmpl $data_items, %eax
  je loop_exit
start_loop:                      # start loop
  incl %edi
  imul $4, %edi, %eax
  addl $data_items, %eax
  cmpl $end_of_data, %eax        # compare address
  je loop_exit
  movl data_items(,%edi,4), %eax # load the first byte of data
  cmpl %ebx, %eax                # compare values
  jle start_loop                 # jump to loop beginning if the new
                                 # one isn't bigger
  movl %eax, %ebx                # move the value as the largest
  jmp start_loop                 # jump to tool beginning

loop_exit:
  # %ebx is the statis code for the exit system call
  # and it already has the maximum number
  movl $1, %eax
  int $0x80
