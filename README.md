# Smart Coop Controller: Fuzzy Sugeno Logic Implementation

Proyek ini adalah sistem kendali otomatis untuk menjaga kestabilan iklim mikro (suhu dan kelembapan) pada kandang ayam menggunakan mikrokontroler Arduino. Sistem ini menerapkan algoritma Logika Fuzzy Metode Sugeno untuk mengatur intensitas output (Pemanas atau Ventilasi) secara presisi berdasarkan pembacaan sensor lingkungan.

## Standar Kondisi Optimal Kandang Ayam

Bagian ini memberikan referensi suhu dan kelembapan ideal untuk ayam pedaging (broiler) yang dapat digunakan sebagai acuan dalam menentukan parameter batas (threshold) pada aturan Fuzzy Logic.

**Tabel Referensi Suhu Berdasarkan Umur Ayam:**

| Umur (Hari) | Suhu Ideal (°C) | Keterangan |
| :--- | :--- | :--- |
| 0 - 7 Hari (DOC) | 31°C - 33°C | Masa brooding kritis, butuh kehangatan tinggi. |
| 8 - 14 Hari | 28°C - 30°C | Suhu mulai diturunkan bertahap. |
| 15 - 21 Hari | 26°C - 28°C | Bulu mulai tumbuh, kebutuhan panas berkurang. |
| 22 - 28 Hari | 23°C - 26°C | Fase pertumbuhan cepat. |
| > 29 Hari (Dewasa) | 20°C - 23°C | Rentan terhadap heat stress jika suhu > 28°C. |

**Kelembapan Ideal:**
* Range Aman: 50% - 70%
* Bahaya: Di atas 70% (Memicu gas amonia dan penyakit pernapasan).

## Fitur Sistem

* **Monitoring Real-time:** Menggunakan sensor DHT22 untuk akurasi pembacaan suhu dan kelembapan.
* **Logika Adaptif (Fuzzy Sugeno):** Mengambil keputusan kontrol secara halus (tidak kaku seperti termostat on-off), menyesuaikan output berdasarkan derajat keanggotaan input.
* **Output PWM:** Sinyal Pulse Width Modulation (0-255) untuk mengatur intensitas lampu pemanas atau kecepatan kipas.
* **Antarmuka Visual:** Menampilkan data sensor, hasil kalkulasi Fuzzy (Nilai Z), dan nilai PWM pada LCD 20x4.

## Kebutuhan Hardware

1.  **Mikrokontroler:** Arduino Uno / Nano / Mega.
2.  **Sensor:** DHT22 (Sensor Suhu & Kelembapan).
3.  **Display:** LCD 20x4 dengan modul I2C.
4.  **Aktuator:**
    * Lampu Pemanas (Heater) atau Kipas Exhaust.
    * Driver (Modul Relay atau MOSFET IRF520 untuk kontrol PWM).
5.  **Komponen Pendukung:** Breadboard, Kabel Jumper, Resistor Pull-up (jika diperlukan).

## Skema Rangkaian

| Komponen | Pin Arduino | Catatan |
| :--- | :--- | :--- |
| DHT22 Data | Pin 2 | Pastikan library DHT terinstall. |
| LCD SDA | A4 (Uno) / 20 (Mega) | Jalur komunikasi data I2C. |
| LCD SCL | A5 (Uno) / 21 (Mega) | Jalur komunikasi clock I2C. |
| Output (LED/Driver) | Pin 9 | Pin wajib mendukung PWM (~). |

## Analisis Logika Fuzzy

Sistem menggunakan 2 variabel input dan 1 variabel output dengan metode Sugeno Orde-Nol.

### 1. Fuzzifikasi (Input)
Pemetaan nilai sensor ke dalam derajat keanggotaan (0.0 sampai 1.0).

* **Input Suhu:**
    * Rendah (<= 20°C)
    * Sedang (20°C - 40°C)
    * Tinggi (>= 40°C)
* **Input Kelembapan:**
    * Kering (<= 30%)
    * Normal (30% - 100%)
    * Basah (>= 50%)

### 2. Aturan Dasar (Rule Base)
Matriks keputusan 3x3 yang menentukan nilai konstanta output (z) berdasarkan kombinasi input.

*Catatan: Konfigurasi kode saat ini menggunakan logika proporsional positif (Kondisi ekstrem = Output tinggi).*

### 3. Defuzzifikasi (Output)
Nilai tegas (Crisp Output) dihitung menggunakan metode Rata-rata Terbobot (Weighted Average):

Z = (Sum(Alpha * z)) / (Sum(Alpha))

Hasil Z kemudian dipetakan ke rentang PWM 0-255 untuk mengontrol perangkat keras.

## Panduan Konfigurasi (PENTING)

Periksa fungsi aktuator Anda sebelum implementasi:

**A. Jika Menggunakan Kipas (Exhaust Fan)**
Biarkan kode seperti default. Logika saat ini akan meningkatkan putaran kipas saat kelembapan tinggi atau suhu ekstrem untuk membuang udara kotor.

**B. Jika Menggunakan Lampu Pemanas (Heater)**
Anda perlu menyesuaikan nilai konstanta `z` dalam kode agar berbanding terbalik dengan suhu (Negative Feedback).
* Saat Suhu Rendah -> Nilai z harus Tinggi (Pemanas Nyala).
* Saat Suhu Tinggi -> Nilai z harus Rendah (Pemanas Mati).

## Instalasi

1.  Pastikan Arduino IDE telah terpasang.
2.  Install library via Library Manager:
    * `DHT sensor library` oleh Adafruit.
    * `LiquidCrystal I2C` oleh Frank de Brabander.
3.  Buka file `.ino`, verifikasi alamat I2C LCD (biasanya 0x27 atau 0x3F).
4.  Upload kode ke papan Arduino.


Lisensi
Project ini dibuat untuk tujuan pendidikan dan pengembangan sistem kandang cerdas.

Author: Afyuadri Putra Project: Fuzzy Logic Sugeno for Poultry Farming

## Lisensi

Proyek ini dikembangkan untuk tujuan edukasi dan penerapan teknologi pada sektor peternakan.
