[bits 64]

VGA_write:
;--------------------------------------------------
; print text direct to VGA buffer 0xB8000
; param1: cursor offset - 0-indexed
; param2: line offset - 0-indexed
; param3: string pointer
	push rbp		; store stack ptr
	mov rbp, rsp
	mov rdi, 0xb8000

	mov rsi, [rbp+16]	; copy string pointer

	mov rdx, [rbp+24]	; retrieve line number
	imul rdx, 0xa0		; calculate line offset

	add rdi, rdx		; add line offset

	mov rdx, [rbp+32]	; retrieve cursor
	sal rdx, 1		; calculate cursor offset

	add rdi, rdx		; add cursor offset

	mov ah, 0x1f		; set color
	lodsb
.next_char:
	test al, 0xff		; is char == 0x00 exit
	jz .exit
	stosw
	lodsb
	jmp .next_char
.exit:
	mov rsp, rbp		; reset stack
	pop rbp
	ret
