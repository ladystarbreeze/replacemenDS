Rem Taken from https://github.com/Cult-Of-GBA/BIOS
%DEVKITARM%/arm-none-eabi/bin/as.exe boot.s -mcpu=arm946e -o boot.o
%DEVKITARM%/arm-none-eabi/bin/objcopy.exe boot.o nds9.bin -O binary
