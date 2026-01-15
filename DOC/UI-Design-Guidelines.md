# UI Design Guidelines – Zloděj
## Výběr mezi Pixel-Art/Flat 2D a Moderním Vektorem/Skeuomorfním UI

---

## 1. Přehled Designových Paradigmat

### 1.1 Pixel-Art / Flat 2D Design

**Charakteristika:**
- **Pixelová mřížka**: Každý pixel je vědomé rozhodnutí; vyžaduje pevnou mřížku (obvykle 64px, 128px, 256px)
- **Omezená paleta barev**: Čisté, vzdálené od realismu (retro vibe)
- **Ostré hrany**: Bez antialiasingu, bez jemných přechodů
- **Nízké nároky na výkon**: Ideální pro mobilní zařízení (Android, iOS)
- **Čitelnost**: Výborná v malých velikostech (HUD, ikony); čitelné i na nízké DPI

**Výhody pro Zloděj:**
- Vyhovuje **Blueprint stylu** (technické výkresy s mřížkou)
- Perfektní komplementace s vektorovými liniemi (6px obvodní zdi, 3px příčky)
- Jednoduchý export: PNG @1x, @2x, @4x (mobilní optimalizace)
- Snadné měření a pixel-perfect alignment (důležité pro UI alignment)

**Nevýhody:**
- Obnovení assetů pro různé rozlišení (pokud chceš čistou kvalitu bez interpolace)
- Omezená škálovatelnost na 4K displays bez rozostření

---

### 1.2 Moderní Vektor UI + Lehký Skeuomorfismus

**Charakteristika:**
- **Infinitní rozlišení**: Vektorové křivky (Bézier paths) se neztratí při škálování
- **Plné nebo semi-flat**: Čisté tvary + jemné stíny, gradience, glow efekty
- **Skeuomorfní prvky**: Napodobování reálných objektů (zámky, trezory, terminály) pro **affordance** (jasné signály, co je interaktivní)
- **Responzivní design**: Jeden návrh pokryje telefon, tablet, desktop bez ztráty kvality
- **Nižší nároky na disk**: Menší soubory SVG vs velké rasterizované PNG

**Výhody pro Zloděj:**
- **Ingame skeuomorfismus** má smysl – fyzické objekty (sejf, terminál, zámek) jako součást fantasy loupeže
- Lehčí itarativní design (změny barev, velikostí bez nového kreslení)
- Lepší mobilní UI (návratnost investice v cross-platform)
- Automatická škálovatelnost bez pixelace

**Nevýhody:**
- Vyžaduje profesionální editor (Adobe Illustrator, Figma, Inkscape)
- V Godotu se SVG musí **rasterizovat** při importu (nejsou real-time vektorové, jen PNG s vyšším rozlišením)
- Pokud je skeuomorfismus přehnán, může odebrat modernitu Blueprint stylu

---

## 2. Doporučení pro Zloděj Praha

### 2.1 Hybridní Přístup (DOPORUČENO)

**Struktura:**
```
├── FLAT BLUEPRINT CORE
│   ├── Mapa & HUD (Pixel-art linky + grid)
│   ├── Timeline UI (čisté geometrické tvary)
│   └── Stavové ikony (neonové symboly)
│
├── SEMI-SKEUOMORPHIC ACCENT
│   ├── Zámky (metalické odlesky, jemné stíny)
│   ├── Trezory (3D efekt přes 2D vrstvení)
│   ├── Terminály (glow, osvětlení, sklo)
│   └── Lámpičky & indikátory (svítící prvky)
│
└── VEKTOROVÁ ZÁKLADNA (SVG → rasterizace)
    ├── Všechny ikony (ikonografie 24-256px)
    ├── UI panely (rámečky, popisy)
    └── Speciální efekty (lightning, kouř)
```

**Logika:**
- **Flat 2D**: Mapový podklad, řídící prvky (herní svět se jeví jako technický výkres)
- **Skeuomorfní**: Interaktivní objekty (hráč ví, že se může dotknout, manipulovat; fyzická přítomnost)
- **Vektorový**: Všechny exporty (škálování bez ztráty)

---

## 3. Konkrétní Implementační Průvodce

### 3.1 HUD & Mapový Layer (FLAT + PIXEL-PERFECT)

**Nový blok v Art Bible:**

#### 3.1.1 Mapa a Herní Prostor

