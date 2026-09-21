	# Q1.4 globals -> 6
	.text
	.globl main
main:
	pushq %rbp

	movq $2, x			# x = 2

	movq x, %rax
	imulq x, %rax
	movq %rax, y			# y = x * x

	movq y, %rax
	addq x, %rax			# y + x
	movq %rax, %rdi
	call print_int

	movq $0, %rax
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
x:
	.quad 0
y:
	.quad 0
.Sprint_int:
	.string "%d\n"
