# UI/UX SPECIFIKACE - ZLODĚJ MĚLNÍK
## VERZE 3.0 - MĚLNÍK 2025 | Komplexní Specifikace Uživatelského Rozhraní

**Projekt**: Zloděj Mělník  
**Cílové zařízení**: Android 1280x720px (svislá orientace)  
**Grafický styl**: Textured Reality + Vintage Modern  
**Accessibility**: WCAG 2.1 AA standard

---

## 1. HLAVNÍ MENU

### 1.1 Start Screen

```
┌───────────────────────────────────┐
│                                   │
│      ZLODĚJ MĚLNÍK                │
│      Año 2025                     │
│                                   │
│    [NEW GAME]                    │
│    [CONTINUE]                    │
│    [SETTINGS]                    │
│    [CREDITS]                     │
│                                   │
│  Background: Mělnický hrad       │
│  s neonovými prvky               │
│                                   │
└───────────────────────────────────┘
```

Animace při startu:
- Nejdřív vidíš logo
- Pak se objeví Mělnický hrad se zvukovým efektem
- Nabídka se postupně zjeví

### 1.2 Obrazovka pro volbu jména

```
┌──────────────────────────────────────┐
│                                      │
│  ZLODĚJ MĚLNÍK                      │
│  START GAME                         │
│                                      │
│  Vítej v Mělníku, roku 2025...     │
│  Jak se jmenuješ?                   │
│                                      │
│  [________________]                │
│   Maximálně 20 znaků               │
│                                      │
│  [CONTINUE] [RANDOM NAME]          │
│  [BACK]                            │
│                                      │
└──────────────────────────────────────┘
```

Přizpůsobení:
- Pokud hráč zadá jméno, používá se v celé hře
- Jméno se zobrazuje v dialozích, textech
- Random generator: "Ivan", "Petr", "Markéta", atd.

---

## 2. KONCEPT ROZHRANÍ (DESIGN PATTERNS)

Vycházíme z osvědčeného patternu jasného oddělení „příběh/roleplay“ a „taktika/plán“. Rozhraní je definováno **6 klíčovými design patterny**:

### 2.1 Pattern: Stabilní Třípásmový Layout
Udržujeme jeden stabilní layout, kde se mění pouze obsah střední části.
1.  **HORNÍ PÁS ("MOZEK")**: Informační vrstva. Texty, čas, kontext, stav mise.
2.  **STŘEDNÍ PÁS ("SVĚT")**: Hlavní viewport. Buď adventurní scéna, nebo technický půdorys.
3.  **SPODNÍ PÁS ("OVLADAČ")**: Interakční vrstva. Menu příkazů, timeline, ovládání simulace.

**Cíl**: Hráč má vždy jistotu – nahoře čte, uprostřed vidí situaci, dole ovládá.

### 2.2 Pattern: Dualita UI (Story vs Tactics)
Rozhraní jasně vizuálně odděluje dva herní režimy:
*   **Příběhový mód**: Střed je detailní, "filmové" prostředí s atmosférou, animacemi a street-artem.
*   **Taktický mód**: Střed se přepne na čistý **top‑down půdorys** (blueprint). Vizuál připomíná technický výkres bez dekorací.
*   **Přepnutí**: Musí být okamžitě rozeznatelné (změna palety, tloušťky linií, strohost). Jde o dva overlaye nad stejnou kostrou.

### 2.3 Pattern: Ikonografický Jazyk Mapy
V taktickém režimu má **čitelnost absolutní přednost před realismem**.
*   **Objekty**: Dveře, okna, sejfy, rozvaděče jsou reprezentovány jasnými, unifikovanými symboly/ikonami (jeden symbol pro "zamčené dveře", jeden pro "kořist").
*   **Postavy**: Zobrazeny jako malé sprity.
*   **Trasy**: Vizualizovány jako barevné čáry, šipky kroků nebo "ghost" animace při přehrávání ("duch" postavy ukazuje budoucí pohyb).

