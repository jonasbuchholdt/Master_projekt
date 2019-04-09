


#include <dht.h>
dht DHT;
//Constants
#define DHT22_PIN 2     // DHT 22  (AM2302) - what pin we're connected to

//Variables
float hum;  //Stores humidity value
float temp; //Stores temperature value



void setup() {
  // put your setup code here, to run once:

  Serial.begin(115200);

}

void loop() {

    int chk = DHT.read22(DHT22_PIN);
    //Read data and store it to variables hum and temp
    hum = DHT.humidity;
    temp= DHT.temperature;
  
  Serial.print(2.4);
  Serial.print("\t");
  Serial.print(0); 
  Serial.print("\t");
  Serial.print(temp); 
  Serial.print("\t");
  Serial.println(hum);
  //delay(10);

}
