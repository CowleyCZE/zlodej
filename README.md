# Zloděj Mělník

**2D Stealth Strategie / Tactical Heist / Timeline Management**

Hra zasazená do autentického prostředí českého města **Mělníka v roce 2025**. Hráč přebírá roli profesionálního zloděje, který plánuje a provádí loupeže v moderním i historickém prostředí.

## 🚀 Klíčové vlastnosti
- **Timeline-Based Planning:** Unikátní systém „Ghost Run“, kde synchronizujete pohyby více postav na časové ose.
- **Dvě herní fáze:** Atmosférický **Adventure Mode** (průzkum města, najímání týmu) a strohý **Planning Mode** (taktický blueprint).
- **Živé město:** Dynamický cyklus dne a noci, náhodné události (zátahy, tipy) a NPC rutiny.
- **Etické volby:** Volba mezi letálním (nůž, pistole) a neletálním (taser) přístupem s dopadem na Heat Level a reputaci.
- **Hlukový systém:** Realistické šíření zvuku – stráže reagují na běh i hlučné nástroje (páčidlo).

## 🛠 Technologie
- **Engine:** Godot 4.3+ (GDScript)
- **Platforma:** Primárně PC/Android
- **Architektura:** Event-Driven s centrálním EventBusem

## 📂 Struktura projektu
- `scenes/core/`: Jádro hry (Adventure, Planning, Action Mode).
- `scripts/autoload/`: Globální manažery (Save, Time, MapEvents, Noise).
- `resources/Missions/`: Definice misí a cílů.
- `DOC/`: Rozsáhlá technická a herní dokumentace.

## 📝 Aktuální stav
Projekt je ve fázi **Pozdní Alfa**. Jsou implementovány všechny klíčové simulační systémy, synchronizace v plánování a základní ekonomický cyklus.

---
*Vytvořeno v rámci vývoje "Zloděj Mělník 2025".*
