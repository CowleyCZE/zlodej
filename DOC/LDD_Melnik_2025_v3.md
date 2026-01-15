# LEVEL DESIGN DOCUMENT - ZLODĚJ MĚLNÍK
## VERZE 3.0 - MĚLNÍK 2025 | Kompletní Design Misí a Lokací

**Projekt**: Zloděj Mělník  
**Lokace**: Mělník a okolí, Česká republika (2025)  
**Obsah**: World Layout, Adventure Lokality, Mission Design, Level Progression

---

## 1. ADVENTURE MODE - MĚLNÍK 2025

### 1.1 Light-Up Mapa Mělníka

Mělník je rozdělena na **8 HLAVNÍCH REGIONŮ**:

```
┌─────────────────────────────────────┐
│  MAPA MĚLNÍKA - 2025                │
├─────────────────────────────────────┤
│                                     │
│  [1] STARÉ MĚSTO (Historické jádro) │
│      └─ Hrad, Kostely, Staré hospody│
│                                     │
│  [2] CENTRUM (Moderní centrum)      │
│      └─ Banky, Nákupní centra, Kina │
│                                     │
│  [3] VÝCHODNÍ ČTVRŤ (Průmysl)      │
│      └─ Staveniště, Továrny, Depo  │
│                                     │
│  [4] ZÁPADNÍ ČTVRŤ (Luxus)          │
│      └─ Soukromé vily, Bohatá sídla │
│                                     │
│  [5] SEVERO-VÝCHODNÍ (Nádraží)      │
│      └─ Stanice, Logistika, Depa   │
│                                     │
│  [6] SEVERO-ZÁPADNÍ (Vzdělání)      │
│      └─ Školy, Knihovny, Administratíva│
│                                     │
│  [7] JIŽNÍ (Rezidenční)             │
│      └─ Byty, Parky, Obchody       │
│                                     │
│  [8] RIEKA (Přístav Labe/Vltava)   │
│      └─ Lodě, Místní hospody        │
│                                     │
└─────────────────────────────────────┘
```

### 1.2 Principais Lokality v Adventure Mode

#### 1.2.1 BARY A HOSPODY (Recruitment)

| Lokalita | Region | Specialisté | Heat | Poznámka |
|----------|--------|-------------|------|----------|
| U Černého Orla | Staré Město | Obecní zloději, Řidiči | Nízká | Hlavní bar |
| Café Vltava | Centrum | Hackeři, IT specialisté | Střední | WiFi, bezpečí |
| Pod Břehem | Přístav | Pašeráci, Námořníci | Střední | Noční podsvětí |
| Hospoda U Vidlice | Východ | Silákové, Stavbaři | Střední | Dělnická třída |
| Na Louce | Západ | Finančníci, Byznismeni | Vysoká | Drahé nápoje |

#### 1.2.2 OBCHODY (Equipment & Vehicles)

**Prodejce nářadí** ("Jaroslav Staňa"):
```
Lokace: Pokój nad U Černého Orla
Dostupnost: Pátek-Neděle, 19:00-23:00
Inventář:
├─ Lockpick Set (500-5,000 CZK) ★★-★★★★★
├─ Svářečka (10,000 CZK)
├─ Stetoskop (2,000 CZK)
├─ Flexi-nástroje (3,000 CZK)
├─ Drátový řezač (4,000 CZK)
└─ Falešné klíče (8,000 CZK)
```

**Prodejce elektroniky** ("Věda"):
```
Lokace: Café Vltava (s laptopedem)
Dostupnost: Pátek-Neděle, 14:00-22:00
Inventář:
├─ EMP Zařízení (15,000 CZK)
├─ Jammer (8,000 CZK)
├─ Detektor drátů (5,000 CZK)
├─ Scanner biometrie (20,000 CZK)
├─ Skener RF (12,000 CZK)
└─ Noční vidění (30,000 CZK)
```

