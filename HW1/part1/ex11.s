	# Q1.1 printf
	.text
	.globl main
main:
	pushq %rbp		# align 16
	movq $42, %rsi		# arg 2
	movq $.Sfmt, %rdi	# arg 1
	movq $0, %rax		# variadic
	call printf
	movq $0, %rax		# exit code
	popq %rbp
	ret

	.data
.Sfmt:
	.string "n = %d\n"
