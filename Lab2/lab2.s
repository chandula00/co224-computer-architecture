@ ARM Assembly - lab 2
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	
	@ Write YOUR CODE HERE
	
	@	Sum = 0;
	@	for (i=0;i<10;i++){
	@			for(j=5;j<15;j++){
	@				if(i+j<10) sum+=i*2
	@				else sum+=(i&j);	
	@			}	
	@	} 
	@ Put final sum to r5


	@ ---------------------
	MOV r5,#0 // set value of r5 to 0(sum)
	MOV r0,#0 // set value of r0 to 0(i)

OuterLoop:
	CMP r0,#10 // compare i with 10
	BGE Exit // if i>=10 jump in to the exit
	MOV r1,#5 // set value of r1 to 5(j)

	InnerLoop:
		CMP r1,#15 // compare j with 15
		BGE ExitInner // if j>=15 jump in to the ExitInner
		
		
		ADD r2,r0,r1 // add i and j and store in r2
		CMP r2,#10 // compare r2 with 10
		BGE Else // if r2>=10 jump in to the Else branch
		
		ADD r5,r5,r0,LSL #1 // sum = sum +(i<<1)
		ADD r1,r1,#1 // j++
		B InnerLoop // jump in to innerloop again

		
		Else:
			AND r3,r0,r1 // i&j
			ADD r5,r5,r3 // sum = sum + r3
			ADD r1,r1,#1 // j++
			B InnerLoop // jump in to innerloop again
		
		ExitInner:
			ADD r0,r0,#1 // i++
			B OuterLoop // jump in to the OuterLoop
		
		Exit:

	@ ---------------------
	
	
	@ load aguments and print
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 300 if correct)\n"

