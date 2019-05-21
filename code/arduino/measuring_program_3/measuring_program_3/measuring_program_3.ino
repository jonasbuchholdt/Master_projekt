#include <math.h> 
#include <dht.h>
dht DHT;
#include "TimerOne.h"


//Constants
#define DHT22_PIN 4     // DHT 22  (AM2302) - what pin we're connected to

#define WindSensorPin1 (2) // The pin location of the anemometer sensor 
#define WindSensorPin2 (3) // The pin location of the anemometer sensor 

//Variables


volatile bool IsSampleRequired; // this is set true every 2.5s. Get wind speed 
volatile unsigned int TimerCount; // used to determine 2.5sec timer count 
volatile unsigned long Rotations1; // cup rotation counter used in interrupt routine 
volatile unsigned long Rotation_old1; // cup rotation counter used in interrupt routine 
volatile unsigned long ring1; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime1; // Timer to avoid contact bounce in isr 
volatile unsigned long Rotations2; // cup rotation counter used in interrupt routine 
volatile unsigned long Rotation_old2; // cup rotation counter used in interrupt routine 
volatile unsigned long ring2; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime2; // Timer to avoid contact bounce in isr 
volatile unsigned long timet1 = 0;
volatile unsigned long timet2 = 0;
float WindSpeed1; // speed miles per hour 
float WindSpeed2; // speed miles per hour 

int analogPin1 = A2;
int analogPin2 = A3;
int vaneValue1;
int vaneValue2;
int count1;
int count2;
int buffersize = 16;
int ringbuffer1[16];
int ringbuffer2[16];
float hum;  //Stores humidity value
float temp; //Stores temperature value

void setup() { 



IsSampleRequired = false; 
TimerCount = 0;
count1 = 0; 
count2 = 0;
Rotations1 = 0; // Set Rotations to 0 ready for calculations 
Rotation_old1 = 0;
Rotations2 = 0; // Set Rotations to 0 ready for calculations 
Rotation_old2 = 0;
ring1 = 0;
ring2 = 0;
Serial.begin(115200); 
pinMode(WindSensorPin2, INPUT); 
// Setup the timer interupt 
attachInterrupt(digitalPinToInterrupt(WindSensorPin1), isr_rotation1, FALLING); 
attachInterrupt(digitalPinToInterrupt(WindSensorPin2), isr_rotation2, FALLING); 
Timer1.initialize(26500);// Timer interrupt every 2.5 seconds 500000 (25000))
Timer1.attachInterrupt(isr_timer); 
} 

void loop() { 
  if(IsSampleRequired) { 


    ringbuffer1[count1] = Rotations1 - Rotation_old1;   
    Rotation_old1 = Rotations1;
    ring1 = 0;
    
    for(int i = 0; i <= buffersize; i++){
      ring1 = ring1+ringbuffer1[i];
    }
  
    if(count1 == buffersize){
      Rotations1 = 0; // Reset count for next sample 
      Rotation_old1 = 0;
      count1 = 0;
    } 

    else{
      count1++;
    } 

    
    ringbuffer2[count2] = Rotations2 - Rotation_old2;   
    Rotation_old2 = Rotations2;
    ring2 = 0;
    
    for(int i = 0; i <= buffersize; i++){
      ring2 = ring2+ringbuffer2[i];
    }
  
    if(count2 == buffersize){
      Rotations2 = 0; // Reset count for next sample 
      Rotation_old2 = 0;
      count2 = 0;
    } 

    else{
      count2++;
    } 
    
  IsSampleRequired = false; 
  } 

  int chk = DHT.read22(DHT22_PIN); //Read data and store it to variables hum and temp    
  vaneValue1 = analogRead(analogPin1); 
  vaneValue2 = analogRead(analogPin2); 
  temp = DHT.temperature;
  hum = DHT.humidity;
  WindSpeed1 = ring1*(2.25/2.960)*0.44704;
  WindSpeed2 = ring2*(2.25/2.960)*0.44704;
  Serial.print(WindSpeed1);
  Serial.print("\t");
  Serial.print(vaneValue1); 
  Serial.print("\t");
  Serial.print(WindSpeed2);
  Serial.print("\t");
  Serial.print(vaneValue2); 
  Serial.print("\t");
  Serial.print(temp); 
  Serial.print("\t");
  Serial.print(hum);
  Serial.print("\t");
  Serial.println(timet2);
  delay(88);
  
} 


// isr handler for timer interrupt 
void isr_timer() { 
TimerCount++; 
  if(TimerCount == 7) { 
    timet2 =  millis();
    IsSampleRequired = true; 
    TimerCount = 0; 
  } 
} 

// This is the function that the interrupt calls to increment the rotation count 
void isr_rotation1() { 
  if((millis() - ContactBounceTime1) > 15 ) { // debounce the switch contact. 
    Rotations1++; 
    ContactBounceTime1 = millis(); 
  } 
} 
 
 void isr_rotation2() { 
  if((millis() - ContactBounceTime2) > 15 ) { // debounce the switch contact. 
    Rotations2++; 
    ContactBounceTime2 = millis(); 
  } 
} 
