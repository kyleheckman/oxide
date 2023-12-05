
;--------------------------------------------------
; prints a string to VGA, starting on given line
; param1: VGA line
; param2: string address
[bits 32]
print_str_32:
	push ebp			; store stack pointer
	mov ebp, esp
	mov esi, [ebp+8]		; retrieve string addr
	mov edi, 0xb8000
	mov edx, 0xa0			; set line width
	mov ecx, [ebp+12]		; retrieve line number
	imul edx, ecx
	add edi, edx			; adjust VGA buffer offset
	mov ah, 0x1f			; set color
	lodsb
.loop:
	test al, 0xff
	jz .exit
	stosw
	lodsb
	jmp .loop
.exit:
	mov esp, ebp			; reset stack
	pop ebp
	ret
