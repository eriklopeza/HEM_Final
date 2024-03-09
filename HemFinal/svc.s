		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
_syscall_table_init
	; AFTER ADRESS FOUND send it to its corosponding k func 
	;  FIGUREOUT ACTION AND 
	; compare if 0 is first run through 
	; if not then find action and send to its k function
	; if equal than store there in this case in sysmalloc
  LDR     r0, =SYSTEMCALLTBL   ; Load the base address of the system call table

    LDR     r1, =SYS_EXIT         ; Load the address of SYS_EXIT
    STR     r1, [r0, #0]          ; Store SYS_EXIT address at index 0 in the table
    LDR     r1, =SYS_ALARM        ; Load the address of SYS_ALARM
    STR     r1, [r0, #4]          ; Store SYS_ALARM address at index 4 in the table
    LDR     r1, =SYS_SIGNAL       ; Load the address of SYS_SIGNAL
    STR     r1, [r0, #8]          ; Store SYS_SIGNAL address at index 8 in the table
    LDR     r1, =SYS_MEMCPY       ; Load the address of SYS_MEMCPY
    STR     r1, [r0, #12]         ; Store SYS_MEMCPY address at index 12 in the table
    LDR     r1, =SYS_MALLOC       ; Load the address of SYS_MALLOC
    STR     r1, [r0, #16]         ; Store SYS_MALLOC address at index 16 in the table
    LDR     r1, =SYS_FREE         ; Load the address of SYS_FREE
    STR     r1, [r0, #20]         ; Store SYS_FREE address at index 20 in the table
    MOV     pc, lr                ; Return from the subroutine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
	; Implement by yourself

	IMPORT _signal_handler
	IMPORT _timer_start
	IMPORT _kalloc
	IMPORT _kfree


	CMP R7, #1
	BEQ _timer_start
	
	CMP R7, #2
	BEQ _signal_handler
	
	CMP R7, #3
	BEQ _kalloc
	
	CMP R7, #4
	BEQ _kfree


	; BL      _syscall_table_init                    ; Branch to the system call function
	 MOV		pc, lr			
		
		END


		
