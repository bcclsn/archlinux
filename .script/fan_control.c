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
#include <wiringPi.h>

#define FTEMP     "/sys/class/thermal/thermal_zone0/temp"
#define THRESHOLD 60000                                               // first two MSD (degree)
#define FORCED_ON 12                                                  // 12 cycle
#define GPIO_PIN  1

int os_read_d(char  *fname) {                                         // thanks to vbextreme
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
   int counter = 0;

   wiringPiSetup();
   pinMode(GPIO_PIN, OUTPUT);

   while(1) {
      temperature = os_read_d(FTEMP);

      if (temperature >= THRESHOLD) {
         digitalWrite(GPIO_PIN, HIGH);                                 // start the fan
         counter = 0;                                                  // reset the counter
      } else {                                                         // else if temperature is under the threshold
         counter++;                                                    // start the counter
         if (counter>FORCED_ON) {                                      // after 12 cycle under the threshold (cycle * delay = one minute)
            digitalWrite(GPIO_PIN, LOW);                               // stop the fan
         }
      }
      delay(5000);
   }
}
