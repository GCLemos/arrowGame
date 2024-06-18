const int potPin = A2;   // Pin where the potentiometer is connected
int lastValue = 0;       // Variable to store the last read value of the potentiometer
int threshold = 10;      // Variation limit to consider a significant change

void setup() {
    Serial.begin(9600);    // Start serial communication
}

void loop() {
    int potValue = analogRead(potPin);              // Read the value of the potentiometer
    int mappedValue = map(potValue, 0, 1023, 0, 255); // Map the value to the range of 0 to 255

    if (abs(mappedValue - lastValue) > threshold) {  // Check if the change is significant
        lastValue = mappedValue;                      // Update the last value
        Serial.print("Potentiometer: ");              // Print the potentiometer value
        Serial.println(lastValue);                    // Print the mapped value
    }

    delay(100); // Small delay for stability
}