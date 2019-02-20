all: dumpix HSV2RGB RGB2HSV

dumpix:
	make -C gimp

HSV2RGB:
	make -C rgb

RGB2HSV:
	TARGET=$@ make -C rgb
