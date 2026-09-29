	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	pushq $10
	pushq $3
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $3
	pushq $10
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $1
	pushq $2
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	pushq $3
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $1
	pushq $2
	pushq $3
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $0
	pushq $7
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	pushq $2
	popq %rcx
	popq %rax
	cqto
	idivq %rcx
	pushq %rax
	popq %rdi
	call print_int
	pushq $100
	pushq $0
	pushq $7
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	cqto
	idivq %rcx
	pushq %rax
	popq %rdi
	call print_int
	pushq $0
	pushq $100
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	pushq $0
	pushq $7
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	cqto
	idivq %rcx
	pushq %rax
	popq %rdi
	call print_int
	pushq $1
	pushq $2
	pushq $3
	pushq $4
	pushq $5
	pushq $6
	pushq $7
	pushq $8
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $100
	pushq $50
	pushq $20
	pushq $10
	pushq $5
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $20
	pushq $4
	popq %rax
	movq %rax, -8(%rbp)
	pushq -8(%rbp)
	pushq -8(%rbp)
	pushq $1
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $5
	popq %rax
	movq %rax, a
	pushq a
	pushq $1
	popq %rax
	movq %rax, -8(%rbp)
	pushq -8(%rbp)
	pushq $10
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
	call print_int
	pushq $100
	popq %rax
	movq %rax, -8(%rbp)
	pushq -8(%rbp)
	pushq $7
	popq %rax
	movq %rax, -16(%rbp)
	pushq -8(%rbp)
	pushq -16(%rbp)
	pushq $10
	popq %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rcx
	popq %rax
	cqto
	idivq %rcx
	pushq %rax
	popq %rdi
	call print_int
	pushq a
	pushq a
	popq %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	pushq a
	pushq $1
	popq %rcx
	popq %rax
	addq %rcx, %rax
	pushq %rax
	popq %rax
	movq %rax, -8(%rbp)
	pushq -8(%rbp)
	pushq -8(%rbp)
	popq %rcx
	popq %rax
	imulq %rcx, %rax
	pushq %rax
	pushq $3
	popq %rcx
	popq %rax
	cqto
	idivq %rcx
	pushq %rax
	popq %rcx
	popq %rax
	subq %rcx, %rax
	pushq %rax
	popq %rdi
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
