@ ARM Assembly - lab 4
@ Group Number : 09

	.text 	@ instruction memory

    .global main
main:
    @ push (store) lr to the stack
    sub sp, sp, #4
	str lr, [sp, #0]

    @ Prompt a message for get number of strings
    ldr r0, =format_pnos
    bl printf

    @ Get number of strings
    sub sp, sp, #4
    ldr r0, =format_snos
    mov r1, sp
    bl scanf
    
    cmp r0,#0
    beq error

    @ Load number from stack to r4
    ldr r4, [sp, #0]

    @ Compares user input(n) with 0
	cmp r4, #0
	beq exit		@ If n == 0, exit the program
	blt error		@ If n < 0, prompt an error message

    @ Set i=0 for strLoop
    mov r5, #0

    strLoop:
        cmp r4,r5       @ Compare i with n
        beq exit		@ If i == n, exit loop

        @ Prompt a message to get the string
        @ printf("Enter input string %d :\n", i)
        ldr r0, =format_pis @ "Enter the number of strings :\n"
        mov r1, r5
        bl printf

        @ Get the string
        @ scanf("%*c%[^\n]", sp)
        sub sp, sp, #200	@ Makes space in stack for string x(for 200 charactors)
        ldr r0, =format_iss @ "%d"
        mov r1, sp
        bl scanf

        mov r6, sp		@ Save address of the string x in r6

        @ Print the entered string in reverse

        @ prinf("Output string %d is :\n", i)
        ldr r0, =format_osp
	    mov r1, r5
	    bl printf

        @ Set j=0 for strlength (j)
        mov r7, #0		@ j = 0

        strlength:
            add r2, r6, r7		@ address of x[j] in r2
            ldrb r3, [r2, #0]	@ r3 = x[j]
            cmp r3, #0
            beq strlExit		@ Exit loop if x[j] == 0
            add r7, r7, #1		@ j++
            b strlength			@ iterate loop

        strlExit:
            sub sp, sp, r7		@ Make space in stack for reversed string y
            sub sp, sp, #1		@ Additional byte to store NULL character
            mov r8, sp			@ r8 = address of reversed string y
                
            sub r2, r2, #1		@ Bring r2 to address of last character of x

            @ Set k=0 for reverse the string
            mov r9, #0			@k = 0

        reverseString:
            cmp r9, r7		    @ Compare r9 (k) with string length (j)
            beq reverseExit		@ Exit loop if k == j
            ldrb r3, [r2, #0]	@ r3 = character in address of r2
            add r10, r8, r9		@ address of y[k] in r8
            strb r3, [r10, #0]	@ store r3 in y[k]
            
            add r9, r9, #1		@ k++
            sub r2, r2, #1		@ Move r2 one character left in string x
            b reverseString		@ Iterates loop

        reverseExit:
            @ Adding NULL character at the end of reversed string y
            sub r6, r6, #1
            mov r9, #0
            strb r9, [r6, #0]
            
            @ Print the reversed string
            @ printf("%s\n", r1)
            ldr r0, =format_ospp
            mov r1, r8
            bl printf
            
            @ Popping reversed string y from stack
            add sp, sp, r7
            add sp, sp, #1      @ Pop additional byte of NULL character
            
            @ Pop original string from stack
            add sp, sp, #200	
            
            add r5, r5, #1		@ i++
            b strLoop			@ Iterates loop


error:
	@ Error message for negative n
	ldr r0, =format_error
	bl printf


exit:
	add sp, sp, #4
	
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr
	

    .data	@ data memory
format_pnos: .asciz "Enter the number of strings :\n"
format_snos: .asciz "%d"
format_error: .asciz "Invalid number\n"
format_pis: .asciz "Enter input string %d :\n"
format_iss: .asciz "%*c%[^\n]"
format_osp: .asciz "Output string %d is :\n"
format_ospp: .asciz "%s\n"