| Prvek | Rozměr | Formát | Paleta | Glow |
|-------|--------|--------|--------|------|
| Grid linie | 1-2px | PNG @2x | #1B2D3F (15% opacity) | Ne |
| Stěny vnější | 6px | SVG → PNG @4x | #39A0ED | Ano (15%) |
| Stěny vnitřní | 3px | SVG → PNG @4x | #39A0ED | Ne |
| Podlaha | - | Procedurální (Noise shader) | #0B1A2A | Ne |
| Osvětlení | Radial gradient | SVG → TextureRect | #00FFFF (20% opacity) | Ano (20%) |

**Godot Setup:**
```gdscript
# Texture Importer Settings
TextureFilter: Nearest (pixel-perfect)
Mipmaps: Off (šetří paměť)
Compress: VRAM (ETC2 pro mobil)

# SVG → PNG Conversion (na export)
# SVG v Figmě / Illustratoru → PNG @4x (1024px ikona exportu jako 4096px)
# Pak downscale v Godotu podle potřeby
```

**Export Sizes:**
```
Standardní rozměry:
- Mobil (5–6"): 1x = 64px, 2x = 128px
- Tablet (10"): 1x = 128px, 2x = 256px
- Desktop (27"): 1x = 256px, 2x = 512px

Godot Settings:
  window/width: 1080 (design base)
  window/height: 1920 (portrait mode)
  stretch_mode: canvas_items
  stretch_aspect: ignore
```

---

### 3.2 Interaktivní Objekty (SEMI-SKEUOMORPHIC)

#### 3.2.1 Zámky a Trezory

