.data
  number: .quad 0

  welcome: .asciz  "Welcome to the factorial assignment please enter a number: "
   
  numberinput: .asciz "%ld"

  answer: .asciz "The result of the factorial is: %ld\n"

.global main
.text



main:
  push %rbp                 # These are the prologue statements to set the
  mov %rsp, %rbp            # stack

  mov $welcome, %rdi        # Prints welcome message and asks for number
  mov $0, %rax         
  call printf

  mov $numberinput, %rdi    # Scans for number
  mov $number, %rsi         # stores it in "number"
  mov $0, %rax
  call scanf

  mov number, %rax          # Moves "number" to rax so it can be accessed in
  call factorial              # the subroutine

  mov $answer, %rdi         # Calls the answer text and moves it to rdi
  mov %rax, %rsi            # Moves the calculated result to rsi so it can
  mov $0, %rax                # be inserted into the answer text
  call printf               # Obligatory rax clear before call printf

  call exit

factorial:
  push %rbp         # Sets the stack for the factorial subroutine
  mov %rsp, %rbp

  cmpq $1, %rax     # Compares the value of "number" stored in rax with 1
  jle end1          # Jumps to end1 if n is equal to or less than 1

  push %rax         # The value of the number stored in rax (which becomes
                      # the result of “imulq %rbx”, is pushed onto the stack
  dec %rax          # If “number” is greater than 1 it is decremented
  call factorial    # The subroutine factorial is called again
  pop %rbx          # The previous result of imulq rbx is is popped off the stack
                      # and stored into rax so it can be used again to multiply
                      # with the current value of rax
  imulq %rbx        # Multiplies rbx with rax
  jmp end2          # Jumps to end2

end1:
  mov %rbp, %rsp   # Resets the stack
  pop %rbp     
  mov $1, %rax     # Moves 1 to rax if number is "0" or "1"   
  ret              # Returns to main

end2: 
  mov %rbp, %rsp  #resets the stack
  pop %rbp
  ret             #returns to main