### 2.4 Pattern: Vizuální vnímání Času
Čas není jen číslo, je to prostorová veličina na mapě.
*   **Zobrazení**: Kromě digitálních hodin nahoře je čas vidět hlavně na **délce trvání akcí** (bubliny nad trasou s ikonkou hodin).
*   **Timeline**: Ve spodním panelu je časová osa ukazující synchronizaci postav.
*   **VCR Ovládání**: Přehrávání plánu jako videa (Play, Pause, Fast-Forward, Step-by-Step).

### 2.5 Pattern: Příkazová Paleta (Spodní Panel)
Spodní oblast funguje jako **sada nástrojů/paleta**.
*   **Položky**: Pevná sada ikon + krátkých textů (WALK, USE, PICK, WAIT, SIGNAL).
*   **Kontextovost**: Ikony se aktivují/deaktivují podle vybraného objektu na mapě.
*   **Módy**:
    *   *Record*: Zadávání příkazů do fronty.
    *   *Simulate*: Pasivní sledování ("Přehrávání").

### 2.6 Pattern: Mozek Loupeže (Horní Panel)
Horní "balloon area" je centrem kontextu.
*   **Funkce**: Kombinace **deníku** (story) a **logu** (systém).
*   **Obsah**:
    *   *Story*: "Matt: Tohle bude fuška."
    *   *System*: "Dveře: Zabezpečení Level 3 (Alarm)."
    *   *Feedback*: "Varování: Stráž tudy projde v 00:15."
*   **Interakce**: Možnost scrollu historií zpět.



---

## 3. ADVENTURE MODE (PŘÍBĚHOVÁ VRSTVA)

Střední pás zobrazuje svět "filmově" - detailní prostředí (ulice, hospoda, interiéry) s postavami a atmosférou.

### 3.1 Horní panel - Dialogy a Info
```
┌──────────────────────────────────────────┐
│ TIME: 14:35    MONEY: 15,240 CZK    [☰] │
├──────────────────────────────────────────┤
│ HONZA (Kontakt):                         │
│ "Poslouchej, [JMÉNO]. MelTech má nové    │
│  zabezpečení. Budeš potřebovat profíka." │
│                                          │
└──────────────────────────────────────────┘
```

### 3.2 Spodní panel - Interakce
Nabídka se mění podle kontextu (kde jsi, s kým mluvíš).
```
┌──────────────────────────────────────┐
│ [TALK] [LOOK] [MOVE] [BUY INFO]      │
└──────────────────────────────────────┘
```

### 3.3 Lokační panel (Overlay ve středu)
Při vstupu do lokace (např. Hospoda):
*   Zobrazí seznam NPC.
*   Status Heat Levelu a Atmosféry.

---

## 4. PLANNING MODE (TAKTICKÁ VRSTVA)

Střední pás se přepne na **Technický Blueprint**. Zmizí dekorace, zůstane čistá, čitelná top-down mapa.

### 4.1 Vizualizace (Střední pás)
*   **Objekty**: Jednoduché obdélníky. Dveře, okna, sejfy a kamery mají jasné, kontrastní ikony (Symbol > Realismus).
*   **Trasy**: Barevné čáry pro každou postavu.
*   **Ghost Run**: Průhledné "duchové" verze postav ukazují nahraný pohyb při přehrávání.

### 4.2 Horní panel - "Mozek loupeže"
Zobrazuje technická data a logiku.
```
┌──────────────────────────────────────────┐
│ INFO: Dveře (Zadní vchod)               │
│ STATUS: Zamčeno (Level 2)                │
│ POZNÁMKA: "Stráž tudy chodí v 00:30"     │
└──────────────────────────────────────────┘
```

### 4.3 Spodní panel - Příkazová paleta & Timeline
Klíčový prvek pro ovládání času.

**Levá část (Příkazy):**
*   [WALK] [USE TOOL] [WAIT] [SIGNAL]
*   Ikony nástrojů (Páčidlo, Šperhák) se aktivují kontextově.

**Pravá část (Timeline):**
*   Časová osa s "bublinami" akcí.
*   Ovládání: [REC] [PLAY] [PAUSE] [STEP >>]
*   Barevné zvýraznění "drahých" kroků (dlouhé akce).

