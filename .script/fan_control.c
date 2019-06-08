/*
 ============================================================================
 Name        : fan_control.c
 Author      : bcclsn
 Version     : 1.0
 Copyright   : null
 Description : controlla l'accensione e lo spegnimento di una ventola tramite
               transistor e pin gpio
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>

#define FTEMP     "/sys/class/thermal/thermal_zone0/temp"
#define THRESHOLD 60000
#define GPIO_PIN  1

int os_read_d(char  *fname) {
  FILE* fd = fopen(fname, "r");

  if (fd == NULL) {
    return -1;
  }
  char inp[64];
  inp[0] = 0;
  fgets(inp, 64, fd);
  return strtoul(inp, NULL, 10);
}

void main(void) {
   int temperature;

   wiringPiSetup();
   pinMode(GPIO_PIN, OUTPUT);

   while(1) {
      temperature = os_read_d(FTEMP);

      if (temperature >= THRESHOLD) {
         digitalWrite(GPIO_PIN, HIGH);
         //printf("fan on \n");
      } else {
         digitalWrite(GPIO_PIN, LOW);
         //printf("fan off \n");
      }
      delay(5000);
   }
}
