;--------------------------------------------------
; basic driver for accessing boot drive from long mode
; used to load kernel into memory

[bits 64]

;--------------------------------------------------
; enumerator declarations

; DMAC 0 Ports
DMA0_ADDR_CH0:		equ 0x00
DMA0_CNT_CH0:		equ 0x01
DMA0_ADDR_CH1:		equ 0x02
DMA0_CNT_CH1:		equ 0x03
DMA0_ADDR_CH2:		equ 0x04
DMA0_CNT_CH2:		equ 0x05
DMA0_ADDR_CH3:		equ 0x06
DMA0_ADDR_CH3:		equ 0x07
DMA0_STATUS:		equ 0x08
DMA0_COMMAND:		equ 0x08
DMA0_REQUEST:		equ 0x09
DMA0_SGL_MASK:		equ 0x0a
DMA0_MODE:		equ 0x0b
DMA0_FLIPFLOP_CLR:	equ 0x0c
DMA0_INTERMED:		equ 0x0d
DMA0_MASTER_CLR:	equ 0x0d
DMA0_MASK_RST:		equ 0x0e
DMA0_MULT_MASK:		equ 0x0f

; DMAC 1 Ports
DMA1_ADDR_CH4:		equ 0xc0
DMA1_CNT_CH4:		equ 0xc2
DMA1_ADDR_CH5:		equ 0xc4
DMA1_CNT_CH5:		equ 0xc6
DMA1_ADDR_CH6:		equ 0xc8
DMA1_CNT_CH6:		equ 0xca
DMA1_ADDR_CH7:		equ 0xcc
DMA1_CNT_CH7:		equ 0xce
DMA1_STATUS:		equ 0xd0
DMA1_COMMAND:		equ 0xd0
DMA1_REQUEST:		equ 0xd2
DMA1_SGL_MASK:		equ 0xd4
DMA1_MODE:		equ 0xd6
DMA1_FLIPFLOP_CLR:	equ 0xd8
DMA1_INTERMED:		equ 0xda
DMA1_MASTER_CLR:	equ 0xda
DMA1_MASK_RST:		equ 0xdc
DMA1_MULT_MASK:		equ 0xde

; Extended Addressing
DMA_PG_CH2:		equ 0x81
DMA_PG_CH3:		equ 0x82
DMA_PG_CH1:		equ 0x83
DMA_PG_CH6:		equ 0x87
DMA_PG_CH7:		equ 0x8a
DMA_PG_CH6:		equ 0x8b

; DMA Modes

