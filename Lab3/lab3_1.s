@ ARM Assembly - lab 3.1
@ Group Number : 09
@ Roshan Ragel - roshanr@pdn.ac.lk
@ Hasindu Gamaarachchi - hasindu@ce.pdn.ac.lk

	.text 	@ instruction memory

	
@ Write YOUR CODE HERE	

@ ---------------------	
mypow:
	sub sp, sp, #4		@ Make space in stack for a element
	str lr, [sp,#0]		@ Store return address

	cmp r1, #0	@ Compare n with 0
	beq base	@ If n=0, jump to base branch (Base Case)

	sub r1, r1, #1	@ n--
	bl mypow		@ Recursive call

	mul r6, r0, r4	@ r6(temp) = previous call return value * X
	mov r0, r6		@ Move result to r0

	ldr lr, [sp,#0] @ Restore previous return address
	add sp, sp, #4	@ Increase stack point by 4 addresses
	mov pc, lr		@ Set program counter to previous return address

	base:
		mov r0, #1		@ set r0 value to 1
		add sp, sp, #4	@ Increase stack point by 4 addresses
		mov pc, lr		@ Set program counter to previous return address
@ ---------------------	

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value x
	mov r5, #3 	@the value n
	

	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl mypow
	mov r6,r0
	

	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	mov r3, r6
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "%d^%d is %d\n"

