	# Question 1.2 -- arithmetic expressions
	.text
	.globl main
main:
	pushq %rbp

	# 4 + 6  ->  10
	movq $4, %rax
	addq $6, %rax
	movq %rax, %rdi
	call print_int

	# 21 * 2  ->  42
	movq $21, %rax
	imulq $2, %rax
	movq %rax, %rdi
	call print_int

	# 4 + 7 / 2  ->  7   (integer division: 7/2 = 3)
	movq $7, %rax
	cqto			# sign-extend %rax into %rdx:%rax
	movq $2, %rbx
	idivq %rbx		# quotient in %rax
	addq $4, %rax
	movq %rax, %rdi
	call print_int

	# 3 - 6 * (10 / 5)  ->  -9
	movq $10, %rax
	cqto
	movq $5, %rbx
	idivq %rbx		# %rax = 2
	movq $6, %rcx
	imulq %rcx, %rax	# %rax = 12
	movq $3, %rbx
	subq %rax, %rbx		# %rbx = 3 - 12 = -9
	movq %rbx, %rdi
	call print_int

	movq $0, %rax
	popq %rbp
	ret

	# print_int: displays the integer passed in %rdi
print_int:
	pushq %rbp		# realign the stack before calling printf
	movq %rdi, %rsi
	movq $.Sprint_int, %rdi
	movq $0, %rax
	call printf
	popq %rbp
	ret

	.data
.Sprint_int:
	.string "%d\n"
