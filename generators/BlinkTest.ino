
/**
 * Example export template for some robot.
 *
 * Specify generated code format:
 * ${MAIN}= void execute()
 * ${REPEAT}= for(${I}= 0; ${I}< ${N}; ${I}++)
 * ${PROC_DEF}= void
 * ${FOREVER}= while(true)
 * ${SEMICOLON}= ;
 * ${BLOCK_OPEN}= {
 * ${BLOCK_CLOSE}= }
 * ${INT_DEF}= int
 * ${TRUE}= true
 * ${FALSE}= false
 * ${COMMENT}= //
 * ${INIT_INDENT}= 0
 * ${VAR}= X=42.0
 * ${VAR_USER_INPUT}=ARDUINO_COMPORT=COM3|Serial port|TEXT
 * ${VAR_USER_INPUT}=USR_FWD_CM=10|Forward (cm)|INT
 * ${VAR_USER_INPUT}=USR_ROT_DEG=90|Rotation (degrees)|INT
 * ${VAR_USER_INPUT}=USR_WHITE=700|Whiteness (0-1000)|INT
 * ${VAR_USER_INPUT}=USR_BLACK=300|Blackness (0-1000)|INT
 * ${POST_PROCESS}=SHOW_GENERATED_SOURCE
 * @author Arvid Halma
 */

void execute();
${FUNCTION_PROTOTYPES}
${POST_PROCESS}=SHOW_GENERATED_SOURCE

// RoboMind's basic instructions specification

// Moving around
void forward(int n){
    for(int i = 0; i < n; i++){
        digitalWrite(13, HIGH);   // set the LED on
        delay(1000);              // wait for a second
        digitalWrite(13, LOW);    // set the LED off
        delay(100);              // wait for a second
    }
}

void backward(int n){
    for(int i = 0; i < n; i++){
        digitalWrite(13, HIGH);   // set the LED on
        delay(100);              // wait for a second
        digitalWrite(13, LOW);    // set the LED off
        delay(1000);              // wait for a second
    }
}

void right(){

}

void left(){

}

void north(int n){

}

void south(int n){

}

void east(int n){

}

void west(int n){

}

// Gripper
void gripperGet(){

}

void gripperPut(){

}

// Painting
void paintWhite(){

}

void paintBlack(){

}

void stopPainting(){

}

// Random
boolean flipCoin(){
    return true;
}

// Perceiving
boolean leftIsObstacle(){
    return false;
}

boolean leftIsClear(){
    return false;
}

boolean leftIsBeacon(){
    return false;
}

boolean leftIsWhite(){
    return false;
}

boolean leftIsBlack(){
    return false;
}


boolean frontIsObstacle(){
    return false;
}

boolean frontIsClear(){
    return false;
}

boolean frontIsBeacon(){
    return false;
}

boolean frontIsWhite(){
    return false;
}

boolean frontIsBlack(){
    return false;
}

boolean rightIsObstacle(){
    return false;
}

boolean rightIsClear(){
    return false;
}

boolean rightIsBeacon(){
    return false;
}

boolean rightIsWhite(){
    return false;
}

boolean rightIsBlack(){
    return false;
}

// Terminating the execution
void end(){

}

//${GENERATED_CODE}

/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.

  This example code is in the public domain.
 */

void setup() {
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards:
  pinMode(13, OUTPUT);
}

void loop() {
   execute(); // to be generated
   while(true) {
      // do not loop
   }
}