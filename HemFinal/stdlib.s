		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		
        MOV     r2, #0          ; Set r2 to 0 (for zero-initialization)

loop    
		CMP     r1, #0          ; Check if n is zero
        BEQ     bz_done            ; If so, exit the loop  

        STRB    r2, [r0], #1    ; Store zero byte at the memory location pointed by r0, and increment r0
        SUBS    r1, r1, #1      ; Decrement n
        BNE     loop            ; If n is not zero, repeat the loop

bz_done   
			
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to
;	src	- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest 

		EXPORT	_strncpy
_strncpy
		
		MOV R5, R2 ; r2 = 40, r1 = a r0 = b
		
	
cpy_loop
		LDRB R4, [R1], #1
		STRB R4, [R0], #1 
		SUBS R5, R5, #1
		BEQ cpy_done
	
		B cpy_loop	

cpy_done
	;MOV R2,R1
	
	MOV		PC, LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
			EXPORT	_malloc
_malloc
		; save registers
		STMDB sp!, {r1-r12, lr}	; save all registers that could be changed
		
		; r0 = size
		
		; set the system call # to R7
	;	MOV R1, 
		MOV	r7, #0x4
	    SVC     #0x4
		MOV R0,R0
		;STRB     R4, [R4, R0] ; allocate bytres
		; resume registers
		
		LDMIA sp!, {r1-r12, lr} ; load back registers and return address

		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; save registers
		STMDB sp!, {r1-r12, lr}	; save all registers that could be changed

		; set the system call # to R7
		MOV	r7, #0x5
        	SVC     #0x5
		
		; resume registers
		LDMIA sp!, {r1-r12, lr} ; load back registers and return address
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; save registers
		STMDB sp!, {r1-r12, lr}	; save all registers that could be changed
		; set the system call # to R7
		MOV	r7, #0x1
        	SVC     #0x0
		; resume registers	
		LDMIA sp!, {r1-r12, lr} ; load back registers and return address

		MOV		pc, lr		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; save registers
		STMDB sp!, {r1-r12, lr}	; save all registers that could be changed
		; set the system call # to R7
		MOV	r7, #0x2
        	SVC     #0x0
		; resume registers
		LDMIA sp!, {r1-r12, lr} ; load back registers and return address

		; not sure how to return properly
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END			
