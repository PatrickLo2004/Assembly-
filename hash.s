.global sha1_chunk

sha1_chunk:
	# Initialize the stack.
	push %rbp
	mov %rsp, %rbp

	# Start looping over w[0:16] and store them on the stack.
	# rax = index, rbx = w value to read from
	mov $0, %rax
	mov %rsi, %rbx
	start_l1:
	cmp $16, %rax
	je end_l1

	movl (%rbx), %ecx
	sub $4, %rsp
	movl %ecx, (%rsp)

	add $4, %rbx
	inc %rax
	jmp start_l1
	end_l1:

	# Calculate w[16:80] and store result on the stack.
	# rax = index
	mov $16, %rax
	start_l2:
	cmp $80, %rax
	jnl end_l2

	movl 8(%rsp), %ebx
	xorl 28(%rsp), %ebx
	xorl 52(%rsp), %ebx
	xorl 60(%rsp), %ebx
	roll $1, %ebx
	sub $4, %rsp
	movl %ebx, (%rsp)

	inc %rax
	jmp start_l2
	end_l2:

	# Values a through e are r8 through r12, k = r13 and f = r14
	movl (%rdi), %r8d
	movl 4(%rdi), %r9d
	movl 8(%rdi), %r10d
	movl 12(%rdi), %r11d
	movl 16(%rdi), %r12d

	# Main loop
	# rax = index, rdx = pointer to i'th element of w
	mov $0, %rax
	mov %rsp, %rdx
	add $316, %rdx
	start_ml:
	cmp $80, %rax
	jnl end_ml

	cmp $20, %rax
	jl v0_20
	
	cmp $40, %rax
	jl v20_40
	
	cmp $60, %rax
	jl v40_60

	jmp v60_80
	
	v0_20:
	movl $0x5a827999, %r13d
	movl %r9d, %r14d
	andl %r10d, %r14d

	movl %r11d, %ebx
	movl %r9d, %ecx
	xorl $0xffffffff, %ecx
	andl %ecx, %ebx
	orl %ebx, %r14d

	jmp after_cond

	v20_40:
	movl $0x6ed9eba1, %r13d
	movl %r9d, %r14d
	xorl %r10d, %r14d
	xorl %r11d, %r14d
	jmp after_cond

	v40_60:
	movl $0x8f1bbcdc, %r13d
	movl %r9d, %r14d
	andl %r10d, %r14d
	movl %r9d, %ebx
	andl %r11d, %ebx
	movl %r10d, %ecx
	andl %r11d, %ecx
	orl %ebx, %r14d
	orl %ecx, %r14d
	jmp after_cond

	v60_80:
	movl $0xca62c1d6, %r13d
	movl %r9d, %r14d
	xorl %r10d, %r14d
	xorl %r11d, %r14d
	jmp after_cond

	after_cond:
	movl %r8d, %r15d
	roll $5, %r15d
	addl %r12d, %r15d
	addl %r13d, %r15d
	addl %r14d, %r15d
	mov %rsp, %rbx
	addl (%rdx), %r15d

	movl %r11d, %r12d
	movl %r10d, %r11d
	movl %r9d, %r10d
	roll $30, %r10d
	movl %r8d, %r9d
	movl %r15d, %r8d

	inc %rax
	sub $4, %rdx
	jmp start_ml
	end_ml:

	# Add chunk result.
	addl %r8d, (%rdi)
	addl %r9d, 4(%rdi)
	addl %r10d, 8(%rdi)
	addl %r11d, 12(%rdi)
	addl %r12d, 16(%rdi)

	# Restore the stack.
	mov %rbp, %rsp
	pop %rbp
	ret
