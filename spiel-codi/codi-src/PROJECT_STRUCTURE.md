# Codi Learning Game - Projekt-Struktur

## Gesamtübersicht

```
codi-learning-game/
├── blocks/                 # Block-System (Szenen, Daten, Implementation)
├── character/              # Character-Controller + Szene
├── gui/                    # Benutzeroberfläche (Scenes & Scripts)
├── interpreter/            # Interpreter & Executor
├── levels/                 # Level-Daten und Loader
├── icon.svg                # Projekt-Icon
└── project.godot           # Godot-Projekt-Konfiguration
```

---

## Hauptmodule

### `blocks/` - Block-System
Das Herzstück des visuellen Programmier-Systems: Szenen, Datenklassen und Implementierungen der Blöcke.

```
blocks/
├── resources/                  # Shared Resources (Fonts, Theme, Spritesheets)
│   ├── blocks_font.tres
│   ├── default_theme.tres
│   ├── GoldenRetriever_spritesheet_free.png
│   └── OpenSans-Semibold.ttf
├── scenes/                     # Block-Szenen (.tscn)
│   ├── base_block.tscn
│   ├── case_distinction_block.tscn
│   ├── condition_block.tscn
│   ├── loop_block.tscn
│   └── program_block.tscn
└── scripts/
    ├── core/                   # Basis-Klassen (Draggable, Container, Registry, Spawner)
    │   ├── BlockRegistry.gd
    │   ├── BlockSpawner.gd
    │   ├── ContainerBlock.gd
    │   └── DraggableBlock.gd
    ├── types/                  # Konkrete Block-Implementierungen
    │   ├── BaseBlock.gd
    │   ├── CaseDistinctionBlock.gd
    │   ├── ConditionBlock.gd
    │   ├── LoopBlock.gd
    │   └── ProgramBlock.gd
    ├── data/                   # Serialisierungs-Datenklassen (BlockData, Condition, Loop...)
    │   ├── BlockData.gd
    │   ├── ConditionBlockData.gd
    │   ├── CaseDistinctionBlockData.gd
    │   └── LoopBlockData.gd
    └── util/                   # Hilfsklassen (SnapZone, SnapTarget, DragState...)
        ├── ConditionZoneData.gd
        ├── DragState.gd
        ├── InstructionZoneData.gd
        ├── SnapCategory.gd
        ├── SnapTarget.gd
        └── SnapZone.gd
```

Hinweis: In `blocks/resources/` befinden sich außerdem Import-Metadaten (`*.import`) und ggf. `.uid`-Dateien neben den Script-Ressourcen.

---

### `character/` - Character-System

```
character/
├── character.tscn               # Charakter-Szene (Sprite/Animation)
└── CharacterController.gd       # Bewegungen, Aktionen und Condition-Checks
```

Wichtige Methoden (Beispiel): `move_forward()`, `move_backward()`, `turn_left()`, `turn_right()`, `jump()`, `interact()`, `wait()`, sowie Condition-Checks wie `can_move_forward()`, `is_at_goal()`.

---

### `interpreter/` - Interpreter & Executor

```
interpreter/
└── scripts/
    ├── BlockInterpreter.gd      # Traversiert Blöcke und erzeugt Instructions
    ├── CharacterExecutor.gd     # Führt Instructions asynchron auf dem Character aus
    └── Instruction.gd           # Instruction-Datenstruktur
```

Kurzbeschreibung:
- `BlockInterpreter.gd` konvertiert die visuellen Blöcke in eine Liste von Instructions (z. B. MOVE_FORWARD, LOOP_FOR, CASE_IF).
- `CharacterExecutor.gd` führt die Instructions schrittweise und asynchron aus, unterstützt Pause/Resume und Schleifen.

---

### `gui/` - Benutzeroberfläche

```
gui/
├── scenes/                     # UI-Szenen
│   ├── block_canvas_container.tscn
│   ├── game_view_container.tscn
│   ├── level_details_container.tscn
│   ├── level_overlay.tscn
│   └── ui.tscn
└── scripts/
    ├── ui.gd
    ├── camera/                 # Kamerasteuerung
    │   └── CameraController.gd
    ├── containers/             # Container-Controller (z. B. Menüs, Overlays)
    ├── menus/
    │   ├── BlockSpawnMenu.gd
    │   └── ContextMenuController.gd
    └── render/                 # Renderer / Utility für UI
        ├── LabelRenderer.gd
        └── SnapIndicatorRenderer.gd
```

UI-Layout: Linke Seite ist der Block-Programmierbereich mit Kamera, rechts oben die Game-View (SubViewport) und rechts unten Level-Details.

---

### `levels/` - Level-Definition und Loader

```
levels/
├── LevelData.gd
├── LevelLoader.gd
└── data/
    └── level_test.json
```

---

## Namenskonventionen (Projektweit)

- Ordner: `snake_case` (z. B. `block_canvas/`)
- Skripte: `PascalCase.gd` mit `class_name` (z. B. `LoopBlock.gd`)
- Szenen: `snake_case.tscn` (z. B. `loop_block.tscn`)
- Ressourcen: `snake_case.tres` / `*.png`, `*.ttf`

---

## Architektur-Prinzipien (Kurz)

- Modularität: Jedes Modul (`blocks/`, `gui/`, `interpreter/`, `levels/`) hat klare Verantwortlichkeiten.
- Trennung von Daten & Darstellung: `blocks/scripts/data/` vs. `blocks/scripts/types/` + `blocks/scenes/`.
- Single Responsibility: Jede Klasse/Resource hat eine klar definierte Aufgabe.

---

**Version**: 2.1
**Datum**: 2026-02-10
