# Java Resistor Library

Eine Java-Bibliothek zur Darstellung und Umrechnung von Widerstands-Farbcodes.  
Entwickelt im Rahmen einer Hausarbeit im Wahlpflichtmodul Java SS2024 an der Hochschule Trier – Umwelt-Campus Birkenfeld.

---

## Überblick

Die **Java Resistor Library** ermöglicht das Erstellen, Berechnen und Analysieren von elektrischen Widerständen basierend auf Farbcodes oder Ohm-Werten.

Die Bibliothek unterstützt:

- Umrechnung zwischen Widerstands-Farbcodes und Ohm-Werten  
- Berechnung von Toleranzen und Temperaturkoeffizienten  
- Unterstützung von 4-, 5- und 6-Band-Widerständen  
- GUI-Tool zur interaktiven Berechnung  

Das Projekt verbindet Elektronik-Grundlagen mit objektorientierter Programmierung in Java. 

---

## Features

✔ Darstellung von Widerständen als Java-Objekte  
✔ Umrechnung Farbcodes ↔ Widerstandswert  
✔ Unterstützung für 4-, 5- und 6-Band-Resistoren  
✔ Berechnung von Toleranz und Temperaturkoeffizient  
✔ GUI-Resistor-Calculator mit Java Swing  
✔ Umfangreiche Unit-Tests  

---

## Design & Architektur

Die Bibliothek basiert auf einer abstrakten `Resistor`-Klasse mit Spezialisierungen für unterschiedliche Bandanzahlen:

- `ResistorB4`
- `ResistorB5`
- `ResistorB6`

Zur Codierung der Farbwerte wurden **HashMaps** verwendet, da sie flexible und effiziente Zuordnungen zwischen Farben und Widerstandswerten ermöglichen und leicht erweiterbar sind.

Beispiele für Designentscheidungen:

- HashMaps statt Enums → bessere Unterstützung für Float/Double Werte  
- Factory-Methoden zum Erstellen von Widerständen  
- Validierung der Eingaben mit Exceptions  

---

## GUI

Zusätzlich enthält das Projekt eine grafische Oberfläche auf Basis von **Java Swing**.

Features der GUI:

- Auswahl der Bandanzahl  
- Auswahl von Farben per ComboBox  
- Berechnung von Widerstand oder Farben  
- Dynamische Anzeige je nach Bandanzahl  
- Benutzerfreundliches Layout mit GroupLayout  

Die GUI wird über `EventQueue.invokeLater()` gestartet, um Thread-Sicherheit zu gewährleisten. 

---

## Installation

Repository klonen:

```bash
git clone https://github.com/Uranolith/Java_ResistorLib.git
````

Projekt bauen (z. B. mit Maven oder Gradle):

```bash
mvn clean install
```

Alternativ kann die erzeugte `.jar`-Datei in andere Projekte eingebunden werden. 

---

## Nutzung

### 1. Resistor aus Farbcodes erstellen

```java
ResistorLib.Resistor resistorB4 = new ResistorLib.ResistorB4(new String[]{"red","violet","yellow","gold"});
```

### 2. Resistor aus Ohm-Wert erstellen

```java
ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(470);

ResistorLib.Resistor resistorWithTolerance = ResistorLib.Resistor.createResistorFromValue(4700, 2f);
```

### 3. Eigenschaften abfragen

```java
System.out.println(resistor.getValue());
System.out.println(resistor.getTolerance());
System.out.println(resistor.getMultiplier());
System.out.println(resistor.getColors());
```

Die Bibliothek prüft automatisch auf ungültige Eingaben und wirft eine `IllegalArgumentException`, wenn Farben oder Werte nicht gültig sind. 

---

## Tests

Die Tests prüfen:

* korrekte Berechnung von Widerstandswerten
* Validierung der Farbbänder
* Grenzwerte und Fehlerfälle
* Eingabevalidierung

Es existiert ein bekanntes Rundungsproblem bei bestimmten Float-Berechnungen, das durch Toleranzwerte abgefangen wurde. 

Tests ausführen:

```bash
mvn test
```

---

## Projektkontext

Dieses Projekt wurde als Hausarbeit im Modul **Java SS2024** erstellt.

Autoren:

* Florian Wittmann
* Matthias Beck
* Philipp Göttel

---

## Mögliche Erweiterungen

* Unterstützung weiterer Widerstandstypen
* Web-Interface oder REST-API
* Integration in Elektronik-Simulatoren
* Verbesserte Rundungslogik

---

## Lizenz

Freie Nutzung für Studium und Portfolio-Projekte.
Bei Verwendung bitte auf das Originalprojekt verweisen.

---
