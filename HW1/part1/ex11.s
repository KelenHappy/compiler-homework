	# Question 1.1 -- printf("n = %d\n", 42)
	.text
	.globl main
main:
	pushq %rbp		# stack is now 16-byte aligned
	movq $42, %rsi		# 2nd argument of printf
	movq $.Sfmt, %rdi	# 1st argument: the format string
	movq $0, %rax		# printf is variadic: no vector register used
	call printf
	movq $0, %rax		# exit code
	popq %rbp
	ret

	.data
.Sfmt:
	.string "n = %d\n"
