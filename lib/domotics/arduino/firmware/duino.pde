/*
 * Serial communication for gHome.
 * 
 * Input(space separeted):
 * 1. command
 * 2. pin
 * 3. option
 * 
 * created 03 Sep 2012
 * by goredar
 */



// Cons
// Replys definitions
const int SuccessReprly = 2;
const int FailReprly = 3;
// Input commands definitions
const int SetPinMode = 0;
const int GetDigital = 1;
const int SetDigital = 2;
const int GetADC = 3;
const int SetPWM = 4;
const int GetWatch = 5;
const int SetWatch = 6;
const int EchoReply = 7;
const int Defaults = 8;
const int SetPWMFreq = 9;
// Output message definitions
const int WatchAlarm = 0;
// Number of pins for board:
// nano - 22, mega - 70
const int NumberOfPins = 70;
// For watch function
const int WatchOFF = 0;
const int WatchON = 1;
// Vars
int command = 0;
int pin = 0;
int option = 0;
int state = 0;
boolean watchlist[NumberOfPins];
int statelist[NumberOfPins];

void setup() {
  default_state();
  // Begin serial
  Serial.begin(115200);
}
// Main stream
void loop() {
  if (Serial.available() > 0) {
    // Parse command
    command = Serial.parseInt();
    pin = Serial.parseInt();
    option = Serial.parseInt();
    if (Serial.read() == '\n') {
      switch (command) {
        case SetPinMode:
          pinMode(pin, option);
          Serial.println(SuccessReprly, DEC);
          break;
        case GetDigital:
          Serial.println(digitalRead(pin), DEC);
          break;
        case SetDigital:
          digitalWrite(pin, option);
          Serial.println(SuccessReprly, DEC);
          break;
        case GetADC:
          Serial.println(analogRead(pin), DEC);
          break;
        case SetPWM:
          analogWrite(pin, option);
          Serial.println(SuccessReprly, DEC);
          break;
        case SetPWMFreq:
          switch (pin) {
            case 1: TCCR1B = (TCCR1B & 0xF8) | option; break;
            case 2: TCCR2B = (TCCR2B & 0xF8) | option; break;
            //#ifdef __AVR_ATmega2560__
            case 3: TCCR3B = (TCCR3B & 0xF8) | option; break;
            case 4: TCCR4B = (TCCR4B & 0xF8) | option; break;
            case 5: TCCR5B = (TCCR5B & 0xF8) | option; break;
            //#endif
          }
          Serial.println(SuccessReprly, DEC);
          break;
        case GetWatch:
          if (watchlist[pin]) {
            Serial.println(WatchON, DEC);
          }
          else {
            Serial.println(WatchOFF, DEC);
          }
          break;
        case SetWatch:
          if (option == WatchOFF) {
            watchlist[pin] = false;
          }
          else {
            statelist[pin] = digitalRead(pin);
            watchlist[pin] = true;
          }
          Serial.println(SuccessReprly, DEC);
          break;
        case EchoReply:
          Serial.print(option, DEC);
          Serial.print(' ');
          Serial.println(pin, DEC);
          break;
        case Defaults:
          default_state();
          Serial.println(SuccessReprly, DEC);
          break;
        default:
          // Invalid command
          Serial.println(FailReprly, DEC);
          break;
      }
    }
    else {
      // Invalid input
      Serial.println(FailReprly, DEC);
    }
  }
  for (int i=2; i < NumberOfPins; i++){
    // Watch for changes on digital pins
    if (watchlist[i]) {
      state = digitalRead(i);
      if (state != statelist[i]) {
        statelist[i] = state;
        Serial.print(WatchAlarm, DEC);
        Serial.print(' ');
        Serial.print(i, DEC);
        Serial.print(' ');
        Serial.println(state, DEC);
      }
    }
  }
}

void default_state() {
  for (int i=0; i < NumberOfPins; i++) {
    pinMode(i, INPUT);
    watchlist[i] = false;
  }
}
