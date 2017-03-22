	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 12
	.globl	_get_int64
	.align	4, 0x90
_get_int64:                             ## @get_int64
## BB#0:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	callq	___error
	leaq	-16(%rbp), %rsi
	movl	$10, %edx
	movl	$0, (%rax)
	movq	-8(%rbp), %rdi
	callq	_strtoll
	movq	%rax, -24(%rbp)
	callq	___error
	cmpl	$34, (%rax)
	jne	LBB0_3
## BB#1:
	movabsq	$9223372036854775807, %rax ## imm = 0x7FFFFFFFFFFFFFFF
	cmpq	%rax, -24(%rbp)
	je	LBB0_5
## BB#2:
	movabsq	$-9223372036854775808, %rax ## imm = 0x8000000000000000
	cmpq	%rax, -24(%rbp)
	je	LBB0_5
LBB0_3:
	callq	___error
	cmpl	$0, (%rax)
	je	LBB0_6
## BB#4:
	cmpq	$0, -24(%rbp)
	jne	LBB0_6
LBB0_5:
	leaq	L_.str(%rip), %rdi
	callq	_perror
	movl	$1, %edi
	callq	_exit
LBB0_6:
	movq	-24(%rbp), %rax
	addq	$32, %rsp
	popq	%rbp
	retq

	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
## BB#0:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$112, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	cmpl	$9, -4(%rbp)
	je	LBB1_2
## BB#1:
	leaq	L_.str.1(%rip), %rdi
	movl	$8, %esi
	movb	$0, %al
	callq	_printf
	xorl	%edi, %edi
	movl	%eax, -92(%rbp)         ## 4-byte Spill
	callq	_exit
LBB1_2:
	movq	-16(%rbp), %rax
	movq	8(%rax), %rdi
	callq	_get_int64
	movq	%rax, -24(%rbp)
	movq	-16(%rbp), %rax
	movq	16(%rax), %rdi
	callq	_get_int64
	movq	%rax, -32(%rbp)
	movq	-16(%rbp), %rax
	movq	24(%rax), %rdi
	callq	_get_int64
	movq	%rax, -40(%rbp)
	movq	-16(%rbp), %rax
	movq	32(%rax), %rdi
	callq	_get_int64
	movq	%rax, -48(%rbp)
	movq	-16(%rbp), %rax
	movq	40(%rax), %rdi
	callq	_get_int64
	movq	%rax, -56(%rbp)
	movq	-16(%rbp), %rax
	movq	48(%rax), %rdi
	callq	_get_int64
	movq	%rax, -64(%rbp)
	movq	-16(%rbp), %rax
	movq	56(%rax), %rdi
	callq	_get_int64
	movq	%rax, -72(%rbp)
	movq	-16(%rbp), %rax
	movq	64(%rax), %rdi
	callq	_get_int64
	movq	%rax, -80(%rbp)
	movq	-24(%rbp), %rdi
	movq	-32(%rbp), %rsi
	movq	-40(%rbp), %rdx
	movq	-48(%rbp), %rcx
	movq	-56(%rbp), %r8
	movq	-64(%rbp), %r9
	movq	-72(%rbp), %rax
	movq	-80(%rbp), %r10
	movq	%rax, (%rsp)
	movq	%r10, 8(%rsp)
	callq	_program
	leaq	L_.str.2(%rip), %rdi
	movq	%rax, -88(%rbp)
	movq	-88(%rbp), %rsi
	movb	$0, %al
	callq	_printf
	xorl	%r11d, %r11d
	movl	%eax, -96(%rbp)         ## 4-byte Spill
	movl	%r11d, %eax
	addq	$112, %rsp
	popq	%rbp
	retq

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"strtoll"

L_.str.1:                               ## @.str.1
	.asciz	"usage: calculator x1 .. x%d\n"

L_.str.2:                               ## @.str.2
	.asciz	"program returned: %lld\n"


.subsections_via_symbols
