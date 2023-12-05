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
;.tss: equ $ - gdt_64
;	dq |0x007e
.pointer:
	dw .pointer - gdt_64 - 1
	dd gdt_64
