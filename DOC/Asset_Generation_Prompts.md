# ASSET GENERATION GUIDE - ZLODĚJ MĚLNÍK
## Verze 1.0 - Mělník 2025 | Specifikace pro AI a Grafiku

Tento dokument obsahuje přesné prompty, formáty a cesty pro generování assetů potřebných pro aktuální fázi vývoje.

---

## 1. PORTRETY POSTAV (Character Portraits)
**Formát:** PNG (průhledné pozadí) | **Velikost:** 512x512 px  
**Styl:** Realistic, cinematic lighting, tech-noir, sharp focus, head and shoulders.

| Postava | Cesta v projektu | Prompt (DALL-E 3 / Midjourney) |
|:---|:---|:---|
| **Honza (Fixer)** | `assets/characters/honza_portrait.png` | Middle-aged Czech man, 45 years old, sharp features, short grey hair, wearing a dark leather jacket, sitting in a dim pub, cinematic moody lighting, tech-noir style, 8k resolution. |
| **Petra (Hacker)** | `assets/characters/petra_portrait.png` | Young woman, 28 years old, intellectual look, short blue-streaked hair, wearing high-tech glasses and a hoodie, reflected light from a computer screen on her face, cyberpunk aesthetic, 8k resolution. |
| **Josef (Řidič)** | `assets/characters/josef_portrait.png` | Tough Czech man, 40 years old, buzz cut, stubble, wearing a mechanic shirt, grease stains, intense gaze, night setting with city lights bokeh, realistic style, 8k resolution. |
| **Milan (Muscle)** | `assets/characters/milan_portrait.png` | Large muscular man, 55 years old, bald head, thick beard, wearing a worn-out denim vest, background of a construction site at dusk, gritty realistic style, 8k resolution. |
| **Strážný (Guard)** | `assets/characters/guard_portrait.png` | Generic security guard in a modern black tactical uniform, wearing a radio headset, tactical cap, professional and alert expression, flat lighting, 8k resolution. |

---

## 2. LOKACE A POZADÍ (Locations)
**Formát:** PNG | **Velikost:** 1024x1024 px (pro UI výřezy)  
**Styl:** Realistic Top-down or Isometric view, rainy, night, Central European architecture.

| Lokace | Cesta v projektu | Prompt |
|:---|:---|:---|
| **U Černého Orla** | `assets/locations/cerny_orel_bg.png` | Exterior of a traditional Czech pub in Mělník city center, stone architecture, neon sign "U Černého Orla", rainy night, street lamps reflecting in puddles, cinematic style. |
| **Café Vltava** | `assets/locations/cafe_vltava_bg.png` | Modern riverside cafe interior, glass walls, view of the Vltava river at night, minimal furniture, high-tech vibe mixed with cozy atmosphere, cinematic lighting. |
| **MelTech Sklad** | `assets/locations/meltech_warehouse.png` | Top-down view of a modern industrial warehouse interior, metal shelves, concrete floor, flickering fluorescent lights, security cameras visible on walls, gritty atmosphere. |

---

## 3. IKONY VYBAVENÍ (Equipment Icons)
**Formát:** PNG (průhledné) | **Velikost:** 128x128 px  
**Styl:** Flat vector, tactical blue/yellow accent, clean lines, white stroke.

| Předmět | Cesta v projektu | Prompt |
|:---|:---|:---|
| **Paklíče** | `assets/icons/icon_lockpick.png` | Flat vector icon of a professional lockpicking set, metallic finish, tactical aesthetic, isolated on transparent background. |
| **Páčidlo** | `assets/icons/icon_crowbar.png` | Flat vector icon of a heavy-duty steel crowbar, dark grey, industrial look, isolated on transparent background. |
| **Taser** | `assets/icons/icon_taser.png` | Flat vector icon of a modern police taser, yellow and black, electrical spark effect, isolated on transparent background. |
| **Bojový Nůž** | `assets/icons/icon_knife.png` | Flat vector icon of a tactical combat knife, serrated edge, matte black finish, isolated on transparent background. |
| **Hacking Kit** | `assets/icons/icon_hacking.png` | Flat vector icon of a rugged laptop or PDA with wires, data stream on screen, isolated on transparent background. |
| **Tlumená Pistole** | `assets/icons/icon_pistol.png` | Flat vector icon of a modern handgun with a long suppressor, matte finish, tactical style, isolated on transparent background. |

---

## 4. WORLD MAP (Mělník 2025)
**Formát:** PNG | **Velikost:** 2048x2048 px  
**Styl:** Blueprint / Satellite hybrid, dark navy palette, glowing cyan lines for streets.

| Asset | Cesta v projektu | Prompt |
|:---|:---|:---|
| **Základní Mapa** | `assets/ui/map_melnik_2025.png` | Stylized tactical map of Mělník city center, confluence of Elbe and Vltava rivers, architectural blueprint style, dark background, glowing grid lines, 4k high detail. |

---

### Instrukce pro implementaci:
1. Vygenerované obrázky zmenšete na cílovou velikost.
2. Odstraňte pozadí u ikon a portrétů (Background removal).
3. Nahrajte do příslušných složek a v Godotu zkontrolujte nastavení importu (Texture Filter: Linear / Nearest podle potřeby).
