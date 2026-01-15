# ART BIBLE - ZLODĚJ MĚLNÍK
## VERZE 3.1 - MĚLNÍK 2025 | Textured Reality Specification

**Projekt**: Zloděj Mělník
**Vizuální styl**: **Top-Down Realistic 2D** (GTA 2 / Hotline Miami style)
**Rozlišení**: 1080x1920px (Portrait Mode)
**Škála**: 1 pixel = 1 centimetr (Detailní textury)
**Atmosféra**: Špinavá realita, beton, déšť, noční pouliční světla

---

## 1. VIZUÁLNÍ IDENTITA

### 1.1 Core Visual Concept

"The Gritty Reality" - Hra zobrazuje svět Mělníka v syrové, detailní podobě:
- **Prostředí:** Použití detailních 2D textur (cihly, asfalt, tráva, parkety).
- **Postavy:** Plně animované 2D sprity (ne jen kroužky).
- **Osvětlení:** Dynamické stíny (Light2D), kužely světla z baterek, pouliční lampy.
- **Počasí:** Částicové efekty deště, kaluže na zemi odrážející světlo.

### 1.2 Barevná paleta (Natural & Atmospheric)

**Prostředí (Materiály)**:
- **Beton/Asfalt:** #3A3A3A až #505050 (neutrální šedá)
- **Cihly:** #8B4513 (tmavě hnědá/červená)
- **Vegetace:** #2E4A28 (desaturovaná tmavá zelená)
- **Interiéry:** #D2B48C (dřevo), #C0C0C0 (dlažba)

**UI & Overlay (Kontrastní)**:
- **Akce/Pohyb:** #4CC9F0 (Cyan - stále držíme pro UI)
- **Nebezpečí:** #EF476F (Varovná červená)
- **Stealth/Stíny:** #0D1B2A (Tmavě modrá pro neprozkoumané oblasti - Fog of War)

### 1.3 Typografie

**Nadpisy**: **Roboto Mono Bold** (Tech feel nad realistickým světem)
**Text**: **Inter** (Čitelnost)

**Malý text** (UI labels):
- Font: Inter Medium
- Velikost: 12px
- Barva: #457B9D

---

## 2. ADVENTURE MODE VIZUÁLY

### 2.1 Mělnická mapa

**Styl Mapy**:
- Vypadá jako "Google Maps Satellite View" ale v noci/večer.
- Budovy mají "střechy" (vidíme šindele, klimatizace, světlíky).
- Ulice jsou texturované (přechody, čáry na silnici, kanály, odpadky).
- **Živý svět:** Auta (sprity) projíždějí po silnicích, stromy se hýbou ve větru, pouliční lampy vrhají kužely světla.

### 2.2 Character Portraits & Sprites

**In-Game Sprites (Top-Down)**:
- Pohled shora (ramena a hlava).
- Rozlišení: cca 64x64px pro postavu.
- Animace: Chůze (nohy se hýbou), Idle (dýchání), Interakce (ruce se natáhnou).
- **Vybavení:** Vidíme zbraň/nástroj v rukou postavy.

### 2.3 Equipment Icons (Inventory)
- **Styl:** Realistické digitální malby (ne vektorové ikony).
- Rozměr: 64x64px.
- Pozadí: Jemný tmavý gradient místo průhlednosti.

---

## 3. PLANNING MODE VIZUÁLY

### 3.1 Celková estetika (Technical Blueprint)

Plánovací obrazovka se vizuálně radikálně odlišuje od Adventurní části. Jde o **hybrid mezi technickým plánem budovy a taktickou mapou**.

-   **Styl**: Klasická pixel-art estetika první poloviny 90. let (tlustší kontury, omezená paleta).
-   **Feeling**: Strohý, funkční, "systémový". Navozuje pocit, že hráč sedí nad papírovým plánkem.
-   **Pozadí**: Čisté linie, jasné tvary místností, žádné zbytečné dekorace (na rozdíl od detailních backgroundů v Adventure módu).

### 3.2 Objekty a Ikony

Všechny interaktivní prvky jsou zobrazeny jako **jasně čitelné pixelové ikony/sprity**:

-   **Dveře, okna**: Schematické, ale dobře rozlišitelné typy.
-   **Interaktivní prvky**: Bedny, trezory, rozvaděče, cennosti – jednoduchá, čistá pixelová grafika.
-   **Čitelnost**: Prioritou je okamžitá identifikace typu objektu (ne realismus).

### 3.3 Postavy a Vizualizace Trasy

-   **Hráčovy postavy**: Malé sprite figurky.
-   **Pohyb**: Během nahrávání se pohybují po mapě; při simulaci je vidět jejich reálný pohyb po trasách.
-   **Stráže**: Zobrazeny jako schémata/entity uvnitř půdorysu (ne hyperrealistické animace), jasně indikují pohyb a směr pohledu.

