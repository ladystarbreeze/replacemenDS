# Taken from https://github.com/Cult-Of-GBA/BIOS
${DEVKITARM}/bin/arm-none-eabi-as boot.s -mcpu=arm946e -o boot.o
${DEVKITARM}/bin/arm-none-eabi-objcopy boot.o nds9.bin -O binary
