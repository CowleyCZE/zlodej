# AUDIO GENERATION PROMPTS - ZLODĚJ MĚLNÍK
**Verze:** 1.0
**Účel:** Seznam promptů pro vygenerování chybějících zvukových efektů (SFX) a ambientů.
**Formát:** OGG (Vorbis) - preferovaný pro Godot (dobrá komprese/kvalita).

---

## 1. UI & SYSTÉMOVÉ ZVUKY (Story Update)
**Cílová složka:** `res://assets/audio/sfx/ui/`

| Název souboru | Formát | Popis | AI Prompt (English) |
| :--- | :--- | :--- | :--- |
| `phone_ring_loop` | .ogg | Vyzvánění mobilu pro příchozí hovor od Honzy. Mělo by být smyčkovatelné. | Modern smartphone ringtone, standard digital melody, medium urgency, looping, clear sound without background noise. |
| `phone_pickup` | .ogg | Zvuk přijetí hovoru (swipe nebo click). | Digital button click, smartphone answer call sound, futuristic UI beep, short and crisp. |
| `phone_hangup` | .ogg | Zvuk ukončení hovoru. | Digital button click, smartphone end call sound, negative UI beep, short. |
| `ui_error` | .ogg | Chybový zvuk (např. nedostatek peněz, zamčeno). | Digital error buzzer, access denied sound, short low pitch beep, UI feedback. |
| `ui_success_chime` | .ogg | Úspěch (mise splněna, level up). | Positive chime, mission accomplished sound, digital uplifting synth, reverb tail. |
| `typewriter_blip` | .ogg | Velmi krátký zvuk pro vykreslování textu v dialogu. | Very short high pitch digital blip, retro computer text scrolling sound, soft click, minimal duration. |

---

## 2. POHYB A STEALTH (Stealth Update)
**Cílová složka:** `res://assets/audio/sfx/movement/`
*Poznámka: Pro variabilitu je dobré vygenerovat delší sekvenci a rozstříhat ji na jednotlivé kroky.*

| Název souboru | Formát | Popis | AI Prompt (English) |
| :--- | :--- | :--- | :--- |
| `footstep_concrete_sneak` | .ogg | Tiché našlapování teniskami na beton (pro plížení). | Soft sneaker footsteps on concrete surface, slow stealthy pace, subtle cloth rustle, night ambience silence, isolated sounds. |
| `footstep_concrete_run` | .ogg | Rychlý běh po betonu/asfaltu. | Fast running footsteps on asphalt, sneakers, heavy impact, urgent pace, isolated sounds. |
| `footstep_interior_wood` | .ogg | Chůze po dřevěné podlaze (parkety). | Leather shoe footsteps on creaky wooden floor, indoor reverb, slow walking pace, isolated sounds. |
| `gear_rustle_loop` | .ogg | Jemné šustění oblečení při pohybu (smyčka). | Soft fabric rustling, leather jacket movement noise, cloth friction, continuous subtle loop. |

---

## 3. NÁSTROJE A INTERAKCE (Heist Update)
**Cílová složka:** `res://assets/audio/sfx/tools/`

| Název souboru | Formát | Popis | AI Prompt (English) |
| :--- | :--- | :--- | :--- |
| `lockpick_fumble` | .ogg | Zvuk hledání správné polohy v zámku. | Metallic clicking, small tools manipulating lock tumbler, quiet metal scraping, lockpicking sound mechanism. |
| `lockpick_success` | .ogg | Zvuk cvaknutí otevřeného zámku. | Loud lock tumbler click, padlock opening mechanism, satisfiying metal snap, spring release. |
| `drill_loop` | .ogg | Zvuk malé ruční vrtačky (pro trezory). | Small electric drill motor running, high pitch whirring, mechanics tool sound, steady loop. |
| `hacking_typing` | .ogg | Rychlé psaní na klávesnici. | Fast mechanical keyboard typing, plastic key switches, hacker coding sound, computer terminal interaction. |
| `hacking_access_granted` | .ogg | Digitální zvuk úspěšného hacku. | Retro computer access granted sound, 8-bit positive trill, success login beep. |

---

## 4. AMBIENTY (Adventure Update)
**Cílová složka:** `res://assets/audio/ambience/`

| Název souboru | Formát | Popis | AI Prompt (English) |
| :--- | :--- | :--- | :--- |
| `ambience_city_night` | .ogg | Noční Mělník, ticho, vítr, vzdálená auta. | City night ambience, quiet street, distant traffic hum, wind blowing through buildings, occasional dog bark far away, realistic field recording. |
| `ambience_pub_interior` | .ogg | U Černého Orla - tlumený hovor, sklenice. | Small pub interior ambience, muffled crowd chatter, glasses clinking, warm atmosphere, background noise. |
| `ambience_rain_loop` | .ogg | Zvuk deště na beton (pro špatné počasí). | Steady rain falling on concrete pavement, water splashing, medium intensity, looping nature sound. |

---

## JAK POUŽÍT
1. Zkopírujte "AI Prompt" do nástroje pro generování zvuku (např. ElevenLabs, AudioLDM, Suno).
2. Vygenerujte zvuk.
3. Upravte v Audacity (ořezat ticho, normalizovat hlasitost, převést na Mono pro SFX).
4. Uložte jako `.ogg` do uvedené cílové složky.
5. V Godotu nastavte v `Import` záložce "Loop" pro soubory označené jako `_loop`.
