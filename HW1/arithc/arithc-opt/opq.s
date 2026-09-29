	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	movq $10, %rax
	pushq %rax
	movq $3, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $3, %rax
	pushq %rax
	movq $10, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $1, %rax
	pushq %rax
	movq $2, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	movq $3, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $1, %rax
	pushq %rax
	movq $2, %rax
	pushq %rax
	movq $3, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $0, %rax
	pushq %rax
	movq $7, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	movq $2, %rax
	movq %rax, %rcx
	popq %rax
	cqto
	idivq %rcx
	movq %rax, %rdi
	call print_int
	movq $100, %rax
	pushq %rax
	movq $0, %rax
	pushq %rax
	movq $7, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	cqto
	idivq %rcx
	movq %rax, %rdi
	call print_int
	movq $0, %rax
	pushq %rax
	movq $100, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	movq $0, %rax
	pushq %rax
	movq $7, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	cqto
	idivq %rcx
	movq %rax, %rdi
	call print_int
	movq $1, %rax
	pushq %rax
	movq $2, %rax
	pushq %rax
	movq $3, %rax
	pushq %rax
	movq $4, %rax
	pushq %rax
	movq $5, %rax
	pushq %rax
	movq $6, %rax
	pushq %rax
	movq $7, %rax
	pushq %rax
	movq $8, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $100, %rax
	pushq %rax
	movq $50, %rax
	pushq %rax
	movq $20, %rax
	pushq %rax
	movq $10, %rax
	pushq %rax
	movq $5, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $20, %rax
	pushq %rax
	movq $4, %rax
	movq %rax, -8(%rbp)
	movq -8(%rbp), %rax
	pushq %rax
	movq -8(%rbp), %rax
	pushq %rax
	movq $1, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	imulq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $5, %rax
	movq %rax, a
	movq a, %rax
	pushq %rax
	movq $1, %rax
	movq %rax, -8(%rbp)
	movq -8(%rbp), %rax
	pushq %rax
	movq $10, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq $100, %rax
	movq %rax, -8(%rbp)
	movq -8(%rbp), %rax
	pushq %rax
	movq $7, %rax
	movq %rax, -16(%rbp)
	movq -8(%rbp), %rax
	pushq %rax
	movq -16(%rbp), %rax
	pushq %rax
	movq $10, %rax
	movq %rax, %rcx
	popq %rax
	imulq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rcx
	popq %rax
	cqto
	idivq %rcx
	movq %rax, %rdi
	call print_int
	movq a, %rax
	pushq %rax
	movq a, %rax
	movq %rax, %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	movq a, %rax
	pushq %rax
	movq $1, %rax
	movq %rax, %rcx
	popq %rax
	addq %rcx, %rax
	movq %rax, -8(%rbp)
	movq -8(%rbp), %rax
	pushq %rax
	movq -8(%rbp), %rax
	movq %rax, %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	movq $3, %rax
	movq %rax, %rcx
	popq %rax
	cqto
	idivq %rcx
	movq %rax, %rcx
	popq %rax
	subq %rcx, %rax
	movq %rax, %rdi
	call print_int
	movq %rbp, %rsp
	popq %rbp
	movq $0, %rax
	ret
print_int:
	pushq %rbp
	movq %rdi, %rsi
	leaq .Sprint_int, %rdi
	movq $0, %rax
	call printf
	popq %rbp
	ret
	.data
a:
	.quad 1
.Sprint_int:
	.string "%d\n"
