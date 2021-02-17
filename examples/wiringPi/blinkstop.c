



#include <signal.h>   // signal de fin de programme

#include <string.h>   // Gestion des String d'erreur

#include <errno.h>    // Gestion des numéros d'erreur

#include <stdlib.h>   // La librairie standard

#include <wiringPi.h> // La wiringPi

 


 

const int gpio20 = 20; // Regular LED - Broadcom pin 20, P1 pin 38

 

volatile int eventCounter = 0; // Le compteur d'appui sur le bouton

 

// Fonction de fin déclenchée par CTRL-C

void fin(int sig)

{

       // Désactive les résistances

       pullUpDnControl(1, PUD_OFF);

    

       exit(0);

}

 

// -----------------------

// Fonction d'interruption

// -----------------------

void myInterrupt(void) {

       eventCounter++;

      
}

 

// ----

// main

// ----

int main(void) {

       // Ecoute du CTRL-C avec fonction à lancer

       

      

       // Setup wiringPi library

       if (wiringPiSetupGpio () < 0) {

             

             exit(1);

       }

 

       pinMode(1, INPUT);

       pullUpDnControl(1, PUD_UP);

 

       // Programmation de l'interruption si la GPIO20 passe de 1 à 0

       if ( wiringPiISR (1, INT_EDGE_FALLING, &myInterrupt) < 0 ) {

           

           exit(2);

       }

 

       // On boucle, mais on pourrait faire plein d'autres choses...

       while ( 1 ) {

       }

}

