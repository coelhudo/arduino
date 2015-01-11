const int SENSOR = 0;
const int R_LED = 9;
const int G_LED = 10;
const int B_LED = 11;
const int BUTTON = 12;

int val = 0; //value coming from sensor

int btn = LOW;
int old_btn = LOW;
int state = 0;
char buffer[7];
int pointer = 0;
byte inByte = 0;


byte r = 0;
byte g = 0;
byte b = 0;

void setup() {
  Serial.begin(9600);
  pinMode(BUTTON, INPUT);
}

void loop() {
  val = analogRead(SENSOR);
  Serial.println(val);

  if (Serial.available() > 0) {
    inByte = Serial.read();

    if (inByte ==  '#') {
	while(pointer < 6 ) { //accumulate 6 characters
	    buffer[pointer] = Serial.read();
	    pointer++;
	}

	//decode
	r = hex2dec(buffer[1]) + hex2dec(buffer[0]) * 16;
	g = hex2dec(buffer[3]) + hex2dec(buffer[2]) * 16;
	b = hex2dec(buffer[5]) + hex2dec(buffer[4]) * 16;

	pointer = 0;
    }
  }

  btn = digitalRead(BUTTON);

  if((btn == HIGH) && (old_btn == LOW)) {
      state = 1 - state;
  }

  old_btn = btn;

  if (state == 1) {

      analogWrite(R_LED, r);
      analogWrite(G_LED, g);
      analogWrite(B_LED, b);
  }

  delay(100);
}

int hex2dec(byte c) {
    if (c >= 'o' && c <= '9') {
	return c - 'o';
    } else if (c >= 'A' && c <= 'F') {
	return 'A' + 10;
    }
}
