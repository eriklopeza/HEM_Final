		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      	; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512			; 2^9 = 512 entries
	
INVALID		EQU		-1			; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
	;; Implement by yourself

 ; Initialize (MCB)
    LDR     r0, =MCB_TOP       ; Load address of MCB top
    LDR     r1, =MAX_SIZE       ; Load address of MCB size
	STR		R1, [R0]
    MOV     r2, #0             ; Clear MCB entries
	
	LDR 	R0, =MCB_TOP
	ADD		R0, #4		; 0x20006804
	LDR		R1, =0x20006C00 ;0x20006C00

	CMP 	R0, R1 ; at  max?
	BGE		fin
	
	STR		R2, [R0]			; clear mcb
	ADD		R0, R0, #1			
	
	STR		R2, [R0]
	
	ADD		R0, #2		; A
	B 		fin
	
fin
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	;; Implement by yourself
		PUSH	{lr}
		CMP	R0, #32 ; if the 32 bit limit is >=
		BGE	pre_post_r
		
		MOV	R0, #32

pre_post_r
									
		LDR	R1, =MCB_TOP			; R1 == MCB_TOP == left
		LDR	R2, =MCB_BOT			; R2 == MCB_BOT == right
		
		BL	_ralloc
		 
		POP		{lr}
		MOV		R0, R12
		
		MOV		pc, lr
		
_ralloc		
			; save reg
			PUSH	{lr}
			
			SUB	R3, R2, R1			
			ADD	R3, R3, #MCB_ENT_SZ			; R3 == entire
			
			ASR	R4, R3, #1			; R4 == half
			ADD	R5, R1, R4			; R5 == midpoint
			
			LSL	R6, R3, #4			; R6 == act_entire_size
			LSL	R7, R4, #4			; R7 == act_half_size
			
			MOV	R12, #0			; R12 == heap_addr
		
		; do we need mem aloc?
		CMP	R0, R7
		BGT	enter_mem ; dont need to allocate so we just enter it
		
		PUSH	{r0-r7}		; save registers
		
		SUB	R2, R5, #MCB_ENT_SZ
		BL	_ralloc
		
		POP		{r0-r7}		; resume registers
		
		CMP	R12, #0 ; 0x0
		BEQ	shift_heap
		
		LDR	R8, [R5]			; R8 == mem[midpoint]
		AND R8, R8, #1   ;0x01
		
		CMP	R8, #0
		BEQ	done_addr
		B	r_done
		
shift_heap
		PUSH	{r0-r7}		; save registers
		MOV	R1, R5
		BL	_ralloc
		POP		{r0-r7}		; resume registers
		B 	r_done
		
		;done ad
enter_mem
		LDR 	R8, [R1]			; R8 == mem[left]
		AND 	R8, R8, #1 ; 0x01
		CMP		R8, #0 
		BNE		negi			; return invalid
		
		LDR		R8, [R1]			; R8 == mem[left]
		CMP		R8, R6
		BLT		negi			; return invalid
		
		ORR		R8, R6, #1			; *(short *)&array[ m2a( left ) ] = act_entire_size | ; this chanmged 0x01;
		STR		R8, [R1]
		
		
		
		LDR		R8, =MCB_TOP			; R8 == MCB_TOP
		SUB		R1, R1, r8			; left -= mcb_top
		LSL		R1, R1, #4			; left *= 16
		
		LDR		R10, =HEAP_TOP			; R10 == HEAP_TOP
		ADD		R10, R10, R1			; heap_top += left
		
		MOV		R12, R10			; heap_addr = heap_top + ( left - mcb_top ) * 16
		B		r_done
			
done_addr
		STR	R7, [R5]
		B	r_done
		
negi
		MOV	R12, #0
r_done
		POP		{lr}
		BX		LR
		
		MOV		pc, lr
	 	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
		;; Implement by yourself
		PUSH	{lr}
		
  		LDR		R1, =HEAP_TOP				; Load the HEAP_TOP value into R2
    	LDR		R2, =HEAP_BOT				; Load the HEAP_BOT value into R3	
		LDR  	R4, =MCB_TOP     			; Load the top of the MCB
		
		MOV		R3, R0					; Move pointer address into register R1

		; If statement
	    CMP  	R3, R1					; If address is smaller than HEAP_TOP
    	BLT  	nullA			; Return Null
   	 	
		CMP  	R3, R2					; If address is larger than HEAP_BOT
    	BGT  	nullA			; Return Null

		 ; Compute the MCB address

		
    	SUB  	R5, R3, R1      			; Subtract HEAP_TOP from the pointer
    	ASR  	R5, R5, #0x4       			; Divide the difference by 16 (logical shift right by 4 bits)
    	ADD  	R5, R4, R5       			; Add the result to MCB_TOP to get the MCB address

		; Call the _rfree function 
		MOV		R0, R5
		
		PUSH 	{R1-R12}
		
		BL   	_rfree 
		POP		{R1-R12}
		
		CMP  	R0, #0x0           			; Check if MCB address passed into _rfree() returns 0	
		BEQ		nullA
		POP		{LR}
		MOV		pc, lr
	
_rfree	
		PUSH	{lr}
											; R0 = MCB_addr
  		LDR 	R1, =MCB_TOP				; R1 = MCB_TOP
  		SUB		R2, R0, #R1		 		; R2 = mcb_offset -> mcb_addr - mcb_top
		LDR 	R3, [R0]                 ; R3 = mcb_contents
		ASR		R4, R3, #4		 		; R4 = mcb_chunk
		LSL		R5, R3, #4		 		; R5 = my_size
		LDR		R7, =MCB_BOT
		
		STR		R3, [R0]
  		SDIV 	R6, R2, R4
    	AND 	R6, R6, #1
      	CMP 	R6, #0			 		; Line 146 in heap.c
		BNE		odd		
		
		; Even Case (CORRECT)
		ADD 	R6, R0, R4
  		
  		CMP		R6, R7					; Line 150 in heap.c
		BGE		doneZ
		
    	LDR		R7, [R6]				; R7 = mcb_buddy
							  		
    	AND		R8, R7, #1				; Line 158 
      	CMP		R8, #0
		BNE		done
  
  		ASR 	R7, R7, #5
    	LSL		R7, R7, #5				; Line 162
		CMP		R7, R5
  		BNE		done				; Line 163

		MOV		R8, #0
      	STR		R8, [R6]				; Line 168
		LSL		R5, #1				; my_size *= 2
  		STR		R5, [R0]
		 
		BL		_rfree					; Recursion (line 178)
		B		done
	
odd								; Line 183
     	SUB		R6, R0, R4				; R6 = mcb_addr - mcb_chunk
       	CMP		R1, R6
	 	BGT		doneZ
		
     	LDR		R7, 
		[R6]				; R7 = mcb_buddy
       	
		AND		R8, R7, #1				; Line 195
  		CMP		R8, #0
    	BNE		done

  		ASR 	R7, R7, #5
    	LSL		R7, R7, #5				; Line 199
      	CMP		R7, R5
		BEQ	 	done				; Line 200
		
		MOV		R9, #0 
		STR		R8, [R0]
    	LSL		R5, #1				; my_size *= 2
		STR		R5, [R6]				; Line 207

		MOV		R0, R6 
		BL		_rfree					; Recursion (line 216)
		B		done
		
doneZ
  		MOV 	R0, #0	

done
  		POP	{lr}
		BX		lr					; return from rfree( )

nullA
		MOV  	R0, #0           			; Set the return value to NULL
		POP		{LR}
		MOV		pc, lr						
	
		END
