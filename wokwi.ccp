#include "DHT.h"
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Konfigurasi DHT
#define DHTPIN 2     // Pin untuk DHT22
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Konfigurasi LCD I2C
LiquidCrystal_I2C lcd(0x27, 20, 4); // Alamat I2C (0x27) dan ukuran LCD 20x4

// Pin untuk LED
#define LEDPIN 9

void setup() {
  Serial.begin(9600);
  dht.begin();
  lcd.begin(20, 4); // Menambahkan parameter jumlah kolom dan baris
  lcd.backlight();
  pinMode(LEDPIN, OUTPUT);

  // Menampilkan pesan awal pada LCD
  lcd.setCursor(0, 0);
  lcd.print("Fuzzy Sugeno System");
  lcd.setCursor(0, 1);
  lcd.print("Initializing...");
  delay(2000); // Tunggu 2 detik
  lcd.clear();
}

void loop() {
  // Membaca data dari DHT22
  float suhu = dht.readTemperature();
  float kelembapan = dht.readHumidity();

  // Cek apakah pembacaan valid
  if (isnan(suhu) || isnan(kelembapan)) {
    lcd.setCursor(0, 0);
    lcd.print("Sensor Error!");
    delay(2000);
    return;
  }

  // Menentukan derajat keanggotaan suhu
  float rendahSuhu = max(0, min(1, (30 - suhu) / (30 - 20)));
  float sedangSuhu = max(0, min(1, min((suhu - 20) / (30 - 20), (40 - suhu) / (40 - 30))));
  float tinggiSuhu = max(0, min(1, (suhu - 30) / (40 - 30)));

  // Menentukan derajat keanggotaan kelembapan
  float keringKelembapan = max(0, min(1, (50 - kelembapan) / (50 - 30)));
  float normalKelembapan = max(0, min(1, min((kelembapan - 30) / (50 - 30), (100 - kelembapan) / (100 - 50))));
  float basahKelembapan = max(0, min(1, (kelembapan - 50) / (100 - 50)));

  // Hitung nilai Z berdasarkan aturan
  float z1 = 50, z2 = 20, z3 = 200, z4 = 60, z5 = 30, z6 = 200, z7 = 70, z8 = 40, z9 = 200;
  float alpha1 = min(rendahSuhu, keringKelembapan);
  float alpha2 = min(rendahSuhu, normalKelembapan);
  float alpha3 = min(rendahSuhu, basahKelembapan);
  float alpha4 = min(sedangSuhu, keringKelembapan);
  float alpha5 = min(sedangSuhu, normalKelembapan);
  float alpha6 = min(sedangSuhu, basahKelembapan);
  float alpha7 = min(tinggiSuhu, keringKelembapan);
  float alpha8 = min(tinggiSuhu, normalKelembapan);
  float alpha9 = min(tinggiSuhu, basahKelembapan);

  // Kalkulasi Z menggunakan rumus defuzzifikasi
  float z = (alpha1 * z1 + alpha2 * z2 + alpha3 * z3 + alpha4 * z4 + alpha5 * z5 +
             alpha6 * z6 + alpha7 * z7 + alpha8 * z8 + alpha9 * z9) /
            (alpha1 + alpha2 + alpha3 + alpha4 + alpha5 + alpha6 + alpha7 + alpha8 + alpha9);

  // Cek jika pembagi 0
  if (isnan(z)) z = 0;

  // Output nilai Z ke LED (PWM)
  int pwmValue = map(z, 20, 200, 0, 255); // Map nilai Z ke rentang PWM
  pwmValue = constrain(pwmValue, 0, 255); // Pastikan nilai dalam batas
  analogWrite(LEDPIN, pwmValue);

  // Menampilkan data pada LCD
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Suhu: ");
  lcd.print(suhu);
  lcd.print(" C");

  lcd.setCursor(0, 1);
  lcd.print("Kelembapan: ");
  lcd.print(kelembapan);
  lcd.print(" %");

  lcd.setCursor(0, 2);
  lcd.print("Nilai Z: ");
  lcd.print(z);

  lcd.setCursor(0, 3);
  lcd.print("PWM LED: ");
  lcd.print(pwmValue);

  // Tampilkan data di Serial Monitor (opsional)
  Serial.print("Suhu: ");
  Serial.print(suhu);
  Serial.print(" C, Kelembapan: ");
  Serial.print(kelembapan);
  Serial.print(" %, Nilai Z: ");
  Serial.println(z);

  delay(2000); // Tunggu 2 detik sebelum membaca ulang
}
