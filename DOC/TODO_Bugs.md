# TODO LIST & BUG REPORT - ZLODĚJ MĚLNÍK

**Datum:** 15. ledna 2026 (Aktualizováno)
**Autor:** Gemini CLI Agent

## 1. Kritické Chyby (Bugs)
| ID | Komponenta | Popis | Stav |
| :--- | :--- | :--- | :--- |
| BUG-001 | Test Runner | Vyřešeno přidáním `disable_saving` v `SaveManager.gd`. | **FIXED** |
| BUG-002 | CLI | Trvá, ale používáme absolutní cesty. | **RESOLVED** |
| BUG-003 | Ghost Run | Chybějící metoda `record_frame` v `GhostRunController.gd`. | **FIXED** |

## 2. Implementační Nedodělky
- [x] **SFX Library:** Ověřeno unit testem (soubory existují).
- [x] **Integrace:** Provedena ve všech klíčových skriptech.
- [x] **Manuální Audio Test:** Vytvořena testovací scéna `AudioTest.tscn`.
- [x] **Ekonomika:** Opraveno chybějící API (`add_money`, `spend_money`).

## 3. Závěr
Core systémy jsou stabilní a audio je plně integrováno. Projekt je připraven pro další rozvoj (např. vizuální polish nebo design misí).