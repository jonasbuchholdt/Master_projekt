


#include <dht.h>
dht DHT;
//Constants
#define DHT22_PIN 4     // DHT 22  (AM2302) - what pin we're connected to

#define WindSensorPin (3) // The pin location of the anemometer sensor 


//Variables
volatile unsigned long Rotations; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime; // Timer to avoid contact bounce in interrupt routine 
float WindSpeed; // speed miles per hour 

float hum;  //Stores humidity value
float temp; //Stores temperature value
int analogPin1 = A2;
int analogPin2 = A3;
int vaneValue;


void setup() {
  // put your setup code here, to run once:

  Serial.begin(115200);
pinMode(WindSensorPin, INPUT); 
attachInterrupt(digitalPinToInterrupt(WindSensorPin), isr_rotation, FALLING); 
}

void loop() {

Rotations = 0; // Set Rotations count to 0 ready for calculations 

sei(); // Enables interrupts 
  delay(1000);
    int chk = DHT.read22(DHT22_PIN); //Read data and store it to variables hum and temp    
    vaneValue = analogRead(analogPin2); 
  cli(); // Disable interrupts 
  
  Serial.print(Rotations);
  Serial.print("\t");
  Serial.print(vaneValue); 
  Serial.print("\t");
  Serial.print(DHT.temperature); 
  Serial.print("\t");
  Serial.println(DHT.humidity);


}

void isr_rotation () { 

if ((millis() - ContactBounceTime) > 15 ) { // debounce the switch contact. 
Rotations++; 
ContactBounceTime = millis(); 
} 
}
