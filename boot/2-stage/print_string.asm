;--------------------------------------------------
; prints a string to VGA, starting on given line
; param1: cursor offset
; param2: line offset
; param3: string address
[bits 32]
print_str_32:
	push ebp			; store stack pointer
	mov ebp, esp
	mov edi, 0xb8000

	mov esi, [ebp+8]		; store string ptr

	mov edx, [ebp+12]		; retrieve line number
	imul edx, 0xa0			; calculate line offset

	add edi, edx			; add line offset
	add edi, [ebp+16]		; add cursor offset
	mov ah, 0x1f			; set color
	lodsb
.loop:
	test al, 0xff			; if char==0x00 exit
	jz .exit
	stosw
	lodsb
	jmp .loop
.exit:
	mov esp, ebp			; reset stack
	pop ebp
	ret
