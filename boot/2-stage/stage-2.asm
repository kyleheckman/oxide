[org 0x1000]
[bits 32]

_start:
	push 20
	push 5 
	push stg_2_str
	call print_str_32
	pop edx
	pop edx
	pop edx

	jmp enable_longmode

%include "print_string.asm"
%include "gdt.asm"

;--------------------------------------------------
; process to enable longmode, detailed in AMD64 Programmer's Manual
enable_longmode:

	;--------------------------------------------------
	; disable paging
	mov eax, cr0
	and eax, 0x7fffffff	; unset CR0[31] "PG"
	mov cr0, eax

	;--------------------------------------------------
	; set up page tables (PML4 -> PDPT -> PDT -> PT)
	; entries will start at addr 0x100000
	mov edi, 0x100000
	mov cr3, edi		; set address of PML4[0]
	xor eax, eax
	mov ecx, 0x1000		
	rep stosd		; zero 4096 * 4 = 16KiB, 0x100000-0x104000
	mov edi, cr3		; reset EDI to PML4[0]

	mov long[edi], 0x101003	; set address of PDPT[0]
	add edi, 0x1000
	mov long[edi], 0x102003	; set address of PDT[0]
	add edi, 0x1000
	mov long[edi], 0x103003	; set address of PT[0]
	add edi, 0x1000

	mov ebx, 0x00000003	; set first page of PT
	mov ecx, 0x200		; set counter to 512
.set_entry:
	mov long[edi], ebx	; set page at EDI
	add ebx, 0x1000		; increment page value
	add edi, 0x8		; increment PT
	loop .set_entry

	;-------------------------------------------------
	; enable PAE in CR4
	mov eax, cr4
	or eax, 1<<5		; set CR4[5] "PAE"
	mov cr4, eax

	;--------------------------------------------------
	; set longmode LM bit in EFER
	mov ecx, 0xc0000080	; set MSR code for EFER
	rdmsr
	or eax, 1<<8		; set EFER[8] "LME"
	wrmsr

	;--------------------------------------------------
	; enable paging
	mov eax, cr0
	or eax, 1<<31		; set CR0[31]
	mov cr0, eax

	;--------------------------------------------------
	; load new GDT, far jump to init_64
	lgdt [gdt_64.pointer]
	jmp gdt_64.code:init_64

[bits 64]
%include "VGA_driver.asm"

init_64:
	mov ax, gdt_64.data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	; print success message
	mov rax, 0x2f592f412f4b2f4f
	mov qword[0xb8000], rax

	;
	push 0
	push 0
	push line_1
	call VGA_write
	pop rdx
	pop rdx

	mov rcx, 23
.loop:
	inc rdx
	push rdx
	push line_2
	call VGA_write
	pop rdx
	pop rdx
	loop .loop

	inc rdx
	push rdx
	push line_1
	call VGA_write
	pop rdx
	pop rdx
	pop rdx
	
	xor rdx, rdx
	push 2
	push 1
	push longm_success_str
	call VGA_write
	pop rdx
	pop rdx
	pop rdx

	hlt

stg_2_str: db "STAGE 2 STARTED",0
longm_success_str: db "64-BIT Operation Set",0

line_1: db	"////////////////////////////////////////////////////////////////////////////////",0
line_2: db	"][                                                                            ][",0

times 1024 - ($-$$) db 'A'
