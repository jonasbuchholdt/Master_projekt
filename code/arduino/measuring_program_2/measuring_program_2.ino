#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <krnl.h>


//Constants
#define DHTPIN 4     // Digital pin connected to the DHT sensor 
#define DHTTYPE    DHT22     // DHT 22 (AM2302)
DHT dht(DHTPIN, DHTTYPE);

#define WindSensorPin (3) // The pin location of the anemometer sensor 


//Variables
volatile unsigned long Rotations; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime; // Timer to avoid contact bounce in interrupt routine 
float WindSpeed; // speed miles per hour 
volatile unsigned long Rotations_print;
float hum;  //Stores humidity value
float temp; //Stores temperature value

int analogPin1 = A2;
int analogPin2 = A3;
int vaneValue;

// A small krnl program with two independent tasks
// They run at same priority so krnl will do timeslicing between them

struct k_t *pt1, // pointer to hold reference
  *pt2;          // to taskdescriptor for t1 and t2  
 
char s1[200]; // stak for task t1
char s2[200]; // stak for task t2
 
void t1(void)
{
  // a task must have an endless loop
  // if you end and leave the task function - a crash will occur!!
  // so this loop is the code body for task 1
  while (1) 
  { 
     
    vaneValue = analogRead(analogPin2); 
    temp = dht.readTemperature();
    hum = dht.readHumidity();
    
  Serial.print(Rotations_print);
  Serial.print("\t");
  Serial.print(vaneValue); 
  Serial.print("\t");
  Serial.print(temp); 
  Serial.print("\t");
  Serial.println(hum);

  
  }               // lenght of ticks in millisec is specified in
}                 // k_start call called from setup

void t2(void)
{
  // and task body for task 2
   while (1) {   
   Rotations = 0;
     k_sleep(10);           // sleep 500 ticks
  Rotations_print = Rotations;
   }
}


void isr_rotation () 
{ 
if ((millis() - ContactBounceTime) > 15 ) { // debounce the switch contact. 
Rotations++; 
ContactBounceTime = millis(); 
} 
}

void setup()
{
  Serial.begin(115200);
  dht.begin();
pinMode(WindSensorPin, INPUT); 
attachInterrupt(digitalPinToInterrupt(WindSensorPin), isr_rotation, FALLING); 

  // init krnl so you can create 2 tasks, 0 semaphores and no message queues
  k_init(2,0,0); 

  // two task are created
  //              |------------ function used for body code for task
  //                 |--------- priority (lower number= higher prio
  //                   |------- array used for stak for task 
  //                        |-- staksize for array s1
  pt1=k_crt_task(t1,11,s1,200); 
  pt2=k_crt_task(t2,10,s2,200);
  k_start(200); // start kernel with tick speed 10 milli seconds
}

void loop(){ /* loop will never be called */ }