**Pronajímatel vozidel** ("Mára"):
```
Lokace: U Černého Orla
Dostupnost: Denně, 11:00-20:00
Vozidla:
├─ Škoda 120 (pronájem 500 CZK/den) - Pomalá, tichá
├─ Dacia Sandero (2,000 CZK/den) - Normální
├─ BMW M340i (5,000 CZK/den) - Rychlá, viditelná
├─ VW Transporter (1,500 CZK/den) - Prostorná
└─ Motocykl (3,000 CZK/den) - Rychlá, riskantní
```

#### 1.2.3 INTELLIGENCE GATHERING BODY

| Metoda | Kategorie Intel | Cena | Čas | Riziko |
|--------|-----------------|------|-----|--------|
| Fyzický průzkum | +10% random | Zdarma | 1h | Heat +5 |
| Nákup plánů | +20% Architecture | 2,000 CZK | 15m | Nízké |
| Rozhovor v hospodě | +15% Guard Patrols | 1,000 CZK | 30m | Střední |
| Hacking IT | +20% Security | Zdarma | 2h | Heat +10 |
| Pozorování z dálky | +10% Alternate Routes | Zdarma | 2h | Nízké |

---

## 2. PLANNING MODE - MISSION STRUCTURE

### 2.1 Mission Anatomy

Každá mise obsahuje:

```
MISSION_ID: "BANK_KOMERCNI_MELNIK_01"

├─ BRIEFING:
│  └─ "Honza ti zavolá: Máme novou robotu..."
│
├─ RECONNAISSANCE PHASE:
│  └─ Musíš sbírat 50% informací
│
├─ PLANNING PHASE:
│  └─ Naplánuj tým a časový plán
│
├─ EXECUTION PHASE:
│  └─ Sleduj a komunikuj během loupeže
│
└─ POST-MISSION:
   └─ Prodej, rozdělení peněz, výsledky
```

### 2.2 Blueprint Reveal System

Informace se odkrývají v **5 kategoriích** (každá 20%):

```
0-20% INTEL: Pouze obrysy zdí a vchody
20-40% INTEL: +Poloha stráží (statické)
40-60% INTEL: +Poloha trezoru, +Trasy hlídek
60-80% INTEL: +Kamery a senzory
80-100% INTEL: +Skryté zámky, +Telefonní linky, +Backupsy
```

**Vizuální progrese** na blueprintu:
```
██████░░░░ 60% REVEALED

Building Layout    ✓ 100%
Guard Patrols      ⚠️ 60%
Security Systems   ⚠️ 30%
Treasure Location  ✓ 100%
Alternate Routes   █░░ 10%
```

### 2.3 Grid Systémy (Technical)

**Macro-Grid** (Regionální):
- Rozměr: 200x200 metrů (pixels)
- Rozděluje Mělník na streamovací buňky
- V paměti: Max. 4 sousední buňky

**Navigation-Grid** (Taktický):
- Rozměr: 0.5x0.5 metru
- Definuje pochozí zóny (NavigationPolygon)
- Automatické pathfinding

**Interaction-Grid** (Objektový):
- Rozměr: 0.1x0.1 metru
- Umisťování interaktivních objektů
- Žádné překryvy

### 2.4 Interactive Objects Catalog

| Objekt | Interakce | Čas | Hluk | Skill |
|--------|-----------|-----|------|-------|
| Standardní dveře | Otevřít | 0.5s | Nízký | - |
| Zámek Lvl 1-3 | Lockpick | 2-5s | Nízký | Lock Picking |
| Bezpečnostní mřížka | Terminál/Páka | 5-8s | Vysoký | Electronics |
| Okno | Rozbít | 3s | Vysoký | - |
| Trezor | Hacknutí/Páčení | 10-20s | Velmi vysoký | Hacking |
| Alarm | Vypnout | 8s | Žádný | Electronics |
| Kamera | Hacknout | 30s | Žádný | Hacking |

