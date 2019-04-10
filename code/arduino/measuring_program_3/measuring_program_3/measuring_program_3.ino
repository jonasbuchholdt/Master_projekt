#include <math.h> 
#include <dht.h>
dht DHT;
#include "TimerOne.h"


//Constants
#define DHT22_PIN 4     // DHT 22  (AM2302) - what pin we're connected to

#define WindSensorPin (3) // The pin location of the anemometer sensor 


//Variables
volatile unsigned long Rotations_print;
volatile unsigned long Rotations_b1;
volatile unsigned long Rotations_b2;
volatile unsigned long Rotations_b3;
volatile unsigned long Rotations_b4;
volatile unsigned long Rotations_b5;


volatile bool IsSampleRequired; // this is set true every 2.5s. Get wind speed 
volatile unsigned int TimerCount; // used to determine 2.5sec timer count 
volatile unsigned long Rotations; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime; // Timer to avoid contact bounce in isr 
float WindSpeed; // speed miles per hour 

int analogPin1 = A2;
int analogPin2 = A3;
int vaneValue;
int count;
int ring;
int Rotation_old;
int ringbuffer[5];
float hum;  //Stores humidity value
float temp; //Stores temperature value

void setup() { 



IsSampleRequired = false; 
TimerCount = 0;
count = 0; 
Rotations = 0; // Set Rotations to 0 ready for calculations 
Rotation_old = 0;
ring = 0;
Serial.begin(115200); 
pinMode(WindSensorPin, INPUT); 
// Setup the timer interupt 
attachInterrupt(digitalPinToInterrupt(WindSensorPin), isr_rotation, FALLING); 
Timer1.initialize(100000);// Timer interrupt every 2.5 seconds 500000
Timer1.attachInterrupt(isr_timer); 
} 

void loop() { 


if(IsSampleRequired) 
{ 
  ringbuffer[count] = Rotations - Rotation_old;   
  Rotation_old = Rotations;
  
  ring = ringbuffer[0]+ringbuffer[1]+ringbuffer[2]+ringbuffer[3]+ringbuffer[4];
  
  if(count == 4)
  {
    Rotations = 0; // Reset count for next sample 
    Rotation_old = 0;
    count = 0;
  } 
  else
  {
    count++;
  }
  
IsSampleRequired = false; 
} 

      int chk = DHT.read22(DHT22_PIN); //Read data and store it to variables hum and temp    
      vaneValue = analogRead(analogPin2); 
      temp = DHT.temperature;
      hum = DHT.humidity;
      WindSpeed = ring*(2.25/2.5)*0.44704;
      Serial.print(WindSpeed);
      Serial.print("\t");
      Serial.print(vaneValue); 
      Serial.print("\t");
      Serial.print(temp); 
      Serial.print("\t");
      Serial.println(hum);

delay(100);

} 










// isr handler for timer interrupt 
void isr_timer() { 
TimerCount++; 
if(TimerCount == 6) 
{ 
IsSampleRequired = true; 
TimerCount = 0; 
} 
} 

// This is the function that the interrupt calls to increment the rotation count 
void isr_rotation() { 

if((millis() - ContactBounceTime) > 15 ) { // debounce the switch contact. 
Rotations++; 
ContactBounceTime = millis(); 
} 
} 
 
 
