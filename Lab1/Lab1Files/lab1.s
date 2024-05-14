@ ARM Assembly - Lab 1
@ E Number :
@ Name :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	ldr r0, =array_a
	ldr r1, =array_b
	mov r2, #3
	mov r3, #7
	mov r4, #10

	
	@ Write YOUR CODE HERE
	@ b[4] = 6 + a[9] - a[3] + b[1] – ( c + d - e )
	@ Base address of a in r0
	@ Base address of b in r1
	@ c,d,e in r2,r3,r4 respectively 

	@ ---------------------
	add r4,r4,#6 // Register r4 contains e+6
	sub r4,r4,r3 // Register r4 contains r4-d
	sub r4,r4,r2 // Register r4 contains r4-c
	ldr r2,[r1,#4] // Register r2 gets b[1]
	add r4,r4,r2 // Register r4 contains r4+r2
	ldr r2,[r0,#36] // Register r2 gets a[9]
	add r4,r4,r2 // Register r4 contains r4+r2
	ldr r2,[r0,#12] // Register r2 gets a[3]
	sub r4,r4,r2 // Register r4 contains r4-r2
	str r4,[r1,#16] // Store final result into b[4]
	@ ---------------------
	
	
	@ load aguments and print
	ldr r0, =format
	ldr r2, =array_b
	ldr r1, [r2,#16]
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	
	
	.data	@ data memory
	
format: .asciz "The Answer is %d (Expect -3 if correct)\n"
	
	@array called array_a of size 40 bytes
	.balign 4 			@align to an address of multiple of 4
array_a: .word 1,5,7,67,5,54,65,23,34,54

	@array called array_b of size 20 bytes
	.balign 4 			@align to an address of multiple of 4
array_b: .word 7,4,8,3,5
