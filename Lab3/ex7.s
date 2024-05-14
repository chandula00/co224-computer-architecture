@ ARM Assembly - exercise 7 
@ Group Number : 09

	.text 	@ instruction memory

	
@ Write YOUR CODE HERE	

@ ---------------------	
Fibonacci:
	sub sp, sp, #8		@ Decrease stack point by 8 addresses for store 2 elements
	str lr, [sp, #4]	@ Store return address
	str r4, [sp, #0]	@ Store value in the r4 in stack

	cmp r4, #0			@ Compare n with 0
	beq base_case_zero	@ If n=0, jump to branch base_case_zero

	cmp r4, #1			@ Compare n with 1
	beq base_case_one	@ If n=1, jump to branch base_case_one

	sub r4, r4, #1	@ n--
	bl Fibonacci	@ Recursive call

	mov r2, r0		@ r2 = previous call fibonacci value
	add r0, r2, r1	@ fib(n) = fib(n-1) + fib(n-2)
	mov r1, r2		@ r1 = fib(n-1)
	mov r2, r0		@ r2 = fib(n)

	ldr r4, [sp, #0]	@ load value of n from stack
	ldr lr, [sp, #4]	@ Restore previous return address
	add sp, sp, #8		@ Increase stack point by 8 addresses
	mov pc, lr			@ Set program counter to previous return address

	base_case_zero:
		mov r0, #0		@ set r0 value to 0
		add sp, sp, #8	@ Increase stack point by 8 addresses
		mov pc, lr		@ Set program counter return address

	base_case_one:
		mov r1, #0		@ set r1 value to 0
		mov r0, #1		@ set r0 value to 1
		add sp, sp, #8	@ Increase stack point by 8 addresses
		mov pc, lr		@ Set program counter return address
@ ---------------------
	
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the Fibonacci function
	mov r0, r4 	@the arg1 load
	bl Fibonacci
	mov r5,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "F_%d is %d\n"

