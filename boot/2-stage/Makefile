all: new_boot.img

mbr.bin: mbr.asm gdt.asm
	nasm -fbin -o $@ $<

second_stage.bin: stage-2.asm
	nasm -fbin -o $@ $<

new_boot.img: mbr.bin second_stage.bin
	cat $^ > $@

clean:
	rm *.bin *.img
