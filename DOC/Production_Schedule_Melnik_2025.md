# PRODUCTION SCHEDULE - ZLODĚJ MĚLNÍK
## VERZE 1.0 - PROJECT PLAN 2025

Tento dokument slouží k řízení vývoje a definici milníků projektu "Zloděj Mělník". Zabraňuje "feature creep" a udržuje fokus na MVP (Minimum Viable Product).

---

## 1. ROADMAPA PROJEKTU

### Fáze 1: PROTOTYP (Core Mechanics)
**Cíl**: Hratelná smyčka "Adventure -> Planning -> Action" s placeholder grafikou.
**Deadline**: Q2 2025
- [ ] Funkční pohyb postavy (Adventure top-down).
- [ ] Implementace "Ghost Run" systému (nahrávání a přehrávání pohybu).
- [ ] Základní interakce (otevřít dveře, sebrat item).
- [ ] UI Skeleton (přepínání 3 pásů).

### Fáze 2: ALPHA (Content & Systems)
**Cíl**: Kompletní první mise se všemi systémy a finálním vizuálním stylem.
**Deadline**: Q3 2025
- [ ] Vytvoření pixel-art tilesetů (Adventure město + Blueprint).
- [ ] Implementace AI stráží (Vision Cones, Patrol Paths).
- [ ] Zvukový engine (kroky, základní atmosféra).
- [ ] První kompletní level: "MelTech - Získání disku".

### Fáze 3: BETA (Polish & Expansion)
**Cíl**: Odladěná hra s více misemi, připravená pro testery.
**Deadline**: Q4 2025
- [ ] Ekonomický systém (nákup vybavení, najímání posádky).
- [ ] Příběhové dialogy a cutscény.
- [ ] Alespoň 3 hratelné mise.
- [ ] UI Polish (animace, zvuky tlačítek).

### Fáze 4: GOLD MASTER (Release)
**Cíl**: Vydání na Android.
**Deadline**: 2026
- [ ] Bugfixing.
- [ ] Lokalizace (CZ/EN).
- [ ] Marketingové materiály.

---

## 2. BACKLOG (TASK LIST)

### 2.1 Programování (Code)
- **Mechaniky**
    - [ ] `PlayerController.gd`: Implementovat nahrávání inputů do pole (pro Ghost Run).
    - [ ] `GuardAI.gd`: Implementovat stavový automat (Patrol -> Suspicious -> Alert).
    - [ ] `InteractionSystem`: Systém pro "Lockpick minihru".
- **Systémy**
    - [ ] `SaveSystem`: Ukládání stavu mise a inventáře.
    - [ ] `AudioManager`: Adaptivní změna hudby při změně módu.

### 2.2 Grafika (Art)
- **Prostředí**
    - [ ] `Tileset_Blueprint`: Zdi, okna, dveře (pixel-art symboly).
    - [ ] `Tileset_City`: Asfalt, lampy, budovy (noc).
- **Postavy**
    - [ ] `Sprite_Player`: Idle, Walk, Run, Sneak animace (4 směry).
    - [ ] `Sprite_Guard`: To samé + animace s baterkou.
- **UI**
    - [ ] `Icons_Equipment`: Ikonky pro Lockpick, Crowbar, EMP.
    - [ ] `Panel_Timeline`: VCR ovládací prvky (Play/Rec/Pause).

### 2.3 Audio (Sound)
- [ ] **SFX**: Kroky (Concrete, Carpet), Lockpick success/fail, Alarm siréna.
- [ ] **Music**: Adventure theme (Rainy jazz), Planning theme (Minimal synth).
- [ ] **Voice**: Dabing pro tutoriál (Honza).

### 2.4 Design & Levely
- [ ] `Mission_01_MelTech`: Design půdorysu, rozmístění kamer a stráží.
- [ ] `Mission_00_Tutorial`: Skriptovaný průchod základními mechanikami.
- [ ] `Economy_Table`: Nastavení cen vybavení vs. odměna za mise.

---

## 3. RIZIKA A MITIGACE

| Riziko | Pravděpodobnost | Dopad | Mitigace |
| :--- | :---: | :---: | :--- |
| **Feature Creep** | Vysoká | Kritický | Striktní dodržování GDD, odmítání mechanik mimo jádro (např. řízení aut). |
| **Technická náročnost Ghost systému** | Střední | Vysoký | Včasný prototyp (Fáze 1) pro ověření proveditelnosti. |
| **Nedostatek assetů** | Střední | Střední | Použití placeholderů ("greyboxing") co nejdéle, případně nákup assetů. |
| **Právní problémy (názvy)** | Nízká | Vysoký | Používání fiktivních názvů (např. Mělnická Spořitelna místo KB). |