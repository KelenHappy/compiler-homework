	# Q1.3 booleans (0 = false)
	# %rcx: caller-saved scratch
	.text
	.globl main
main:
	pushq %rbp

	# true && false -> false
	movq $1, %rax			# true
	testq %rax, %rax
	je .Land_false
	movq $0, %rax			# false
	testq %rax, %rax
	je .Land_false
	movq $1, %rax
	jmp .Land_end
.Land_false:
	movq $0, %rax
.Land_end:
	movq %rax, %rdi
	call print_bool

	# if 3 <> 4 then 10*2 else 14 -> 20
	movq $3, %rax
	cmpq $4, %rax			# flags of (3 - 4)
	je .Lelse
	movq $10, %rax
	imulq $2, %rax
	jmp .Lendif
.Lelse:
	movq $14, %rax
.Lendif:
	movq %rax, %rdi
	call print_int

	# 2 = 3 || 4 <= 2*3 -> true
	movq $2, %rax
	cmpq $3, %rax
	sete %al			# %al = (2 = 3)
	movzbq %al, %rax
	testq %rax, %rax
	jne .Lor_true
	movq $2, %rax
	imulq $3, %rax			# %rax = 6
	movq $4, %rcx
	cmpq %rax, %rcx			# flags of (4 - 6)
	setle %al			# %al = (4 <= 6)
	movzbq %al, %rax
	testq %rax, %rax
	jne .Lor_true
	movq $0, %rax
	jmp .Lor_end
.Lor_true:
	movq $1, %rax
.Lor_end:
	movq %rax, %rdi
	call print_bool

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

	# print_bool(%rdi)
print_bool:
	pushq %rbp
	testq %rdi, %rdi
	je .Lpb_false
	movq $.Strue, %rdi
	jmp .Lpb_call
.Lpb_false:
	movq $.Sfalse, %rdi
.Lpb_call:
	movq $0, %rax
	call printf
	popq %rbp
	ret

	.data
.Sprint_int:
	.string "%d\n"
.Strue:
	.string "true\n"
.Sfalse:
	.string "false\n"
