#include <stdio.h>
#include <wiringPi.h>

#define	LED	0
#define BTN 	1

int main (void)
{

	wiringPiSetup () ;
	pinMode (LED, OUTPUT) ;
	pinMode (BTN,INPUT) ;

	for (;;)
	{
		if(digitalRead(BTN)==LOW){
			digitalWrite (LED, HIGH) ;
		}
		else{
			digitalWrite (LED, LOW) ;
		}
	
	
	delay (100) ;		
	
	}
	return 0 ;
}
