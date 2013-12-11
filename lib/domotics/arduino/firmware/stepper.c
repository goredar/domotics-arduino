
int command =						0;
int pin =							0;
int option =						0;
int state =							0;

void setup() {
	Serial.begin(115200);
}

void loop() {
	PORTD maps to Arduino digital pins 0 to 7
	PORTB maps to Arduino digital pins 8 to 13
	PORTC maps to Arduino analog pins 0 to 5.
PORTB |= B1100;
}