---

## 3. PRVNÍ KAMPAŇ - 8 MISÍ

### 3.1 ACT I: NÁVRAT (Tutorial & Setup)

#### MISSION 1: "Malý zkoušební lup" (TUTORIAL)

```
┌─────────────────────────────────────────────────┐
│ MISS001: Malý zkoušební lup                    │
├─────────────────────────────────────────────────┤
│                                                 │
│ Lokace: Kancelář MelTech s.r.o.               │
│ Cíl: Ukrást digitální disk (obsahuje dokumenty)│
│                                                 │
│ Obtížnost: ⭐ TUTORIAL                         │
│ Doporučený tým: 1-2 osoby                     │
│ Čas limitu: 10 minut                          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 0 (Jen majitel, který je pryč)   │
│ ├─ Kamer: 1 (ve vchodu, ale vypnutá)         │
│ ├─ Trezoru: Ne, disk je na stole              │
│ └─ Alarmu: Ne                                 │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 5,000 CZK                         │
│ ├─ Reputace: +20                             │
│ ├─ Intel o dalších misích: ✓                │
│ └─ Bonus (bez detekce): +5,000 CZK           │
│                                                 │
│ Speciální: Toto je TUTORIAL - hra vás vede   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Blueprint**: Malý 2-místnosti kancelář
```
┌─────────────────────┐
│  HLAVNÍ KANCELÁŘ    │
│                     │
│     [Desk]          │   ← Disk je tady!
│                     │
├─────────────────────┤
│  VEDLEJŠÍ MÍSTNOST  │
│  (Archiv)           │
│     [Files]         │
└─────────────────────┘
```

#### MISSION 2: "Komercní banka Mělník" (EASY)

```
┌─────────────────────────────────────────────────┐
│ MISS002: Komercní Banka Mělník                 │
├─────────────────────────────────────────────────┤
│ Lokace: Bankovní pobočka v centru             │
│ Cíl: Ukrást 200,000 CZK z trezoru            │
│                                                 │
│ Obtížnost: ⭐⭐ EASY                          │
│ Doporučený tým: 3-4 osoby                     │
│ Čas limitu: 30 minut                          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 2 (jeden v hale, jeden v kanceláři)
│ ├─ Kamer: 4 (rohy, hala, trezorovna)         │
│ ├─ Trezoru: Ano (Lvl 2 zámek)                │
│ ├─ Alarmu: Ano (Silent alarm)                │
│ └─ Čas odpovědi policie: 3 minuty            │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 20,000 CZK                        │
│ ├─ Reputace: +30                             │
│ └─ Bonus (bez detekce): +20,000 CZK          │
│                                                 │
│ Strategie:                                     │
│ - Hacknout kamery před vstupem (ideální)     │
│ - Omráčit strážce nebo se vyhnout           │
│ - Hackovat alarm nebo páčit trezor (volba)   │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### MISSION 3: "Vozidlo v garáži" (EASY)

```
┌─────────────────────────────────────────────────┐
│ MISS003: Ukrást vozidlo pro budoucnost        │
├─────────────────────────────────────────────────┤
│ Lokace: Uzamčené parkoviště u Mělnické stanice│
│ Cíl: Ukrást BMW M340i (pro budoucí mise)     │
│                                                 │
│ Obtížnost: ⭐⭐ EASY                          │
│ Doporučený tým: 1-2 osoby (hacker + řidič)  │
│ Čas limitu: 15 minut                         │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 1 (u brány, dá se obejít)       │
│ ├─ Kamer: 2 (malé, slabé)                   │
│ ├─ Alarmu: Ano (auto-alarm - musíš hacknout)│
│ └─ Složitost zámku: Lvl 3 (moderní vůz)    │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 0 (ale máš vozidlo navíc!)       │
│ ├─ Reputace: +25                             │
│ └─ Bonus (bez detekce): Nový vůz k dispozici│
│                                                 │
└─────────────────────────────────────────────────┘
```

