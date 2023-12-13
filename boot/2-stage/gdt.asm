;--------------------------------------------------
; constructs global descriptor tables for bootloader

; Access Bits
PRESENT: 	equ 1<<47
USER_D:		equ 1<<46 | 1<<45	; for user decriptor (Privilege level 3)
SYS_D:		equ 1<<44
EXEC:		equ 1<<43
RW:		equ 1<<41	

; upper 4 bits of limit
UPP_LIM:	equ 1<<51 | 1<<50 | 1<<49 | 1<<48

; Flag Bits
GRAN:		equ 1<<55
DB:		equ 1<<54
LONGM:		equ 1<<53

; TSS values
RSP0:		equ 0x10000		; must be equal to PM_STACK in mbr.asm 
IST6:		equ 0

;--------------------------------------------------
; 32-bit (Protected mode) GDT
gdt_32:
	dq 0x0
.code: equ $ - gdt_32
	dq GRAN | DB | UPP_LIM | PRESENT | SYS_D | EXEC | RW | 0xffff			; FLAGS=0xC, ACCESS= 0x9A
.data: equ $ - gdt_32
	dq GRAN | DB | UPP_LIM | PRESENT | SYS_D | RW | 0xffff				; FLAGS=0xC, ACCESS=0x92
.pointer:
	dw .pointer - gdt_32 - 1
	dd gdt_32

;--------------------------------------------------
; 64-bit (Long mode) GDT
gdt_64:
	dq 0x0
.code: equ $ - gdt_64
	dq GRAN | LONGM | UPP_LIM | PRESENT | SYS_D | EXEC | RW | 0xffff		; FLAGS=0xA, ACCESS=0x9A
.data: equ $ - gdt_64
	dq GRAN | DB | UPP_LIM | PRESENT | SYS_D | RW | 0xffff				; FLAGS=0xC, ACCESS=0x92
.user_code: equ $ - gdt_64
	dq GRAN | LONGM | UPP_LIM | PRESENT | USER_D | SYS_D | EXEC | RW | 0xffff	; FLAGS=0xA, ACCESS=0xFA
.user_data: equ $ - gdt_64
	dq GRAN | DB | UPP_LIM | PRESENT | USER_D | SYS_D | RW | 0xffff			; FLAGS=0xC, ACCESS=0xF2
.tss: equ $ - gdt_64
	dw tss_entry.tss_limit
	dw 0					; base, filled in by tss_pack in stage-2.asm 
	db 0					; base, filled in by tss_pack
	db 0x89					; access byte: P=1 | DPL=0 | 0 | Type=9
	db 0x0f & tss_entry.tss_limit >> 32	; FLAGS=0, upper byte of tss_limit
	db 0					; base, filled in by tss_pack
	dd 0					; base, filled in by tss_pack
	dd 0					; reserved
.pointer:
	dw .pointer - gdt_64 - 1
	dd gdt_64

;--------------------------------------------------
; initial TSS for long mode
; functions to provide IST6 to allow kernel code to be read into high memory for execution
; will be replaced during kernel setup
tss_entry:
	dq 0		; RESERVED
	dq RSP0		; rsp0 value
	times 2 dq 0	; fill rsp1, rsp2
	dq 0		; RESERVED
	times 5 dq 0	; fill ist1, ist2, ist3, ist4, ist5
	dq IST6		; ist6 value
	dq 0		; fill ist7
	dq 0		; RESERVED
	dd 0		; RESERVED
	dd 0		; IOPB offset
.tss_limit: equ $ - tss_entry