```
┌──────────────────────────────────────────────────────────────┐
│ [WALK] [USE] [WAIT] │  Timeline: 00:00 ----[●]---- 00:15   │
│ [SIGNAL] [CANCEL]   │  <<  [ PLAY ]  >>  [COMMIT]          │
└──────────────────────────────────────────────────────────────┘
```

---

## 5. ACTION MODE (EXEKUCE)

Sleduješ výsledek. Střední pás se vrací do detailnějšího zobrazení (nebo zůstává taktický - volitelné), ale bez možnosti editace.

### 5.1 Horní panel - Live Log
Zobrazuje rádiovou komunikaci a varování.
*   "JOSEF: Jsem na místě."
*   "SYSTEM: Kamera 2 - Detekce pohybu!"

### 5.2 Spodní panel - Intervence
Omezené možnosti zásahu.
*   [ABORT] (Zrušit akci)
*   [SIGNAL: GO] (Urychlit)
*   [SIGNAL: STOP] (Zastavit tým)

---

## 6. RESULT SCREEN

```
┌─────────────────────────────────────────────────────┐
│ VÝSLEDEK MISE                                   [X] │
├─────────────────────────────────────────────────────┤
│                                                     │
│  KOMERCNÍ BANKA MĚLNÍK                            │
│  ✅ LOUPEŽ ÚSPĚŠNÁ!                               │
│                                                     │
│  RANK: ⭐⭐⭐⭐⭐ S-RANK (Perfektní!)             │
│                                                     │
│  📊 STATISTIKA:                                    │
│  ├─ Čas: 2:35 (z max 10:00)                      │
│  ├─ Detekce: 0 (bez varování)                    │
│  ├─ Hluk: 15 dB (velmi tichý)                    │
│  ├─ Mrtvých: 0 (non-letální)                     │
│  └─ Zranění v týmu: 0                            │
│                                                     │
│  💰 FINANČNÍ VÝSTUP:                              │
│  ├─ Hrubý lup: 200,000 CZK                       │
│  ├─ Administrátor (15%): -30,000 CZK            │
│  ├─ Josef (Řidič 20%): -34,000 CZK              │
│  ├─ Petra (Hacker 25%): -42,500 CZK             │
│  ├─ Milan (Silák 15%): -25,500 CZK              │
│  └─ TVŮJ PODÍL: 68,000 CZK ✓                    │
│                                                     │
│  📈 OSTATNÍ BONUSY:                               │
│  ├─ Reputace: +50 (nyní 95/100)                 │
│  ├─ Heat Level: +15 (nyní 45%)                  │
│  ├─ Skill XP: +20 (Petra si zvýšila Electronics) │
│  └─ Bonus bez detekce: +50,000 CZK! ✨          │
│                                                     │
│  👥 TÝM SPOKOJNOST:                               │
│  ├─ Josef: VELMI SPOKOJENÝ (+10 loyalty)        │
│  ├─ Petra: SPOKOJENÁ                            │
│  └─ Milan: VÝRAZNĚ NESPOKOJENÝ (-20 loyalty)    │
│     └─ Chtěl 150k, dostal 25.5k... zlobus!      │
│                                                     │
│  ⚠️ UPOZORNĚNÍ:                                   │
│  Milan ti hrozil, že tě zradí polici!           │
│  NALÉHAVĚ: Dej mu bonus nebo si ho vezmi        │
│  do další mise jako "make-up"                    │
│                                                     │
│ [POKRAČOVAT NA MAPU] [ULOŽ HRU]                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 6. ACCESSIBILITY & DESIGN GUIDELINES

### 6.1 Barevné schéma

**Primární barvy**:
- #1A1A2E (Temně modrá pozadí)
- #16C784 (Neon zelená - úspěch)
- #FF6B6B (Neon červená - varování)
- #FFE66D (Neon žlutá - upozornění)

**Fontů**:
- Nadpisy: Roboto Bold (32px)
- Běžný text: Inter Medium (16px)
- Malý text: Inter Regular (12px)

### 6.2 Kontrola přístupu

- ✅ Kontrast textu: 4.5:1 (WCAG AA)
- ✅ Podpora čteče obrazovky (TalkBack/VoiceOver)
- ✅ Haptická zpětná vazba (vibrace)
- ✅ Možnost zvětšit text (+200%)