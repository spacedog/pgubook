#PURPOS:    This progmram finds the maximum number of a
#           set of data items
#
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

.globl data_items1
.globl data_items2
.globl data_items3

data_items1:                        # These are the data items
  .quad 3,67,34,222,45,75,54,34,44,33,22,11,66,0
data_items2:                        # These are the data items
  .quad 3,21,56,16,41,78,12,56,98,122,13,88,7,0
data_items3:                        # These are the data items
  .quad 51,12,65,61,22,190,123,46,20,124,21,199,33,0
.section .text
.globl _start

_start:

  pushq $data_items1
  call maximum
  addq $8, %rsp

  pushq $data_items2
  call maximum
  addq $8, %rsp

  pushq $data_items3
  call maximum
  addq $8, %rsp

  movq %rax, %rbx
  movq $1, %rax
  int $0x80
