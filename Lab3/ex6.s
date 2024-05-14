@ ARM Assembly - exercise 6 
@ Group Number : 09

	.text 	@ instruction memory
	
	
@ Write YOUR CODE HERE	

@ ---------------------	
fact:
	sub sp, sp, #4		@ Make space in stack for 1 element
	str r4, [sp, #0]	@ Store value in the r4 in stack

loop:	
	cmp r4, #1	@ Compare n with 1
	beq exit	@ If n = 1, jump to exit

	sub r4, r4, #1	@ n--
	mul r3, r0, r4	@ r3(temp) = r0(previos return value) x r4(n)
	mov r0, r3		@ r0 = r3
	B loop			@ Jump back to loop

exit:
	ldr r4, [sp, #0]	@ Restore original value of r4
	add sp, sp, #4		@ Increase stack point by 4 addresses
	mov pc, lr			@ Set program counter to previous return address
@ ---------------------	

.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the fact function
	mov r0, r4 	@the arg1 load
	bl fact
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
format: .asciz "Factorial of %d is %d\n"

