# AUDIO DESIGN DOCUMENT (ADD) - ZLODĚJ MĚLNÍK
## VERZE 1.0 - AUDIOVISION 2025

**Cíl**: Vytvořit pohlcující zvukovou kulisu ("Gritty Reality"), která podporuje stealth mechaniky a jasně odlišuje herní módy. Zvuk je klíčovou součástí hratelnosti (poslouchání kroků, indikace alarmu).

---

## 1. AUDIO KONCEPT & ADAPTIVNÍ HUDBA

Hudba a sound design se mění podle aktuálního herního módu a úrovně ohrožení (Heat Level).

### 1.1 Adventure Mode (Atmosféra)
- **Styl**: Temný, deštivý, melancholický. Inspirace: Noir jazz, ambientní ruchy města.
- **Vrstvy**:
    - *Base*: Tichý šum deště, vítr.
    - *Music*: Pomalé piano nebo saxofon (vzdáleně), občasné basové tóny.
    - *World*: Vzdálené vlaky (nádraží Mělník), štěkot psů, projíždějící auto (doppler efekt).
- **Feeling**: Osamělost, noční klid před bouří.

### 1.2 Planning Mode (Analýza)
- **Styl**: Sterilní, technický, soustředěný.
- **Vrstvy**:
    - *Base*: Úplné ticho zvenčí (tlumené).
    - *Music*: Minimalistické elektronické pulsování (syntezátory), rytmické tikání (čas).
    - *UI*: Zvuky "křídy na papíře" nebo "digitálního kurzoru" při kreslení trasy.
- **Feeling**: "Jsem v bezpečí, přemýšlím."

### 1.3 Action Mode (Tenze)
- **Styl**: Dynamický, napínavý stealth.
- **Stavy hudby**:
    1.  **Stealth (Undetected)**: Velmi tichá basa, rytmus srdce. Důraz na SFX (kroky).
    2.  **Suspicious (Podezření)**: Přidání vyšších smyčců (staccato) nebo perkusí. Zvyšuje se tempo.
    3.  **Alarm/Chase (Odhalení)**: Plná, agresivní elektronická/orchstrální hudba. Sirény.

---

## 2. ASSET LIST (SFX)

### 2.1 Postavy & Pohyb (Foley)
Kroky se musí lišit podle povrchu (GameTag: `SurfaceType`).
- **Concrete (Beton)**: Tvrdý, klapavý zvuk.
- **Carpet (Koberec)**: Tlumený, měkký šustivý zvuk.
- **Grass (Tráva)**: Šustění, mokrý zvuk (pokud prší).
- **Wood (Dřevo)**: Vrzání (šance na hluk!).
- **Oblečení**: Šustění bundy při rychlém pohybu.

### 2.2 Interakce & Nástroje
- **Lockpicking**:
    - *Start*: Kovové cvaknutí.
    - *Success*: Uspokojivé "kliknutí" západky.
    - *Fail*: Skřípavý zvuk kovu, zlomení paklíče.
- **Dveře**:
    - *Open*: Vrznutí pantů (liší se podle typu dveří - staré dřevěné vs. moderní skleněné).
    - *Locked*: Zvuk kliky, která nejde stisknout.
- **Loot**:
    - *Cash*: Šustění papíru.
    - *Gold/Jewelry*: Cinkání kovu.
    - *Tech*: Digitální pípnutí.

### 2.3 UI & Feedback
- **Hover**: Jemné "digitální" cvaknutí.
- **Select**: Výraznější tón.
- **Error/Deny**: Hluboký "bzučák".
- **Planning Timeline**: Zvuk přetáčení pásky (rewind/fast-forward) stylově laděný do 90. let.

---

## 3. VOICE OVERS (DABING)

Hra bude obsahovat částečný dabing (barks a klíčové dialogy), zbytek bude text s "psacím strojem" efektem.

### 3.1 Postavy
- **Honza (Kontakt)**:
    - *Popis*: 50 let, kuřák, bývalý vekslák. Chraplavý, autoritativní, ale přátelský hlas.
    - *Ukázka*: "Tak co, mladej? Máš to?" / "Dávej bacha na ty kamery."
- **Strážný (Guard)**:
    - *Popis*: Znuděný zaměstnanec security.
    - *Barks*: "Co to bylo?", "Asi jen vítr...", "HEJ! STŮJ!", "Hlásím narušení v sektoru B."

---

## 4. TECHNICKÁ IMPLEMENTACE (GODOT)

### 4.1 Audio Bus Layout
- **Master**
    - **Music** (Hudba)
    - **SFX** (Efekty)
        - *Environment* (Déšť, město)
        - *Gameplay* (Kroky, interakce)
        - *UI* (Menu)
    - **Voice** (Dabing)

### 4.2 Propagace zvuku (Occlusion)
Ve stealth hře je klíčové, aby zdi tlumily zvuk.
- **Mechanika**: Použití `CastShape2D` mezi zdrojem zvuku (Stráž) a posluchačem (Hráč).
- **Efekt**: Pokud paprsek narazí na zeď (`CollisionLayer: Wall`), aplikuje se na zvuk **Low Pass Filter** (útlum výšek) a sníží se hlasitost (-10dB).

### 4.3 Kroky a Detekce
- Každý zvuk kroku generuje "Noise Event" (neviditelná sféra).
- AI Stráže mají "Hearing Radius".
- Pokud `Noise Event` protne `Hearing Radius`, AI přejde do stavu *Suspicious*.