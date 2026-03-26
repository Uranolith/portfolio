## Snap-Kategorien für Block-Kompatibilität.
##
## Definiert welche Blöcke an welchen Indikatoren snappen können.
## Verwendet konstante Integer-Werte für verschiedene Block-Typen.
class_name SnapCategory
extends RefCounted

## Akzeptiert nichts
const NONE = -1

## Loop, Case, etc. - normale Control-Flow Blöcke
const FLOW = 0

## Instruction Blöcke - haben eigene Indikatoren
const INSTRUCTION = 1

## Condition Blöcke - für Bedingungen und Ausdrücke
const CONDITION = 2

## Universelle Indikatoren die alles akzeptieren
const ANY = 99

## Gibt den Namen einer Kategorie zurück.
##
## @param category: Die Kategorie-Konstante
## @return: Der lesbare Name der Kategorie
static func get_category_name(category: int) -> String:
	match category:
		NONE:
			return "None"
		FLOW:
			return "Flow"
		INSTRUCTION:
			return "Instruction"
		CONDITION:
			return "Condition"
		ANY:
			return "Any"
		_:
			return "Unknown"

## Prüft ob ein Block an einem Indikator snappen kann.
##
## Vergleicht die Block-Kategorie mit den akzeptierten Kategorien des Indikators.
##
## @param block_category: Die Kategorie des Blocks
## @param indicator_accepts: Array der akzeptierten Kategorien
## @param debug: Optional: Aktiviert Debug-Ausgaben
## @return: true wenn Snap möglich, false sonst
static func can_snap(block_category: int, indicator_accepts: Array, debug: bool = false) -> bool:
	if indicator_accepts.is_empty():
		if debug:
			print("[SnapCategory] Snap abgelehnt: Indikator akzeptiert nichts (leeres Array)")
		return false
	
	if indicator_accepts.has(ANY):
		if debug:
			print("[SnapCategory] Snap erlaubt: Indikator akzeptiert ANY")
		return true
	
	var result = indicator_accepts.has(block_category)
	if debug:
		if result:
			print("[SnapCategory] Snap erlaubt: ", get_category_name(block_category), " wird akzeptiert")
		else:
			print("[SnapCategory] Snap abgelehnt: ", get_category_name(block_category), " wird nicht akzeptiert (erwartet: ", _format_accepts(indicator_accepts), ")")
	return result

## Hilfsfunktion für Debug-Ausgabe.
##
## Formatiert ein Array von Kategorien als lesbaren String.
##
## @param accepts: Array der Kategorien
## @return: Komma-separierte Liste der Kategorie-Namen
static func _format_accepts(accepts: Array) -> String:
	var names = []
	for cat in accepts:
		names.append(get_category_name(cat))
	return ", ".join(names)
