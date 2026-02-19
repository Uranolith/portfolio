---

# Shrouded Dales – Action-Adventure Prototype

**Shrouded Dales** ist ein 2D-Action-Adventure-Sidescroller, entwickelt als Teamprojekt im Modul *Spieleentwicklung SS2023* an der Hochschule Trier – Umwelt-Campus Birkenfeld. 

Das Projekt demonstriert Gameplay-Systeme wie State-Machines, Inventory-Management und modulare Audio-Systeme in der Godot-Engine.

---

#  Überblick

In einer Fantasy-Welt untersucht die Wächterin **Cirilla** das Auftauchen von Untoten und wird in eine unbekannte Region teleportiert, aus der sie einen Weg zurück finden muss. 

Das Spiel ist als Prototyp eines Action-Adventure-RPGs mit Erkundung, Kampf und Loot-Mechaniken konzipiert.

---

## 🎬 Gameplay Showcase

| Feature | Video |
|---------|------|
| Combat | ![Combat](doc/media/SD_combat.mp4) |
| Movement | ![Movement](doc/media/SD_movement.mp4) |
| Inventory | ![Inventory](doc/media/SD_inventory.mp4) |
| Magic | ![Magic](doc/media/SD_magic.mp4) |
| Death | ![Death](doc/media/SD_dead.mp4) |

---

#  Features

###  Gameplay

* Player & Enemy **State Machines**
* Kampf- und Bewegungsmechaniken
* Item-Drops & Loot-System
* Skills mit Mana-Kosten
* Inventar mit Equipment-Slots & Hotbar
* Chest-System für Item-Transfer

###  Leveldesign

* Tilemap-basierte Levels
* Mehrere Level-Bereiche mit eigener Musik
* Mehrschichtige Parallax-Umgebung
* Auto-Tilings & Pattern-System

###  Audio & UI

* Dynamischer Audio-Controller mit Crossfade
* Soundscape mit Musik & SFX
* Parallax-Main-Menu
* Options- und Settings-Menüs

###  Architektur

* Objektorientiertes GDScript-Design
* Abstrakte State-Klassen
* Modularer Audio-Controller
* Ressourcensystem für Items & Skills

Diese Systeme werden im Projektbericht ausführlich beschrieben. 

---

#  Demo

 **Spiel spielen:**
[https://umwelt-campus.itch.io/shrouded-dales](https://umwelt-campus.itch.io/shrouded-dales)

 **Projektbericht:**
[Projektbericht als PDF öffnen](doc/Project_SD.pdf)

---

#  Team

* Florian Wittmann
* Christina Kehrbach
* Philipp Göttel 

Betreuer: Dr. Markus Schwinn
Hochschule Trier – Umwelt-Campus Birkenfeld.

---

#  Technologie-Stack

* **Engine:** Godot 4.0
* **Sprache:** GDScript
* **Tools:** Tilemap-Editor, AnimationTree, AudioBus
* **Assets:** Itch.io Asset Packs & freie Musikquellen (siehe Projektbericht) 

---

#  Wichtige Lerneffekte

* Design und Debugging komplexer State-Machines
* Modularisierung von Audio-Systemen
* UI-Design mit Godot Control-Nodes
* Leveldesign mit Tilemaps und Parallax-Layern
* Teamarbeit im Game-Development-Workflow

Im Projektbericht werden Probleme wie rekursive Animation-States oder Audio-Handling detailliert beschrieben. 

---

#  Installation & Start

### Voraussetzungen

* Godot Engine 4.0

### Projekt starten

```bash
git clone <repo>
cd shrouded-dales
```

Dann Projekt in Godot öffnen und `Main.tscn` starten.

---

#  Lizenz

Projekt zu Studien- und Portfolio-Zwecken.
Assets gehören ihren jeweiligen Urhebern (siehe Projektbericht).