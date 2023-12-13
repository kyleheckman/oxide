;--------------------------------------------------
; data structure locations in memory
;
;	0x104000 +-------------------------+
;		 | PML4, PDPT, PDT, PT
;	0x100000 +-------------------------+
;		 |	/	/	/
;		 |	\	\	\
;	0x10000  +-------------------------+
;		 | Stack
;		 |
;	0x7e00   +-------------------------+
;		 | Boot Sector 1
;	0x7c00   +-------------------------+
;		 | Boot Sector 2
;	0x7800   +-------------------------+
;		 |	/	/	/
;		 +-------------------------+


[org 0x7c00]
[bits 16]

;--------------------------------------------------
; entry point for bootloader
;_start:
	;--------------------------------------------------
	; clean segment registers, far jump to starting point
	; to clear CS
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp 0x0000:boot_init

%include "gdt.asm"

boot_init:
	;--------------------------------------------------
	; initialize stack, beginning at addr 0x8000
	; stack will be relocated after PM is enabled
	mov bp, 0x8000
	mov sp, bp
	
	;--------------------------------------------------
	; store drive number in [boot_drive]
	mov [boot_drive], dl

	;--------------------------------------------------
	; disable text cursor
	mov ah, 0x01
	mov ch, 0x3f
	int 10h

	;--------------------------------------------------
	; read bootloader second stage into memory
	; second stage initializes long mode and calls kernel
	mov ah, 0x2		; INT13h READ
	mov al, SECTORS_TO_READ
	mov ch, 0
	mov cl, 0x2		; starting sector
	mov dh, 0
	mov dl, [boot_drive]
	mov bx, ST2_OFFSET	; set read buffer (ES:BX) to addr 0x1000

	int 13h			; call BIOS interrupt

	jc .read_error		; check if INT13h executed w/o error
	cmp al, SECTORS_TO_READ
	jne .sec_read_error	; check correct number of sectors were read

	;--------------------------------------------------
	; load GDT, far jump to PM initialization
	cli			; disable interrupts
	lgdt [gdt_32.pointer]	; load GDT for PM
	mov eax, cr0		; set CR0[0] "PM"
	or eax, 0x1
	mov cr0, eax
	jmp gdt_32.code:init_pm

.read_error:
;	push read_err_str
;	call print_string
;	pop dx
	hlt

.sec_read_error:
;	push sec_err_str
;	call print_string
;	pop dx
	hlt

;print_string:
;	push bp			; store initial base ptr
;	mov bp, sp
;	mov si, [bp+4]		; load param 'string' from stack into SI
;	mov ax, 0xb800
;	mov es, ax
;	mov di, 0
;	mov dx, 0xa0
;	imul dx, [LINE_OFF]
;	add di, dx
;	mov ah, 0x1f
;	lodsb
;.loop:
;	test al, 0xff
;	jz .exit
;	stosw
;	lodsb
;	jmp .loop
;.exit:
;	inc long[LINE_OFF]
;	mov sp, bp		; restore original stack ptrs
;	pop bp
;	ret

[bits 32]
;--------------------------------------------------
; initialize protected mode, reset segment registers
init_pm:
	mov ax, gdt_32.data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, PM_STACK	; move stack_top to addr PM_STACK
	mov esp, ebp		; reset stack pointers

	call is_A20_on		; confirm A20 gate in on, enable if not

	jmp ST2_OFFSET		; go to bootloader second stage

;-------------------------------------------------
; check is A20 line is enabled, run A20 init if A20 disabled
is_A20_on:
	pushad
	mov edi, 0x112345
	mov esi, 0x012345
	mov [esi], esi
	mov [edi], edi
	cmpsd
	popad
	jne init_A20
	ret

; initialize A20 line using keyboard controller
init_A20:
	call .a20wait
	mov al, 0xad		; send keyb command 0xAD
	out 0x64, al		; disable keyb

	call .a20wait
	mov al, 0xd0		; send keyb command 0xD0
	out 0x64, al		; read input

	call .a20wait2
	in al, 0x60		; read keyb data into EAX
	push eax

	call .a20wait
	mov al, 0xd1		; send keyb command 0xD1
	out 0x64, al		; write to output

	call .a20wait
	pop eax			; send data
	or al, 2
	out 0x60, al

	call .a20wait
	mov al, 0xae		; send keyb command 0xAE
	out 0x64, al		; enable keyb

	call .a20wait
	ret
.a20wait:
	in al, 0x64
	test al, 2
	jnz .a20wait
	ret
.a20wait2:
	in al, 0x64
	test al, 1
	jz .a20wait2
	ret

;print_str_32:
;	push ebp
;	mov ebp, esp
;	mov esi, [ebp+8]
;	mov edi, 0xb8000
;	mov edx, 0xa0
;	imul edx, [LINE_OFF]
;	add edi, edx
;	mov ah, 0x1f
;	lodsb
;.loop:
;	test al, 0xff
;	jz .exit
;	stosw
;	lodsb
;	jmp .loop
;.exit:
;	inc long[LINE_OFF]
;	mov esp, ebp
;	pop ebp
;	ret

;--------------------------------------------------
; declarations

; constants
SECTORS_TO_READ: equ 2
ST2_OFFSET: equ 0x7800
PM_STACK: equ 0x10000

; variables
boot_drive db 0
;LINE_OFF dd 0
;read_err_str db "READ ERROR",0
;sec_err_str db "SECTORS READ MISMATCH",0
;read_success db "READ SUCCESS",0
;test_str db "PM INITIALIZED",0

;--------------------------------------------------
; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55