**Design:**
- **Baseline**: Flat geometrický obrys (ploché linie, #39A0ED)
- **Skeuomorfní vrstvy** (jemné):
  - Jemný stín (2px offset, #000000 opacity 20%)
  - Metalická textura (procedurální lesklostí, není fotorealistická)
  - Glow při interakci (#FFB400 pulsing)

**Příklad GDScript:**
```gdscript
extends Node2D

@onready var lock_sprite = $Lock
var glow_material = StandardMaterial3D.new()

func _on_lock_interact():
    # Animace: flat → skeuomorfní (zvýšení hloubky)
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_ELASTIC)
    tween.set_ease(Tween.EASE_OUT)
    
    # Zvětšení + glow efekt
    tween.tween_property(lock_sprite, "scale", Vector2(1.1, 1.1), 0.3)
    tween.parallel().tween_property(glow_material, "albedo_color", Color.GOLD, 0.3)
```

**Asset Specifikace:**
| Prvek | Stav | Barva | Animace |
|-------|------|-------|---------|
| Zámek (zavřený) | Default | #39A0ED | Steady |
| Zámek (odemykání) | Active | #FFB400 | Pulsing 2Hz |
| Zámek (otevřený) | Success | #00FF00 | Single flash |

---

### 3.3 Ikonografie (VEKTOROVÁ ZÁKLADNA)

#### 3.3.1 Workflow SVG → PNG

**1. Tvorba v Figmě / Illustratoru (SVG)**
- Rozměr: 256×256px (artboard, vysoké rozlišení)
- Stroke: 2px (konzistentní tloušťka)
- Barva: Bílá (#FFFFFF)
- Bez složitých gradientů (max 2 barvy)

**2. Export a Rasterizace (Godot)**
```gdscript
# Godot 4.4+ SVG Rasterization
var svg_bytes = FileAccess.get_file_as_bytes("res://icons/lock.svg")
var image = Image.new()
image.load_svg_from_buffer(svg_bytes, 4.0)  # 4.0 = 4x upscaling
var texture = ImageTexture.create_from_image(image)

# Pak: Sprite2D.texture = texture
# Godot automaticky downscale na potřebný formát
```

**3. Generování Variant**
```
lock.svg (zdroj)
├── lock_24.png    (24×24, UI HUD)
├── lock_64.png    (64×64, Token ikona)
├── lock_128.png   (128×128, Menu)
└── lock_256.png   (256×256, Asset library)

Všechny se generují z jednoho SVG!
```

---

## 4. Barevné Konzistence (MASTER PALETTE)

### 4.1 Paleta – Rozšíření o Skeuomorfní Tóny

```
PRIMÁRNÍ (z Art Bible):
  Blueprint Deep       #0B1A2A  (background)
  Grid Line           #1B2D3F  (struktura)
  Tech Blue           #39A0ED  (primární UI)
  Agent Cyan          #00FFFF  (hráčské prvky)
  Alarm Red           #FF4B2B  (nebezpečí)
  Gold Ember          #FFB400  (cíle, loot)

SKEUOMORFNÍ TÓNY (přidáno):
  Metal Light         #D0D0D0  (lesky na zámcích)
  Shadow Dark         #0A0F15  (stíny, hloubka)
  Glass Tint          #1F4050  (skleněné plochy)
  Leather Brown       N/A (NENÍ! Zůstáváme v modrém spektru)
  Neon Glow Ext       #7FE0FF  (ambient glow, 40% opacity)
```

**Pravidla:**
- **Základní paleta**: Zůstává beze změny (Art Bible platí)
- **Skeuomorfní vrstvy**: Jsou jen "efekty na vrstvě" (shader, shadow)
- **Glow**: Maximálně 20% opacity, jen pro akcentuaci
- **Testování**: Všechny barvy na AMOLED vs LCD (kontrastní zařízení)

---

## 5. Godot Engine Workflow & Export

### 5.1 Importní Nastavení (UI & Ikony)

```gdscript
# project.godot - UI texture defaults
[importer_defaults]
texture_2d:
  compress_mode = 0  # VRAM compression
  filter = 0         # Nearest (pixel-perfect)
  mipmaps = false    # Vypnuto pro UI
  srgb_linear = false

# SVG-specific
svg:
  scale = 4.0        # Rasterizuj na 4x rozměr
  use_rasterizer = true  # Godot 4.4+
```

### 5.2 Struktura Projektu

```
res://
├── assets/
│   ├── ui/
│   │   ├── svg/
│   │   │   ├── icons/
│   │   │   │   ├── lock.svg
│   │   │   │   ├── hacker.svg
│   │   │   │   └── ...
│   │   │   ├── panels/
│   │   │   │   ├── frame_main.svg
│   │   │   │   └── ...
│   │   │   └── hud/
│   │   │       ├── timeline_bg.svg
│   │   │       └── ...
│   │   └── png/
│   │       ├── 1x/
│   │       │   ├── lock_24.png (24×24 mobile)
│   │       │   └── lock_64.png
│   │       ├── 2x/
│   │       │   ├── lock_48.png (48×48 tablet)
│   │       │   └── lock_128.png
│   │       └── 4x/
│   │           ├── lock_96.png (96×96 desktop/4K)
│   │           └── lock_256.png
│   ├── characters/
│   │   ├── tokens/
│   │   │   ├── agent_cyan.png
│   │   │   └── guard_red.png
│   │   └── shadows/
│   │       ├── ghost_shadow_active.png
│   │       └── ghost_shadow_idle.png
│   └── vfx/
│       ├── glow_circle.png
│       ├── pulse_ring.png
│       └── ...
│
├── scenes/
│   ├── ui/
│   │   ├── hud_main.tscn
│   │   ├── timeline.tscn
│   │   └── inventory.tscn
│   └── game/
│       ├── map.tscn
│       ├── token.tscn
│       └── interactive_lock.tscn
│
└── shaders/
    ├── blueprint_scanlines.gdshader
    ├── glow_effect.gdshader
    └── skeuomorphic_shadow.gdshader
```

### 5.3 Mobilní Optimalizace (Android)

```gdscript
# Godot Project Settings
android/window/width = 1080
android/window/height = 1920
display/window/dpi_scale = 1.0

# Density buckets (jak iOS @2x/@3x)
res://assets/ui/png/1x/lock_24.png    # ldpi (120 dpi)
res://assets/ui/png/2x/lock_48.png    # mdpi (160 dpi) + hdpi (240 dpi)
res://assets/ui/png/4x/lock_96.png    # xhdpi (320 dpi)

# Godot automaticky vybere správný formát
# (Godot 4.4+ má vestavěný MultiResolutionImage-like systém)
```

---

## 6. Čekový seznam – Finální Validace UI Assetů

### 6.1 KONTRAST & ČITELNOST

- [ ] Kontrastní poměr min. 4.5:1 (WCAG AA) pro текст vs. pozadí
- [ ] Ikony čitelné na 24×24px (mobilní) i 256×256px (desktop)
- [ ] Barvy testovány na AMOLED (tmavé) a LCD (jasné) displeji
- [ ] Color-blind friendly (alespoň 80% rozlišitelnosti bez barvy)

### 6.2 KONZISTENCE

- [ ] Tloušťka čar: konzistentní (2px, 3px, 6px dle typu)
- [ ] Font: Roboto Mono (primární), Inter (sekundární)
- [ ] Glow: Max. 20% opacity, jen pro akcentuaci
- [ ] Paleta: Všechny barvy z Master Palety

### 6.3 VÝKON & OPTIMALIZACE

- [ ] PNG: Lossless compression, optimalizované (PNGCrush, OptiPNG)
- [ ] SVG: Bez zbytečných pointů, clean path data (< 10KB na ikonu)
- [ ] Mipmaps: Vypnuté pro UI (není třeba)
- [ ] VRAM: Komprese ETC2 pro mobilní assety

### 6.4 ŠKÁLOVATELNOST

- [ ] Vektorový asset exportován v @1x, @2x, @4x
- [ ] Verifikace: @4x upscale bez pixelace
- [ ] Mobilní UI: Minimální tlačítko 48×48dp (device-independent pixels)

### 6.5 GODOT INTEGRATION

- [ ] Texture Filter: **Nearest** (pixel-perfect)
- [ ] Import compression: **VRAM compression on**
- [ ] SVG rasterization: **On-import v Godotu 4.4+**
- [ ] Scene testing: Všechna rozlišení (720p, 1080p, 1440p, 2560p)

---

## 7. Příklady Implementace

### 7.1 Flat Timeline UI (pixel-perfect)

```gdscript
# timeline.gd
extends Control

@onready var timeline_bg = $TimelineBackground
@onready var play_button = $PlayButton
@onready var slider = $TimeSlider

func _ready():
    # SVG import (Godot 4.4+)
    var timeline_svg = preload("res://assets/ui/svg/hud/timeline_bg.svg")
    timeline_bg.texture = timeline_svg
    
    # Scale pro mobilní
    if get_viewport().size.x < 600:  # Mobilní
        timeline_bg.scale = Vector2(0.75, 0.75)
    
    play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_QUINT)
    tween.set_ease(Tween.EASE_OUT)
    
    # Flat animace – bez 3D efektů
    tween.tween_property(play_button, "scale", Vector2(0.95, 0.95), 0.1)
    tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.1)
```

### 7.2 Skeuomorfní Zámek (s glow efektem)

```gdscript
# interactive_lock.gd
extends Node2D

@export var lock_icon_path: String = "res://assets/ui/png/2x/lock_64.png"
@onready var sprite = $Sprite2D
@onready var glow_sprite = $GlowOverlay  # Druhý sprite pro glow

var is_locked = true

func _ready():
    sprite.texture = load(lock_icon_path)
    glow_sprite.texture = load(lock_icon_path)
    glow_sprite.self_modulate.a = 0.0  # Počáteční – bez glowevu

func _on_area_interact():
    if is_locked:
        _unlock()

func _unlock():
    is_locked = false
    
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Zámek se otáčí a zmizí (flat animace)
    tween.tween_property(sprite, "rotation", PI, 0.5)\
        .set_trans(Tween.TRANS_BACK)\
        .set_ease(Tween.EASE_OUT)
    
    # Glow efekt (skeuomorfní – jemné osvětlení)
    tween.tween_property(glow_sprite, "self_modulate", Color(1, 1, 0.5, 1.0), 0.3)\
        .set_trans(Tween.TRANS_SINE)
    
    # Pak zmizení
    tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3)\
        .set_trans(Tween.TRANS_ELASTIC)\
        .set_ease(Tween.EASE_IN)
    
    tween.tween_callback(func(): visible = false)
```

---

## 8. Doporučené Nástroje

| Nástroj | Formát | Výhoda | Cena |
|---------|--------|--------|------|
| **Figma** | SVG (webový) | Kolaborativní, real-time preview | Freemium / $12/měsíc |
| **Adobe Illustrator** | SVG / PDF | Profesionální, complex paths | $22/měsíc |
| **Inkscape** | SVG | Open-source, offline | Zdarma |
| **Aseprite** | PNG (pixel-art) | Pixel-perfect, animace | $19.99 (jedenkrát) |
| **Godot Editor** | TSCN | Native integration | Zdarma |