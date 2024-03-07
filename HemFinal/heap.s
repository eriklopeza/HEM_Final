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
	LDR     sp, =HEAP_TOP
	
 ; Initialize (MCB)
    LDR     r0, =MCB_TOP       ; Load address of MCB top
    LDR     r1, =MCB_BOT       ; Load address of MCB bottom
    MOV     r2, #0             ; Clear MCB entries
	
_init_fill_loop	
	STR     r2, [r0], #MCB_ENT_SZ  ; Store zero to MCB entry and increment pointer
    CMP     r0, r1            ; Check if reached MCB bottom
    BNE     _init_fill_loop     ; If not, continue loop
	
	MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	;; Implement by yourself
	; R0 = BYTES TO ALLOCATE

		MOV 	R7, R0
			
		LDR     sp, =HEAP_TOP	
		LDR		r2, [r0]   
		
		CMP		r0, #0              ; Check if size is zero
		BEQ     done      ; If not, exit

		
		; Implement memory allocation logic here
		
		; Example: Allocate memory from the heap
		LDR		r0, =MCB_TOP       ; Load heap top address
		LDR		R1, =MCB_BOT       ; Load heap top address
		
		
		STR		r0, [r7]            ; Update heap top
		;LOOP
		MOV		r7, r8              ; Return allocated memory address in r0
		
done
		POP		{pc}                ; Restore return address and return

fail
		MOV		r0, #INVALID        ; Return invalid address
		B		done          ; Exit
	
	MOV		pc, lr
	 	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
	;; Implement by yourself
		MOV		pc, lr					; return from rfree( )
		
		END
