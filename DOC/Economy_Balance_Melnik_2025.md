# GAME BALANCE & ECONOMY - ZLODĚJ MĚLNÍK
## VERZE 1.0 - SPREADSHEET 2025

Tento dokument slouží jako "živá tabulka" (v této MD verzi jako definice) pro vyvážení ekonomiky hry, postupu hráče a obtížnosti.

---

## 1. EKONOMIKA MISE (LOOT VS RISK)

Vzorec pro výpočet odměny: `Base Reward + Loot Value - (Crew Share + Expenses) = Net Profit`

| Mission Tier | Název | Obtížnost | Base Reward (CZK) | Max Loot (CZK) | Avg. Expenses (CZK) | Avg. Net Profit (CZK) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Tier 1** | Tutorial (Kiosek) | Easy | 5,000 | 2,000 | 500 | **6,500** |
| **Tier 2** | MelTech Office | Medium | 20,000 | 15,000 | 8,000 | **27,000** |
| **Tier 3** | Vila Starosty | Hard | 50,000 | 100,000 | 25,000 | **125,000** |
| **Tier 4** | Mělnická Banka | Insane | 200,000 | 500,000 | 100,000 | **600,000** |

### Podíly Crew (Crew Share)
Každý specialista bere % z celkového lupu (Base + Loot).
- **Rookie**: 10% (Levný, nízký skill)
- **Pro**: 20% (Spolehlivý, střední skill)
- **Expert**: 35% (Drahý, ale nezbytný pro Tier 4)

---

## 2. PROGRESSION CURVE (CENY VYBAVENÍ)

Hráč musí investovat zisk zpět do vybavení, aby odemkl těžší mise.

| Level | Očekávaný Cash | Doporučený Nákup | Cena (CZK) | Efekt |
| :--- | :---: | :--- | :---: | :--- |
| **Start** | 0 | Basic Lockpick | 500 | Otevře Level 1 zámky (pomalé) |
| **Lvl 2** | 10,000 | Crowbar (Páčidlo) | 2,000 | Rychlé otevření dveří (Hluk!) |
| **Lvl 3** | 30,000 | Basic Van (Auto) | 15,000 | Útěk +20% šance, Kapacita lupu |
| **Lvl 5** | 100,000 | Silent Drill | 40,000 | Otevře sejfy potichu |
| **Lvl 8** | 500,000 | Signal Jammer | 150,000 | Vypne alarmy na 30s |

---

## 3. STATISTIKY POSTAV (BALANCING)

Vyvážení atributů pro různé třídy postav (Hráč i NPC).
Hodnoty jsou normalizované (0 = Min, 100 = Max).

| Class | Speed (Move) | Stealth (Noise) | Tech Skill | Strength | HP |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Player (Thief)** | 60 | 80 | 60 | 40 | 100 |
| **Josef (Driver)** | 50 | 40 | 30 | 60 | 120 |
| **Petra (Hacker)** | 70 | 90 | 100 | 20 | 60 |
| **Milan (Brute)** | 40 | 20 | 10 | 100 | 200 |
| --- | --- | --- | --- | --- | --- |
| **Guard (Basic)** | 50 | 50 (Detection) | N/A | 50 | 100 |
| **Guard (Elite)** | 70 | 90 (Detection) | N/A | 80 | 150 |

### Mechaniky Detekce (Guard AI)
- **Vision Cone**: Úhel 90°, Dosah 300px (den) / 150px (noc).
- **Hearing Radius**:
    - Běh: 200px
    - Chůze: 100px
    - Plížení: 20px

---

## 4. ITEMIZACE (VYBAVENÍ)

Seznam předmětů a jejich vlastností.

### Nástroje (Tools)
1.  **Lockpick Set**
    - *Weight*: 0.5 kg
    - *Use Time*: 5-10s (dle skillu)
    - *Noise*: Low
2.  **Páčidlo**
    - *Weight*: 2.0 kg
    - *Use Time*: 2s
    - *Noise*: High (přiláká stráže z 500px)
3.  **EMP Granát**
    - *Weight*: 0.3 kg
    - *Effect*: Vypne kamery v rádiusu 300px na 10s.
    - *Cost*: 5,000 CZK (Spotřební zboží)

### Loot (Kořist)
1.  **Hotovost (Cash)**
    - *Weight*: 0.1 kg / svazek
    - *Value*: 100% face value.
2.  **Šperky**
    - *Weight*: 0.5 kg
    - *Value*: 50-80% (musí se prodat u překupníka).
3.  **Art / Obrazy**
    - *Weight*: 5.0 kg (zpomaluje hráče o 20%)
    - *Value*: High (ale těžko prodejné).