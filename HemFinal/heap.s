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


 ; Initialize (MCB)
    ; Load address of MCB top into register r0
    LDR     r0, =MCB_TOP       
	; Load address of MAX_SIZE into register r1
    LDR     r1, =MAX_SIZE   
    ; Store the value of MAX_SIZE into the memory location pointed to by MCB_TOP    
	STR		R1, [R0]
	; Clear the MCB entries by Initialize register r2 to 0
	MOV     r2, #0             
	
	LDR 	R0, =MCB_TOP
	; Add 4 bytes to the address in R0 ( MCB entries are 4 bytes each)
	ADD		R0, #4		; 0x20006804
	; Load the base address of the maximum address range into register R1
	LDR		R1, =0x20006C00 ;0x20006C00

	; Compare the current address (R0) with the maximum address range (R1)
	; & If the current address is at or beyond the maximum address range, branch to fin
	CMP 	R0, R1 ; at  max?
	BGE		fin
	
	; Inside the loop to clear MCB entries
	; & Store the value in register R2 (which is 0) into the memory location pointed to by the current address (R0)
	; Increment the address stored in R0 by 1 so we can make more space to store 
	; 0 for more space, we do it twice for 
	STR		R2, [R0]			
	ADD		R0, R0, #1			
	
	STR		R2, [R0]
	; Increment the address stored in R0 by 2
	ADD		R0, R0, #2		
	B 		fin
; finish or end of init	
fin
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
		;Store registers
		PUSH	{lr}
		; if the R0 bit limit is >= 32 then call pre_post_r to do the
		; pre and post ralloc sequence
		CMP	R0, #32 
		BGE	pre_post_r
		
		MOV	R0, #32

pre_post_r
		;The left and right adresses are stored respectivly  							
		LDR	R1, =MCB_TOP			
		LDR	R2, =MCB_BOT			
		
		BL	_ralloc
		
		;restore the lr and put the heap register we chose as the adress
		; to return
		POP		{lr}
		MOV		R0, R12
		
		MOV		pc, lr
		
_ralloc		
			; save the lr 
			PUSH {lr}
			
			; In the tabbed section we systematicly stored the parts of mcb that are needed
			; the entire adress of the space of the MCB in r3
			SUB	R3, R2, R1			
			ADD	R3,  #MCB_ENT_SZ			
			
			;half adress of the whole of the MCB in r4 right and r5 is left
			ASR	R4, R3, #1			
			ADD	R5, R1, R4			
			; the whole size of the act is found and put in r6 while its half is put in r7
			LSL	R6, R3, #4			
			LSL	R7, R4, #4			
			
			; R12 was deemed to be our heap location so we cleared its space for memory
			MOV	R12, #0			
		
		; If we do have space small enough to enter memory then enter it
		CMP	R0, R7
		; else shift the memory right and find avalible space to enter the memory in 
		BGT	enter_mem 
		
		; we save registers for later
		PUSH	{r0-r7}		
		
		; subtract the mcb whole size from the right side of the mcb and make it the new bottom
		SUB	R2, R5, #MCB_ENT_SZ
		BL	_ralloc
		
		; we restore the registers and finish
		POP		{r0-r7}				

		; if heap is null then shift over
		CMP	R12, #0x0
		BEQ	shift_heap
		
		; the value of the midpoint of the memory is put in r8 and do a bitwise operation of  0x01
		LDR	R8, [R5]			
		AND R8, #0x01
		
		;if r8 is empty then get the heap address and return it
		CMP	R8, #0
		BEQ	done_addr
		B	r_done
		
shift_heap
		; we save registers for later
		PUSH	{r0-r7}		
		; shift the heap top right so we can call ralloc for recursion 
		; this helps later by finding a space that is avalible inside heap
		MOV	R1, R5
		BL	_ralloc
		; we restore the registers and finish
		POP		{r0-r7}		
		B 	r_done
		
		;done ad
enter_mem
		; This method Loads and checks if memory block is free
		; then checks if memory block is within bounds
		; then sets memory block status and finally update heap pointers
		
		LDR 	R8, [R1]			; R8 has the left value of the memory 
		AND 	R8,  #0x1 			; Then perform a bitwise operation with 0x1 to find the least significant bit
									; checking if the memory block is in use
		CMP		R8, #0 ; if its still empty then we  have an invalid case 
		BNE		negi			
		
		LDR		R8, [R1]			; R8 has the left value of the memory
		CMP		R8, R6				; and if it is the the whole size of act then invalid
		BLT		negi			; return invalid
								
		ORR		R8, R6, #0x1	;Set status flag for memory block
		STR		R8, [R1]		; Perform a bitwise OR operation of R6 and 0x1
								; This operation sets the  flag or status bit in a memory block header. 
								; spesificly array(m2a(left)) = act size
								
		LDR		R8, =MCB_TOP			
		SUB		R1, R8			; the left side gets - from mcb top and multiplied by 16
		LSL		R1, R1, #4			
		
		LDR		R10, =HEAP_TOP			
		ADD		R10, R1			; the heap top gets added to the left side.
		
		MOV		R12, R10			; This way we have the top of the heap address be the top of the heap plus the left address minus the mcb top time 16
									; in order to have the acurate adress for the top of the new heap
		B		r_done
			
