;--------------------------------------------------
; floppy disk driver utilizing ISA DMA
; to load kernel into memory after long mode is initialized

[bits 64]

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
