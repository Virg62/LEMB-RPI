#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>



int main (int argc, char *argv[])
{

  int LED = atoi(argv[1]);
	printf("led : %d\n",LED);
  wiringPiSetup () ;
  pinMode (LED, OUTPUT) ;

  for (;;)
  {
    digitalWrite (LED, HIGH) ;	// On
    delay (500) ;		// mS
    digitalWrite (LED, LOW) ;	// Off
    delay (500) ;
  }
  return 0 ;
}