### 3.4 UI Prvky v Plánování

-   **Horní status panel**: Jednoduchý rám bez ilustrací, obsahuje textová data (čas, alarmy). Vizuálně kontrastuje s mapou.
-   **Spodní ovládací panel**: Funguje jako "VCR ovladač" (tlačítka Play, Rec ve stylu 90. let UI). Ikony příkazů jsou řazeny v přehledném panelu.
-   **Detail objektu**: Při výběru objektu se zobrazí kombinace kurzoru a textového popisu nahoře (kombinuje technický nákres s infem).



---

## 4. ACTION MODE VFX

### 4.1 Detekce a Hluk Effects

**Noise Ripples** (Zvukové vlny):
- Subtilní distorze vzduchu (se shaderem) + jemný bílý kruh, který se rychle rozplyne.
- Ne neonové kruhy, spíše jako "rázová vlna".

**Detection Warning**:
- Ui element nad hlavou postavy.
- **Eye Icon:** Otevírající se oko (postupné plnění barvou).
- Zvuk: "Whoosh" efekt narůstajícího napětí.

### 4.2 Success / Failure Effects

**Úspěch loupeže**:
- Obrazovka ztmavne, "MISSION COMPLETE" razítko.
- Postavy nastoupí do dodávky (animace) a odjedou.

**Selhání loupeže**:
- Zmrazení obrazu (Freeze frame).
- Černobílý filtr (Death cam).
- Červený text "BUSTED" nebo "K.O.".

---

## 5. ASSET EXPORT STANDARDS (PRO GODOT)

### 5.1 Image Formats

- **PNG**: Všechny UI prvky (s transparencí)
- **.CTEX** (Godot Compressed Texture): Všechny velké textury (pro mobily)
- **SVG**: Vektorové loga (pak konvertovat na PNG)

### 5.2 Folder Struktura Assets

```
/assets/
├─ /adventure/
│  ├─ /map/
│  │  ├─ melnik_map_1280x720.png
│  │  └─ buildings.png
│  ├─ /characters/
│  │  ├─ josef_card.png
│  │  ├─ petra_card.png
│  │  └─ milan_card.png
│  └─ /icons/
│     ├─ lockpick_64x64.png
│     ├─ emp_64x64.png
│     └─ vehicles/
│
├─ /planning/
│  ├─ /blueprints/
│  │  ├─ bank_layout.png
│  │  └─ house_layout.png
│  ├─ /ui/
│  │  ├─ timeline_bg.png
│  │  └─ character_token.png
│  └─ /effects/
│     ├─ vision_cone.png
│     └─ noise_ripple.png
│
├─ /ui/
│  ├─ /buttons/
│  ├─ /panels/
│  └─ /fonts/
│
└─ /audio/
   ├─ /sfx/
   │  ├─ lockpick_sound.ogg
   │  ├─ alarm_sound.ogg
   │  └─ success_chime.ogg
   └─ /music/
      ├─ adventure_theme.ogg
      ├─ planning_ambient.ogg
      └─ action_intense.ogg
```

### 5.3 Exportní nastavení (Godot 4.3+)

**Textury**:
```
[compression/mode] = "vram_compressed"
[compression/vram_compression] = "etc2"
[mipmaps/generate] = true
[mipmaps/limit] = -1
```

**Audio**:
```
[mix_rate] = 44100
[modes] = "mono"  (pro SFX)
[modes] = "stereo"  (pro hudbu)
```

---

## 6. ANIMACE A PŘECHODY

### 6.1 UI Animace

**Button Hover**:
- Scale: 1.0 → 1.1 (0.2s)
- Barva: Standard → Neon zelená (0.2s)
- Zvuk: Malý "beep" (30ms)

**Panel Slide-in**:
- Pozice: Mimo obrazovku → Na místo (0.4s)
- Easing: Elastic Out
- Zvuk: Subtilní "whoosh"

### 6.2 Character Animation

**Pohyb v Adventure Mode**:
- Animace chůze: 4 snímky (0.3s loop)
- Běh: 6 snímků (0.2s loop)
- Plížení: 3 snímky (0.6s loop)

---

## 7. ACCESSIBILITY DESIGN

### 7.1 Kontrast a Čitelnost

✅ Všechny texty mají kontrast 4.5:1 (WCAG AA)  
✅ Žádná barva není jedinou indikací (vždy + ikona/text)  
✅ Haptická zpětná vazba (vibrace) pro důležité akce  
✅ Zvuk upozornění pro selhání (ne jen vizuální)