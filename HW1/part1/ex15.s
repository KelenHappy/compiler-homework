	# Q1.5 locals -> 9, 19
	# frame: -8 x, -16 y, -24 z, -32 tmp
	.text
	.globl main
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp			# align 16

	# print (let x = 3 in x * x)
	movq $3, -8(%rbp)		# x = 3
	movq -8(%rbp), %rax
	imulq -8(%rbp), %rax
	movq %rax, %rdi
	call print_int

	# print (let x = 3 in (let y = x+x in x*y) + (let z = x+3 in z/z))
	movq $3, -8(%rbp)		# x = 3

	movq -8(%rbp), %rax		# let y = x + x
	addq -8(%rbp), %rax
	movq %rax, -16(%rbp)		# y = 6

	movq -8(%rbp), %rax		# x * y
	imulq -16(%rbp), %rax
	movq %rax, -32(%rbp)		# left operand = 18

	movq -8(%rbp), %rax		# let z = x + 3
	addq $3, %rax
	movq %rax, -24(%rbp)		# z = 6

	movq -24(%rbp), %rax		# z / z
	cqto
	idivq -24(%rbp)			# %rax = 1

	addq -32(%rbp), %rax		# 18 + 1
	movq %rax, %rdi
	call print_int

	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret

	# print_int(%rdi)
print_int:
	pushq %rbp
	movq %rdi, %rsi
	movq $.Sprint_int, %rdi
	movq $0, %rax
	call printf
	popq %rbp
	ret

	.data
.Sprint_int:
	.string "%d\n"
