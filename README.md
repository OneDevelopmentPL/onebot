# OneBot - aplikacja

Jedyne wymagania to tak naprawde HC-06 w dowonym robocie z min 1 silnikiem. Pobierz aplikacje na swój system Android (apk) lub iOS (ipa), które znajdziesz w zakładce "Releases".

Przykładowy kod Arduino (nano):

```cpp
/*
 * Oryginalny kod: Wiktor Goszczyński (vityk-dev) © 2026
 * GitHub: https://github.com/vityk-dev
 *
 * Wersja zmodyfikowana: OneDevelopmentPL © 2026
 *
 * Uwagi:
 * - Ta wersja została zaadaptowana i przerobiona z oryginału.
 * - Wszystkie prawa do oryginalnego kodu pozostają przy autorze.
 */

#include <SoftwareSerial.h>
#include <Servo.h>

int rx = 8;
int tx = 7;

int motor_left_pin1 = 9;
int motor_left_pin2 = 5;
int motor_right_pin1 = 2;
int motor_right_pin2 = 3;

int servoPin = 4;

int lineLeftPin = 11;
int lineRightPin = 12;

SoftwareSerial bt(rx, tx);
Servo myServo;
char data;
int car_speed = 100;

bool followLine = false;

void forward() {
  digitalWrite(motor_left_pin1, HIGH);
  analogWrite(motor_left_pin2, car_speed);
  digitalWrite(motor_right_pin1, HIGH);
  analogWrite(motor_right_pin2, car_speed);
}

void backward() {
  digitalWrite(motor_left_pin1, LOW);
  analogWrite(motor_left_pin2, car_speed);
  digitalWrite(motor_right_pin1, LOW);
  analogWrite(motor_right_pin2, car_speed * 0.8);
}

void rightTurn() {
  digitalWrite(motor_left_pin1, HIGH);
  analogWrite(motor_left_pin2, car_speed);
  digitalWrite(motor_right_pin1, LOW);
  analogWrite(motor_right_pin2, 0);
}

void leftTurn() {
  digitalWrite(motor_left_pin1, LOW);
  analogWrite(motor_left_pin2, 0);
  digitalWrite(motor_right_pin1, HIGH);
  analogWrite(motor_right_pin2, car_speed);
}

void stp() {
  digitalWrite(motor_left_pin1, LOW);
  analogWrite(motor_left_pin2, 0);
  digitalWrite(motor_right_pin1, LOW);
  analogWrite(motor_right_pin2, 0);
}

void moveServo() {
  myServo.write(180);
  delay(500);
  myServo.write(0);
  delay(500);
}

void dance() {
  digitalWrite(motor_left_pin1, HIGH);
  analogWrite(motor_left_pin2, 75);
  digitalWrite(motor_right_pin1, HIGH);
  analogWrite(motor_right_pin2, 75);
  delay(250);

  digitalWrite(motor_left_pin1, LOW);
  analogWrite(motor_left_pin2, 75);
  digitalWrite(motor_right_pin1, LOW);
  analogWrite(motor_right_pin2, 75);
  delay(250);

  leftTurn();
  delay(250);

  rightTurn();
  delay(250);

  stp();
}

void followLineMode() {
  bool left = digitalRead(lineLeftPin);
  bool right = digitalRead(lineRightPin);

  if (left == HIGH && right == HIGH) forward();
  else if (left == HIGH && right == LOW) leftTurn();
  else if (left == LOW && right == HIGH) rightTurn();
  else stp();
}

void setup() {
  bt.begin(9600);

  pinMode(motor_left_pin1, OUTPUT);
  pinMode(motor_left_pin2, OUTPUT);
  pinMode(motor_right_pin1, OUTPUT);
  pinMode(motor_right_pin2, OUTPUT);

  pinMode(lineLeftPin, INPUT);
  pinMode(lineRightPin, INPUT);

  myServo.attach(servoPin);
  myServo.write(0);
}

void loop() {
  if (bt.available()) {
    data = bt.read();

    if (data == 'F') forward();
    else if (data == 'B') backward();
    else if (data == 'L') leftTurn();
    else if (data == 'R') rightTurn();
    else if (data == 'S') { stp(); followLine = false; }
    else if (data == 'M') moveServo();
    else if (data == 'D') dance();
    else if (data == 'A') followLine = true;
    else if (data == 'E') {
      followLine = false;
      stp();
    }
  }

  if (followLine) {
    followLineMode();
  }
}
```

Wgrraj kod do swojego Arduino Nano lub innej kompatybilnej płytki

HC-06 Automatycznie przechodzi w tryb parowania przy otrzymaniu prądu.

# Jak się połączyć?
1. Włącz robota (chyba jasne xd)
2. Wejdź do aplikacji OneBot
3. Kliknij plusik w prawym górnym rogu
4. Po chwili pojawi się HC-06 na liście
5. Kliknij go, następnie poczekaj chwilę aż połączenie będzie stabilne
6. Kliknij jakiś przycisk aby sprawdzić działanie

# Jak dodać własne przyciski?
1. Gdy jesteś połączony/a do robota, kliknij "+" w prawym górnym rogu
2. Wybierz napis oraz komendę do Bluetooth
3. Wybierz styl, następnie kliknij "Dodaj przycisk"
4. Przycisk wyświetli się na dole ekranu

# Co jak mój HC-06 czasami się odłącza?
Nie przejmuj się, przwidzieliśmy to, jeśli robot się rozłączy aplikacja będzie próbowała się połączyć odrazu ponownie. Dopracowaliśmy system auto-connect aby działał bardzo dobrze!

Projekt jest na licencji MIT, więcej przeczytasz w pliku LICENSE.

© 2026 OneDevelopmentPL
