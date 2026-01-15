# LEGAL & BUSINESS DOCUMENT - ZLODĚJ MĚLNÍK
## VERZE 1.0 - COMPLIANCE 2025

Tento dokument slouží k identifikaci a ošetření právních rizik spojených s vývojem hry, zejména v oblasti ochranných známek a licencí.

---

## 1. TRADEMARK CHECK (FIKCIONALIZACE)

Hra se odehrává v reálném městě (Mělník), což je povoleno, ale použití chráněných názvů firem je rizikové.

### 1.1 Lokace a Názvy
| Reálný Název | Status | Riziko | Řešení ve hře (Návrh) |
| :--- | :---: | :---: | :--- |
| **Mělník** | Veřejný | Žádné | **Zachovat** (Geografický název nelze chránit jako copyright pro setting). |
| **Komerční Banka** | Trademark | **Vysoké** | **"Mělnická Banka"** nebo "Union Banka". Logo změnit na fiktivní. |
| **Škoda Auto** | Trademark | Střední/Vysoké | Auta bez loga, obecné názvy ("Sedan 120", "Moderní Hatchback"). Design mírně upravit. |
| **Policie ČR** | Veřejný | Nízké | **Zachovat**. (Lze použít symboly státní policie v uměleckém díle, pokud nedochází k zesměšnění/záměně s realitou). |
| **Vltava / Labe** | Veřejný | Žádné | **Zachovat**. |

### 1.2 Fiktivní Značky (Lore Brands)
Vytvoření vlastních značek pro budování světa bez právních rizik.
- **MelTech s.r.o.** (Technologická korporace - hlavní antagonista)
- **Beer & Gear** (Lokální hospoda/obchod)
- **CzechSecurity Systems** (Výrobce alarmů)

---

## 2. LICENCE ASSETŮ (3RD PARTY)

Seznam softwaru a assetů použitých při vývoji a jejich licenční podmínky.

### 2.1 Engine & Tools
| Software | Licence | Povinnosti |
| :--- | :--- | :--- |
| **Godot Engine 4.3** | MIT License | Uvést copyright notice "Powered by Godot" v titulcích. Hra může být komerční. |
| **Aseprite** | EULA (Paid) | Umožňuje komerční užití vytvořené grafiky. Žádné povinnosti. |

### 2.2 Fonty (Typography)
| Font | Zdroj | Licence | Poznámka |
| :--- | :--- | :--- | :--- |
| **Roboto** | Google Fonts | Apache 2.0 | Volné pro komerční užití. |
| **Inter** | Google Fonts | OFL (Open Font License) | Volné pro komerční užití, nutno přibalit licenci při font embeddingu. |
| **Pixel Font** | Itch.io | (Zkontroluj konkrétní asset!) | Většinou CC0 nebo CC-BY. Ověřit autora. |

---

## 3. GDPR & PRIVACY POLICY (GOOGLE PLAY)

Jelikož hra bude na Androidu (Google Play), musí mít Privacy Policy.

### 3.1 Datový sběr
- **Jméno hráče**: Hra ukládá jméno zadané hráčem ("Input Name").
    - *Lokace dat*: Pouze lokálně na zařízení (`user://savegame.tres`). Data se neposílají na server.
    - *Status*: **Bezpečné**. Není třeba GDPR souhlas, pokud data neopouští mobil.
- **Analytika (Firebase/Unity Ads)**:
    - *Plán*: Pokud bude v budoucnu přidána analytika, bude nutné přidat "Cookie Banner" / souhlas se sběrem dat.
    - *Teď*: Žádná analytika = Žádná starost.

### 3.2 Age Rating (PEGI/ESRB)
- **Obsah**: Krádeže, (možné) násilí, alkohol (hospoda).
- **Odhad**: PEGI 12 nebo 16 (podle míry vizualizace násilí a jazyka).
- **Akce**: Vyplnit IARC dotazník v Google Play Console před vydáním.

---

## 4. BUSINESS MODEL

### 4.1 Monetizace
- **Premium**: Jednorázová cena (např. 150 CZK). Žádné reklamy, žádné mikrotransakce.
- **Demo**: První mise zdarma (Tutorial + MelTech), zbytek odemknout nákupem.