	# Q1.2 arithmetic
	# %rcx: caller-saved scratch
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

	# 4 + 7 / 2 -> 7
	movq $7, %rax
	cqto			# sign-extend
	movq $2, %rcx
	idivq %rcx		# quotient in %rax
	addq $4, %rax
	movq %rax, %rdi
	call print_int

	# 3 - 6 * (10 / 5)  ->  -9
	movq $10, %rax
	cqto
	movq $5, %rcx
	idivq %rcx		# %rax = 2
	movq $6, %rcx
	imulq %rcx, %rax	# %rax = 12
	movq $3, %rcx
	subq %rax, %rcx		# %rcx = 3 - 12 = -9
	movq %rcx, %rdi
	call print_int

	movq $0, %rax
	popq %rbp
	ret

	# print_int(%rdi)
print_int:
	pushq %rbp		# align 16
	movq %rdi, %rsi
	movq $.Sprint_int, %rdi
	movq $0, %rax
	call printf
	popq %rbp
	ret

	.data
.Sprint_int:
	.string "%d\n"
