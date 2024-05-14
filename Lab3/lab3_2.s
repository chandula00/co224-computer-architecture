 @ ARM Assembly - lab 3.2 
@ Group Number : 09

	.text 	@ instruction memory

	
@ Write YOUR CODE HERE	

@ ---------------------	
gcd:
	sub sp, sp, #4		@ Make space in stack for a element
	str lr, [sp, #0]	@ Store return address
	
	cmp r1, #0	@ Compare b with 0
	beq base	@ If b=0, jump to base branch (Base Case) 

	mov r2, r1	@ r2 = b
	mov r1, r0	@ r1 = a
	mov r0, r2	@ r0 = b
	
	@ Calculating (a%b) and store value in r1
	loop:
		cmp r1, r0	@ Compare value in r1 (remainder) with b
		blt exit	@ If r1<b, exit from the loop

		sub r1, r1, r0	@ remainder -= b
		b loop			@ Jump back to top of the loop

		exit:
			bl gcd	@ Recursive call

			ldr lr, [sp, #0]	@ Restore previous return address
			add sp, sp, #4		@ Increase stack point 
			mov pc, lr			@ Set program counter to previous return address

	base:
		add sp, sp, #4	@ Increase stack point by 4 addresses
		mov pc, lr		@ Set program counter to previous return address	
@ ---------------------	

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #64 	@the value a
	mov r5, #24 	@the value b
	

	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl gcd
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
format: .asciz "gcd(%d,%d) = %d\n"

