import processing.serial.*;

Serial Arduino;

Serial sArduino;

//array for serial inputs from arduino
//2xGeschwindigkeit, 2xDrehzahl, Gang/Kupplung; je die drei letzten werte
short[][] input = new short[5][3];

//index for iterating over the three last values per input in input array
byte index = 0;

//function for initializing arduino serial connection
void initPortAndSerial(){
  String portName = Serial.list()[2];
  String portName2 = Serial.list()[3];

  Arduino = new Serial(this, portName, 115200);
  sArduino = new Serial(this, portName2, 115200);
}

//function for receiving serial data from arduino and writing it into the input array
void getInput(){
  //Maximalwerte: 280, 8000, 6+r
  if(Arduino.available() >= 5){
    //MSB geschwindigkeit
    input[0][index] = (short)Arduino.read();
    //LSB geschwindigkeit
    input[1][index] = (short)Arduino.read();
    //MSB drehzahl
    input[2][index] = (short)Arduino.read();
    //LSB drehzahl
    input[3][index] = (short)Arduino.read();
    //Gang/Kupplung
    input[4][index] = (short)Arduino.read();
  }
  
  index++;
  
  if(index > 2) index = 0;
}

//function for computing usable values from arduino input
void computeValues(){
  short msbSpeed = (short)((input[0][0] + input[0][1] + input[0][2])/3);
  short lsbSpeed = (short)((input[1][0] + input[1][1] + input[1][2])/3);
  
  short msbDrehzahl = (short)((input[2][0] + input[2][1] + input[2][2])/3);
  short lsbDrehzahl = (short)((input[3][0] + input[3][1] + input[3][2])/3);
  
  drehzahl = lsbDrehzahl + (msbDrehzahl<<8);
  
  geschwindigkeit = lsbSpeed + (msbSpeed<<8);
  
  gang = (short)(input[4][0]&0x07);
  
  kupplung = (input[4][0]&0x08) == 0x08;
  
  sportModus = (input[4][0]&0x10) == 0x10;
  
  blinkerRechts = (input[4][0]&0x20) == 0x20;
  
  blinkerLinks = (input[4][0]&0x40) == 0x40;
}

void sendSerial(){
  sArduino.write((byte)input[0][0]);
  sArduino.write((byte)input[1][0]);
  sArduino.write((byte)input[2][0]);
  sArduino.write((byte)input[3][0]);
  sArduino.write((byte)input[4][0]);
}
