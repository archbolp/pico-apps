
#define WOKWI             // Uncomment if running on Wokwi RP2040 emulator.
#include <pico/double.h>
#include <pico/float.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
//#include "pico/stdlib.h"

float single(int dec){ // function for single precision floats(wallis product)
float a = 2; //numerator starts at 2

float equals = 1.0f; // set equals to a float value
for (int i = 1; i <= dec; i++) { //for loop for each iteration
float one = (a)/(a+1); // first fraction calculated
float two = (a)/(a-1); // second fraction calculated
equals *= one * two; //fractions mutiplied to get current pi estimate for this iteration
a = a +2; // a is bigger for next iteration
}
return equals; // return once for loop is complete
}

double doub(int dec){ // function for double precision floats (wallis product)
double a = 2; //numerator starts at 2

double equals = 1.0f; // set equals to a float value
for (int i = 1; i <= dec; i++) { //for loop for each iteration
double one = (a)/(a+1); // first fraction calculated
double two = (a)/(a-1); // second fraction calculated
equals *= one * two; //fractions mutiplied to get current pi estimate for this iteration
a = a +2; // a is bigger for next iteration
}
return equals; // return once for loop is complete
}

int main() {

#ifndef WOKWI
    // Initialise the IO as we will be using the UART
    // Only required for hardware and not needed for Wokwi
    stdio_init_all();
#endif

int dec = 100000; //iterations

float estimate = single(dec); //calling single precision floats
estimate = estimate * 2; // multiply by 2 as wallis is pi/2
printf("single precision float estimate=%f\n",estimate); //print pi estimate

float error = 3.14159265359 - estimate; //find approx error
printf("single precision float absolute approximation error =%f\n", error); //print approx error

float perror = (error / 3.14159265359) *100; //get approx error
printf("single precision float percentage approximation error =%f\n", perror); //print approx error as %

double estimated = doub(dec); //calling double precision floats
estimated = estimated *2; //multiply by 2 as wallis is pi/2
printf("double precision float estimate=%f\n",estimated); //print pi estimate

double errord = 3.14159265359 - estimated; //find approx error
printf("double precision float absolute approximation error =%f\n", errord); //print approx error
    
float perrord = (errord / 3.14159265359) *100; // get approcx error
printf("double precision float percentage approximation error =%f\n", perrord); //print approx error as %
    
    // Returning zero indicates everything went okay.
    return 0;
}