done_addr
		;if r8 is empty then get the heap address and return it
		; otherwise this happens regardless
		STR	R7, [R5]
		B	r_done
		
negi
		; if we have a negitive value its invalid so we clear heap 
		MOV	R12, #0
r_done 
		; return
		POP		{lr}
		BX		LR
		
		MOV		pc, lr
	 	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree 
		;; Implement by yourself
			;save register 
			PUSH	{lr}
			
			;stored addresses in registers
			LDR		R1, =HEAP_TOP				
			LDR		R2, =HEAP_BOT					
			LDR  	R4, =MCB_TOP     			
	
		; Pointer copy for future referance
		MOV		R3, R0			

		; If the adress of top is out of boundes for either the heap top
	    CMP  	R3, R1					; If address is smaller than HEAP_TOP
    	BLT  	nullA			
   	 	; or the heap bottom return null
		CMP  	R3, R2					
    	BGT  	nullA			

		; To find the MCB address we subract the heap top to the pointer
		
    	SUB  	R5, R3, R1      			; Subtract HEAP_TOP from the pointer
    	; Divide it by 4 bits  
		ASR  	R5, #4      
		; add the mcb top to get the address
    	ADD  	R5, R4        			

		; Mcb becomes new pointer
		MOV		R0, R5
		
		;save registers
		PUSH 	{R1-R12}
		; call rfree with the new pointer
		BL   	_rfree 
		;resume registers
		POP		{R1-R12}
		; If the mcb address is null then we have an error return null
		CMP  	R0, #0           			
		BEQ		nullA
		POP		{LR}
		MOV		pc, lr
	
_rfree	
			;save registers
			PUSH	{lr}
			
			; registers are loaded for future used adresses
			LDR R1, =MCB_TOP				; mcb top
			SUB R2, R0, R1		 		; mcb offfset
			LDR R3, [R0]                 ; mcb value
			ASR R4, R3, #4		 		; cmcb hunk
			LSL R5, R3, #4		 		; size
			LDR R7, =MCB_BOT			; mcb bottom for later	
		STR R3, [R0]	
		    ; Calculate buddy index
  		SDIV R6, R2, R4      
    	AND R6, #1  ; Check if buddy index is odd
		
      	CMP R6, #0	; Compare if buddy index is not equal to 0		
		BNE odd		
		
		; if we haved an EVEN buddy index caluclaute for that
		; Calculate address of buddy MCB
		ADD R6, R0, R4
		; Compare if address of buddy MCB is greater than or equal to MCB_BOT if it is = or greater then, program done and zero out
  		CMP R6, R7					
		BGE doneZ
		
		; Load buddy MCB value into R7
    	LDR R7, [R6]	
		; Extract status flag from buddy MCB value
    	AND R8, R7, #1	
		; Compare if status flag is not equal to 0 if it's not = then program is done
      	CMP R8, #0
		BNE done
		
		; Calculate new size for merged memory blocks
  		ASR R7, #5
    	LSL R7, #5		
		; Compare if new size is not equal to current size if not then we are done
		CMP R7, R5
  		BNE done				

		; Set status flag of buddy MCB to 0
		MOV R8, #0
      	STR R8, [R6]				
		; Double the size of memory block
		LSL R5, #1				; my_size *= 2
  		STR R5, [R0]
		; Recur here until we reach the end of the size
		BL _rfree					
		B done
	
odd				
		; ODD is very similar to even
		; find the mcb address after minusing to the mcb chunk
     	SUB R6, R0, R4			
        ;Compare if MCB_TOP is greater than the calculated addressif it is  zero out and finish
       	CMP R1, R6
	 	BGT doneZ
		
	    ; Load buddy MCB value into R7
     	LDR R7, [R6]	
		; Extract status flag from buddy MCB value and Compare if status flag is not equal to 0. If it is then we are done
		AND R8, R7,#1				
  		CMP R8, #0
    	BNE done
		
	    ; Calculate new size for merged memory blocks
  		ASR R7,#5
    	LSL R7,#5				;If the
      	CMP R7, R5
		BNE done				
		
		MOV R8,#0 
		STR R8, [R0]
    	LSL R5,#1				; my_size *= 2
		STR R5, [R6]				; Line 207

		MOV		R0, R6 
		BL		_rfree					; Recursion 
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
