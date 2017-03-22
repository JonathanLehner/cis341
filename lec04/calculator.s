	.text
	.globl	_program
_program:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	24(%rbp)
	pushq	24(%rbp)
	popq	%rax
	popq	%r10
	imulq	%r10, %rax
	pushq	%rax
	popq	%rax
	popq	%rbp
	retq	