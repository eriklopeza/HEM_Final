		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14			; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER     EQU		0x20007B84		; Address of a user-given signal handler function	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
; void timer_init( )
		EXPORT		_timer_init
_timer_init
	;; Implement by yourself
	LDR		R1, =STCTRL				
	LDR		R0, =STCTRL_STOP		
		STR		R0, [R1]	; systick stops			
	    
    LDR     R0, =STRELOAD_MX   ; the time count is 1 sec
	LDR		r1, =STRELOAD		; systick reload address	
		STR     R0, [R1]        ; the value of STRELOAD also the max
	
		MOV		pc, lr		; return to Reset_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
	;; Implement by yourself
	LDR R1, =SECOND_LEFT	
	LDR R7, [R1]		
		STR R0, [R1]		; Store the value of the timer parameter (R0) into SECOND_LEFT memory location
  	
	LDR R2, =STCTRL		
	LDR R3, =STCTRL_GO		;control value for timer start into register R3
		STR R3, [R2]		
	
  	
	LDR R4, =STCURRENT
	MOV R5, #0x0			
		STR R5, [R4]		; Store the value of 0x0 into STCURRENT register to reset the timer counter

		
	MOV R0, R7	
	MOV		pc, lr		; return to SVC_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
	;; Implement by yourself

	LDR		R1, =SECOND_LEFT	
	LDR		R2, [R1] 		    ; Load the value stored in SECOND_LEFT memory location into register R2
	SUB 	R2, R2, #1		
	STR 	R2, [R1]     ; Store the decremented value back into SECOND_LEFT memory location to decrease the time
	
	; if we dont have no more seconds left then we are done
	CMP 	R2, #0
	BNE		done_u
	
	LDR		R3, =STCTRL
	LDR		R4, =STCTRL_STOP
	STR		R4, [R3]     ; Store the value of STCTRL_STOP into the STCTRL register to stop the timer
	
	LDR 	R5, =USR_HANDLER 
	LDR		R7, [R5]     ; Load the value stored in USR_HANDLER memory location into register R7

	; save all registers
	STMFD	sp!, {r1-r12,lr}	
	; this should be sig handler	
	BLX 	R7
	; load all registers
	LDMFD	sp!, {r1-r12,lr}		

done_u
	MOV		pc, lr		; return to SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler
_signal_handler
	;; Implement by yourself
		CMP	R0, #SIGALRM
		BNE	sig_done	;if the alarm is not at the given val then we are done
		LDR	R3, =USR_HANDLER
		LDR	R2, [R3] 		; Load the value stored in USR_HANDLER memory location into register R2	
		STR	R1, [R3]			; Store the value of R1 into the USR_HANDLER memory location

	
sig_done
		MOV	R0, R2
		MOV pc, lr		; return to Reset_Handler
		
		END		