### 3.2 ACT II: PROFESIONÁL (Medium Difficulty)

#### MISSION 4: "Galerie Mánes" (MEDIUM)

```
┌─────────────────────────────────────────────────┐
│ MISS004: Galerie Mánes - Umělecké mistrovství │
├─────────────────────────────────────────────────┤
│ Lokace: Historická budova v Mělníku           │
│ Cíl: Ukrást tři vzácné obrazy (300k CZK)      │
│                                                 │
│ Obtížnost: ⭐⭐⭐ MEDIUM                      │
│ Doporučený tým: 3-4 osoby                     │
│ Čas limitu: 45 minut                          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 6-8 (patroly každých 5 minut)   │
│ ├─ Kamer: 8 (všude v galerii)               │
│ ├─ Trezoru: Ne (obrazy na zdích)            │
│ ├─ Alarmu: Ano (připevnění detektory)       │
│ └─ Speciální: Obrazy jsou těžké (2 osoby)   │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 50,000 CZK                        │
│ ├─ Reputace: +50                             │
│ └─ Bonus (bez detekce): +50,000 CZK (!)     │
│                                                 │
│ Klíčové prvky:                                 │
│ - Synchronizace více postav                  │
│ - Manipulace patroly (timing je všechno)     │
│ - Fyzická síla k přenášení obrazů            │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### MISSION 5: "Datacentrum Karlín" (MEDIUM)

```
┌─────────────────────────────────────────────────┐
│ MISS005: Datacentrum - Hackerský závod         │
├─────────────────────────────────────────────────┤
│ Lokace: Moderní IT centrum u Mělníka          │
│ Cíl: Ukrást server s hodnotnými daty (200k)   │
│                                                 │
│ Obtížnost: ⭐⭐⭐ MEDIUM                      │
│ Doporučený tým: 2-3 osoby (fokus na hackera) │
│ Čas limitu: 40 minut                          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 3-4 (méně, ale lépe vybaveni)   │
│ ├─ Kamer: 12 (vysokotechnologické)          │
│ ├─ Elektroniky: 5 (lasery, sensory)         │
│ ├─ Alarmu: Ano (automatický)                │
│ └─ Speciální: Server váží 20kg              │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 40,000 CZK                        │
│ ├─ Reputace: +40                             │
│ └─ Bonus (bez detekce): +40,000 CZK         │
│                                                 │
│ Výzva: Vyžaduje perfektní hacking a timing   │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### MISSION 6: "Bankovní pobočka Václavák" (MEDIUM)

```
┌─────────────────────────────────────────────────┐
│ MISS006: Hlavní banka - Velký zásah            │
├─────────────────────────────────────────────────┤
│ Lokace: Velká banková pobočka v Praze*        │
│ Cíl: Ukrást 100,000 CZK (ale je rizikové!)   │
│                                                 │
│ Obtížnost: ⭐⭐⭐ MEDIUM-HARD                │
│ Doporučený tým: 4-5 osob                      │
│ Čas limitu: 30 minut (policie je rychlá!)    │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 8-10 (vysoká hustota)            │
│ ├─ Kamer: 10 (všude)                         │
│ ├─ Trezoru: Ano (Lvl 4 - těžký)             │
│ ├─ Alarmu: Ano (tiché varování)             │
│ └─ Čas odpovědi policie: 2-3 minuty         │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 30,000 CZK                        │
│ ├─ Reputace: +35                             │
│ └─ Bonus (bez detekce): +35,000 CZK         │
│                                                 │
│ *Poznámka: Tato mise je v Praze, ne Mělníku │
│ Poučení: Hra se rozšiřuje, Heat roste        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 3.3 ACT III: EXPERT (Hard Difficulty)

#### MISSION 7: "Mělnický hrad" (HARD)

```
┌─────────────────────────────────────────────────┐
│ MISS007: Mělnický hrad - Historické poklady   │
├─────────────────────────────────────────────────┤
│ Lokace: Mělnický hrad (skutečná lokace)       │
│ Cíl: Ukrást historické artefakty (300k CZK)  │
│                                                 │
│ Obtížnost: ⭐⭐⭐⭐ HARD                      │
│ Doporučený tým: 4-5 osob                      │
│ Čas limitu: 50 minut                          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 10+ (s psy!)                     │
│ ├─ Kamer: Není (staré budovy = bezpečnost)   │
│ ├─ Alarmu: Staré mechanické (lze obejít)     │
│ └─ Speciální: Architektura je labyrint       │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 60,000 CZK                        │
│ ├─ Reputace: +80                             │
│ └─ Bonus (bez detekce): +80,000 CZK         │
│                                                 │
│ Klíčová výzva: Fyzická stavba, orientace     │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### MISSION 8: "FINÁLNÍ MISE - Praha Exponáty" (LEGENDARY)

