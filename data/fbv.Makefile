#
# Makefile
#
# Makefile for fbv

#include Make.conf

PATH_CC=/home/virgile/Documents/LEMB-RPI/build/tools-master/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin
CCC=$(PATH_CC)/arm-linux-gnueabihf-gcc
CXX=$(PATH_CC)/arm-linux-gnueabihf-g++


prefix	= /mnt/rootfs/usr
bindir	= /mnt/rootfs/usr/bin
mandir	= /mnt/rootfs/usr/man
infodir	= /mnt/rootfs/usr/info

LIBS	= -lm -lz -ljpeg -lpng


PATH_TARGET_FBV = /mnt/rootfs/usr
CPFLAGS=-I$(PATH_TARGET_FBV)/include/
LDFLAGS=-L$(PATH_TARGET_FBV)/lib

CC ?= $(CXX)
CFLAGS ?= -Wall -D_GNU_SOURCE

SOURCES	= main.c jpeg.c png.c bmp.c fb_display.c vt.c transforms.c
OBJECTS	= ${SOURCES:.c=.o}

OUT	= fbv

all: $(OUT)
	@echo Build DONE.

$(OUT): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $(OUT) $(OBJECTS) $(LIBS)

clean:
	rm -f $(OBJECTS) *~ $$$$~* *.bak core config.log $(OUT)

distclean: clean
	@echo -e "error:\n\t@echo Please run ./configure first..." >Make.conf
	rm -f $(OUT) config.h

install: $(OUT)
	cp $(OUT) $(bindir)
	[ -d $(mandir)/man1 ] || mkdir -p $(mandir)/man1
	gzip -9c $(OUT).1 > $(mandir)/man1/$(OUT).1.gz

uninstall: $(bindir)/$(OUT)
	rm -f $(bindir)/$(OUT)
	rm -f $(mandir)/man1/$(OUT).1.gz

