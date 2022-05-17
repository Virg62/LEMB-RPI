CC = gcc
INCLUDE = -I.
LIB = -L
FLAG = -lwiringPi -lwiringPiDev -lpthread -lm -lcrypt -lrt
all : led btn blinkstop

led : led.o
	@echo Edition de liens
	$(CC) $(INCLUDE) led.o  -o led $(LIB) $(FLAG)
	
blinkstop : blinkstop.o
	@echo Edition de liens
	$(CC) blinkstop.o -o blinkstop $(LIB) $(FLAG)
	

led.o : led.c
	@echo Compilation
	$(CC) -c -Wall $(INCLUDE) -Winline -pipe led.c -o led.o



btn : btn.o
	$(CC) btn.o -o btn $(LIB) $(FLAG)

btn.o : btn.c
	$(CC) -c -Wall $(INCLUDE) -Winline -pipe btn.c -o btn.o
	
blinkstop.o : blinkstop.c
	$(CC) -c -Wall $(INCLUDE) -Winline -pipe blinkstop.c -o blinkstop.o

clean : 
	rm *.o
