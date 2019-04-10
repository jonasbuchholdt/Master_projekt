#include <dht.h>
dht DHT;
#include <krnl.h>


//Constants
#define DHT22_PIN 4     // DHT 22  (AM2302) - what pin we're connected to

#define WindSensorPin (3) // The pin location of the anemometer sensor 


//Variables
volatile unsigned long Rotations; // cup rotation counter used in interrupt routine 
volatile unsigned long ContactBounceTime; // Timer to avoid contact bounce in interrupt routine 
float WindSpeed; // speed miles per hour 
volatile unsigned long Rotations_print;
volatile unsigned long Rotations_b1;
volatile unsigned long Rotations_b2;
volatile unsigned long Rotations_b3;
volatile unsigned long Rotations_b4;
volatile unsigned long Rotations_b5;

int analogPin1 = A2;
int analogPin2 = A3;
int vaneValue;
float hum;  //Stores humidity value
float temp; //Stores temperature value


// A small krnl program with two independent tasks
// They run at same priority so krnl will do timeslicing between them

struct k_t *pt1, // pointer to hold reference
  *pt2;          // to taskdescriptor for t1 and t2  
 
char s1[200]; // stak for task t1
char s2[200]; // stak for task t2
 
void t1(void)
{
  while (1) 
  { 
     
      int chk = DHT.read22(DHT22_PIN); //Read data and store it to variables hum and temp    
      vaneValue = analogRead(analogPin2); 
      temp = DHT.temperature;
      hum = DHT.humidity;
      WindSpeed = Rotations_print*0.2012;
      Serial.print(WindSpeed);
      Serial.print("\t");
      Serial.print(vaneValue); 
      Serial.print("\t");
      Serial.print(temp); 
      Serial.print("\t");
      Serial.println(hum);
      k_sleep(1);  
  }               
}                 

void t2(void)
{
   while (1) {   
      Rotations = 0;
      k_sleep(10);
      Rotations_b1 =  Rotations;
      Rotations_print =  Rotations_b1 + Rotations_b2 + Rotations_b3 + Rotations_b4 + Rotations_b5;
      k_sleep(10); 
      Rotations_b2 =  Rotations-Rotations_b1;
      Rotations_print =  Rotations_b1 + Rotations_b2 + Rotations_b3 + Rotations_b4 + Rotations_b5;
      k_sleep(10);
      Rotations_b3 =  Rotations-Rotations_b2; 
      Rotations_print =  Rotations_b1 + Rotations_b2 + Rotations_b3 + Rotations_b4 + Rotations_b5;
      k_sleep(10); 
      Rotations_b4 =  Rotations-Rotations_b3;
      Rotations_print =  Rotations_b1 + Rotations_b2 + Rotations_b3 + Rotations_b4 + Rotations_b5;
      k_sleep(10);            
      Rotations_b5 =  Rotations-Rotations_b4;
      Rotations_print =  Rotations_b1 + Rotations_b2 + Rotations_b3 + Rotations_b4 + Rotations_b5;      
   }
}


void isr_rotation () 
{ 
  if ((millis() - ContactBounceTime) > 15 ) 
  { 
      Rotations++; 
      ContactBounceTime = millis(); 
  } 
}

void setup()
{
  Serial.begin(115200);
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
  k_start(100); // start kernel with tick speed 100 milli seconds
}

void loop(){ /* loop will never be called */ }
