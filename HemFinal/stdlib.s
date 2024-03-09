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
		STMFD	sp!, {r1-r12,lr}
		
        MOV     r2, #0          ; Set r2 to 0 (for zero-initialization)
		MOV R4,R0		; DUMMY STORE
loop    
        SUBS    r1, r1, #1      ; Decrement n
        BMI     bz_done            ; If so, exit the loop  
        STRB    r2, [r0], #1    ; Store zero byte at the memory location pointed by r0, and increment r0
        B     loop            ; If n is not zero, repeat the loop

bz_done   
		MOV R0, R4
		LDMFD	sp!, {r1-r12,lr}

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
		STMFD	sp!, {r1-r12,lr}

		MOV R5, R0 ; r2 = 40, r1 = a r0 = b, R4 = 2 R1 VAL, R5= CPY OF ADRESS
		
	
cpy_loop
        SUBS    r2, r2, #1      ; Decrement n
		BMI cpy_done

		LDRB R4, [R1], #1
		STRB R4, [R0], #1 
		
		CMP R4, #0
		BEQ cpy_done	; CHECKS FOR IF AT END VIA THE /0
		B cpy_loop	

cpy_done
	MOV R0,R5
	LDMFD	sp!, {r1-r12,lr}
 
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
		STMFD sp!, {r1-r12, lr}	; save all registers that could be changed
		
		; r0 = size
		
		; set the system call # to R7
	;	MOV R1, 
		MOV	r7, #3
	    SVC     #0x0
		; resume registers
		
		LDMFD sp!, {r1-r12, lr} ; load back registers and return address

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
		STMFD sp!, {r1-r12, lr}	; save all registers that could be changed

		; set the system call # to R7
		MOV	r7, #4
        SVC     #0x0
		
		; resume registers
		LDMFD sp!, {r1-r12, lr} ; load back registers and return address
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
		STMFD sp!, {r1-r12, lr}	; save all registers that could be changed
		; set the system call # to R7
		MOV	r7, #1
        SVC     #0x0
		; resume registers	
		LDMFD	sp!, {r1-r12,lr}	; resume registers

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
		STMFD sp!, {r2-r12, lr}	; save all registers that could be changed
		; set the system call # to R7
		MOV	r7, #2
        SVC     #0x0
		; resume registers	
		LDMFD	sp!, {r2-r12,lr}	; resume registers

		MOV		pc, lr		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _setZeroRegisters( )
;Parameters
;  none
; Return value
;   none
; Fun program that sets all registers to 0 EXTRA CREDIT
_setZeroRegisters

		MOV R1, #0
		MOV R2, #0
		MOV R3, #0
		MOV R4, #0
		MOV R5, #0
		MOV R6, #0
		MOV R7, #0
		MOV R8, #0
		MOV R9, #0
		MOV R10, #0
		MOV R11, #0
		MOV R12, #0
	
	MOV		pc, lr	
		
		END			
