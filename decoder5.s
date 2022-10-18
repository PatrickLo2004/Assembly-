.data
output: .asciz "%c"
output2: .asciz "%ld"
.text

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
  
  push %r9
  mov %rdi, %r9       #Pushing all registers used in the program to the stack
  push %r11           #in order to help keep callee registers correct
  push %r12
  push %r15     
  push %r8
  mov $0, %r11
  mov (%r9), %r11b    #taking the character byte and storing it in r11
  inc %r9
  mov $0, %r8
  mov (%r9), %r8b
  inc  %r9            #taking the amount byte and storing it in r8
  mov $0, %r12
  mov (%r9), %r12w
  push %rdi                  #taking the index word and storing it in r12
  push %r12           
  push %r11           #pushing our arguments to the stack in order
  push %r8
  jmp printer
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	mov %rsp, %rbp
  popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

printer:
 
  pop %rcx
  cmpq $1, %rcx   #checks whether a character has been printed often enough
  jl compar2      #jumps to compar2 when character has been printed enough
  dec %rcx
  
  pop %r9
  mov %r9, %rsi #character is moved to rsi for printing
  push %r9      #arguments are pushed to stack for next print iteration
  push %rcx
  

  mov $output, %rdi
  mov $0, %rax      #standard printf routine
  call printf
  jmp printer       #jumps itself again to check to go to compar2 or keep printing
  
  
compar:
  
 
  pop %r9
  mov $0, %r11
  mov (%r9), %r11b
  inc %r9
  mov $0, %r8
  mov (%r9), %r8b
  inc  %r9
  mov $0, %r12
  mov (%r9), %r12w
  push %r12
  push %r11
  push %r8
  jmp printer
  
compar2:
  pop %r15    #remove character from stack is no longer needed
  
  pop %r8     #pop index to r8  
  
  cmp $0, %r8
  je end1       #if index is 0 end program
  mov $8, %rax
  mul %r8         #multiply index with 8 to calculate memory adress
  pop  %r9
  push %r9
  add %rax, %r9     #calculate next memory adress
  push %r9
  jmp compar      #restart routine for printing next character

end1:
  pop %r9
  pop %r8
  pop %r15
  pop %r12  #restoring the registers from before call decode
  pop %r11
  movq  %rbp, %rsp    # clear local variables from stack
  popq  %rbp      # restore base pointer location 
  ret
