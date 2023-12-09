;--------------------------------------------------
; floppy disk driver utilizing ISA DMA
; to load kernel into memory after long mode is initialized

[bits 64]

%include "DMA_driver.asm"

;--------------------------------------------------
; enumeration declarations

; floppy registers
STATUS_REG_A:		equ 0x3f0
STATUS_REG_B:		equ 0x3f1
DIG_OUTPUT:		equ 0x3f2
MAIN_STATUS_REG:	equ 0x3f4	; read-only
DATARATE_SEL:		equ 0x3f4	; write-only
DATA_FIFO:		equ 0x3f5
DIG_INPUT:		equ 0x3f7	; read-only
CONFIG_CONTROL:		equ 0x3f7	; write-only

; Digital Output Reg (DOR) flag def
; bits 0,1 to select drive number to access
MOTD:			equ 1<<7	; drive 3 motor on
MOTC:			equ 1<<6	; drive 2 motor on
MOTB:			equ 1<<5	; drive 1 motor on
MOTA:			equ 1<<4	; drive 0 motor on
IRQ_ON:			equ 1<<3	; enable IRQ (required for DMA)
RESET:			equ 1<<2	; clear=reset, set=normal operation

; Datarate select
; setting datarate reg also sets config_control
DR_500:			equ 0		; 500Kpbs, used by 1.44M, 1.2M floppy
DR_1M:			equ 3		; 1Mbps, user by 2.88M floppy

; Main Status Reg (MSR) description
;
;	|  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
;	| MRQ | DIO | NDMA| BUSY| ACTD| ACTC| ACTB| ACTA|
;
; MRQ = 1 when FIFO is read
; DIO = 1 (write expected), DIO = 0 (read expected)
; NDMA = 0 (DMA), NDMA = 1 (no-DMA)
; BUSY = 1 (controller is busy)
;
; ACTA,ACTB,ACTC,ACTD = 1 (drive is seeking)

floppy_write_command:
;-------------------------------------------------
; send command to floppy FIFO
; param1: command
	push rbp
	mov rbp, rsp			; store stack pointer

	call .MSR_wait			; wait until FIFO is available

	mov rax, [rbp+16]		; retrieve command from stack
	out DATA_FIFO, rax		; send command to I/O port

	mov rsp, rbp			; reset stack
	pop rbp
	
.MSR_wait:
	in rax, MAIN_STATUS_REG		; read MSR from I/O
	test rax, 0x80			; check if MRQ == 1
	jz .MSR_wait
	ret

floppy_read_data:
;--------------------------------------------------
; read data from FIFO buffer
; param1: address to store result
	push rbp
	mov rbp, rsp			; store stack pointer

	call .MSR_wait			; wait until FIFO available

	in rax, DATA_FIFO		; grab byte from FIFO
	mov rbx, [rbp+16]
	mov byte[rbx], rax		; store value at address

	mov rsp, rbp			; reset stack
	pop rbp

.MSR_wait:
	in rax, MAIN_STATUS_REG		; read MSR from I/O
	test rax, 0x80			; check if MRQ == 1
	jz .MSR_wait
	ret
