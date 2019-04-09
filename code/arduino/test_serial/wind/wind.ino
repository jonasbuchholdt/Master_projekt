#include <math.h> 

#define WindSensorPin (3) // The pin location of the anemometer sensor 

volatile unsigned long Rotations; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime; // Timer to avoid contact bounce in interrupt routine 

float WindSpeed; // speed miles per hour 

void setup() { 
Serial.begin(115200); 

pinMode(WindSensorPin, INPUT); 
attachInterrupt(digitalPinToInterrupt(WindSensorPin), isr_rotation, FALLING); 

Serial.println("Davis Wind Speed Test"); 
Serial.println("Rotations\tMPH"); 
} 

void loop() { 

Rotations = 0; // Set Rotations count to 0 ready for calculations 

sei(); // Enables interrupts 
delay (3000); // Wait 3 seconds to average 
cli(); // Disable interrupts 

Serial.println(Rotations);


} 

// This is the function that the interrupt calls to increment the rotation count 
void isr_rotation () { 

if ((millis() - ContactBounceTime) > 15 ) { // debounce the switch contact. 
Rotations++; 
ContactBounceTime = millis(); 
} 

}
