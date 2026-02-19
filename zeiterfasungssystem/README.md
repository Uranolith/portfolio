# RFID Time Tracking System

Ein IoT-basiertes Zeiterfassungssystem mit RFID-Authentifizierung, entwickelt zur automatisierten Arbeitszeiterfassung für Einzelpersonen und Teams.

Das System kombiniert **ESP8266-Hardware**, RFID-Reader, Web-Server und Datenbank zu einer vollständigen Tracking-Lösung. 

---

#  Überblick

Ziel des Projekts war ein benutzerfreundliches System zur automatischen Arbeitszeiterfassung ohne manuelle Eingaben, geeignet für Coworking-Spaces oder Homeoffice. 

Die Anmeldung erfolgt über RFID-Karten oder NFC-Tags.

---

#  Features

###  Authentifizierung

* RFID Login via RC522 Reader
* NFC-Tags oder Karten
* API-Key geschützte Serverkommunikation 

###  Zeiterfassung

* Login/Logout Tracking
* Speicherung von Unix Epoch Time
* Anzeige von Status und Logs im Web-UI 

###  Web-Interface

* Benutzerverwaltung
* Kartenverwaltung
* Positionsverwaltung
* Log-Anzeige
* Responsive UI mit Bootstrap + Pug Templates 

###  Architektur

* ESP8266 Firmware
* Flask API Server
* SQLite Datenbank
* Docker-Container Deployment 

---

#  Systemarchitektur

```
RFID Tag
   ↓
RC522 Reader
   ↓
ESP8266 Firmware
   ↓ (JSON via API)
Flask Server
   ↓
SQLite Database
   ↓
Web UI
```

Die Firmware sendet RFID-ID + Zeit an den Server, der Einträge speichert und im Web-Interface darstellt. 

---

#  Entwickler

* Florian Wittmann
* Raffael Schäfer 

---

#  Technologie-Stack

### Hardware

* ESP8266 NodeMCU
* RC522 RFID Reader
* NFC Karten
* 3D-gedrucktes Gehäuse
* Eigene Verbindungsplatine (KiCad Design) 

### Software

* Python Flask API
* SQLite Datenbank
* Docker
* Bootstrap + Pug + Alpine.js Frontend 

---

#  Installation

## Server starten

```bash
docker build -t time-tracker .
docker run -p 5000:5000 time-tracker
```

Oder lokal:

```bash
python app.py
```

Server auf `0.0.0.0` setzen, damit ESP Zugriff hat. 

---

## Firmware konfigurieren

In `credentials.h` und `api.h` eintragen:

```
WiFi SSID
WiFi Password
API Key
Server Adresse
```

Diese Dateien sind bewusst ausgelagert, damit keine Zugangsdaten im Code stehen. 

---

#  Projektbericht

 [Projektbericht öffnen](version_20240311.pdf)

---

#  Lerneffekte

* IoT-Hardware-Integration
* REST-API Design
* Web-UI Entwicklung
* Docker Deployment
* Datenbankmodellierung
* RFID-Kommunikation
* Hardware-PCB-Design in KiCad

---

#  Mögliche Erweiterungen

* Offline-Zeiterfassung
* PostgreSQL statt SQLite
* Login-System im Web-UI
* Automatische Sommer/Winterzeit
* Hardware-Feedback LEDs
* Microservice-Architektur 

---

#  Lizenz

Projekt für Studien- und Portfolio-Zwecke.
Hardware-Design und Software frei nutzbar. 
Bei Verwendung bitte auf das Originalprojekt verweisen.