```
┌─────────────────────────────────────────────────┐
│ MISS008: NÁRODNÍ MUZEUM - Grand Finale         │
├─────────────────────────────────────────────────┤
│ Lokace: Národní muzeum v Praze               │
│ Cíl: Ukrast Korunu Československou + důkazy   │
│                                                 │
│ Obtížnost: ⭐⭐⭐⭐⭐ LEGENDARY              │
│ Doporučený tým: 5-6 osob (NEJLEPŠÍ tým)      │
│ Čas limitu: 120 minut (dlouhá mise)          │
│                                                 │
│ Zabezpečení:                                   │
│ ├─ Strážců: 20+ (bezpečnostní oddíl!)       │
│ ├─ Kamer: 20+ (nejnovější technologie)      │
│ ├─ Laserů: 8 (laserové sítě)                │
│ ├─ Alarmu: Ano (vojenská úroveň)            │
│ └─ Speciální: DRON s AI!                    │
│                                                 │
│ Odměny:                                        │
│ ├─ Peníze: 200,000+ CZK                      │
│ ├─ Reputace: +150 (legendární status!)       │
│ └─ Bonus: ENDING + nový kontext              │
│                                                 │
│ Selhání: Game Over (nemáte druhý pokus!)     │
│                                                 │
│ TATO MIS JE KONEC HRY - Vyberte si svůj konec│
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 4. DETECTION SYSTEM

### 4.1 Vision Cones (Zorná Pole)

```
Primární zóna (30°):    - Okamžitá detekce (0.2s)
Periferní zóna (60°):  - Postupná detekce (1.5-3.0s)
Zatmavené zóny:        - Bezpečné (pokud nejsi hlučný)
```

### 4.2 Noise System (Hluk)

| Akce | Radius | Hlučnost | Útlum |
|------|--------|----------|-------|
| Plížení | 1.0m | 20 | -5m/zeď |
| Chůze | 3.5m | 50 | -2m/dřevo |
| Běh | 7.0m | 100 | -5m/cihla |
| Lockpick | 1.5m | 30 | -3m/cihla |
| Páčení | 5m | 80 | -5m |
| Výbuch | 30m+ | 200 | -8m |

---

## 5. RANDOM EVENTS V MISÍCH

Aby mise nebyly statické, aplikují se modifikátory:

```
[12:34] Neočekávaná OSOBA ve místnosti!
        → Civilista / Hlídka se vrátila dříve
        → Řešení: Omráčit nebo přestrojit se

[12:45] Alarm SELHÁNÍ (sensor error)
        → Drzej se dál, alarmy se resetují za 30s
        → Příležitost k útěku!

[13:00] Policie V DOHLEDU
        → Čas se zkrátil o 50%
        → URGENCE: Musíš být TEĎKÁ!

[13:15] Spoluprachatý SE UNAVUJE
        → Pohyb zpomaluje o 20% za 10s
        → Volej mu povzbudivou zprávu