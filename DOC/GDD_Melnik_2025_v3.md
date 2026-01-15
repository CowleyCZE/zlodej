# GAME DESIGN DOCUMENT - ZLODĚJ MĚLNÍK
## VERZE 3.0 - MĚLNÍK 2025 | Rozsáhlá Profesionální Specifikace

**Projekt**: Zloděj Mělník  
**Hra**: 2D Stealth Strategy / Tactical Heist / Timeline Management  
**Vizuální styl**: Top-Down Realistic 2D (GTA 2 Style)  
**Lokace**: Mělník a okolí, Česká republika (2025)  
**Platforma**: Android (primární), PC (sekundární)  
**Engine**: Godot 4.3+  
**Cílová skupina**: Fanoušci taktických her a puzzle strategií  
**Rating**: 16+ (vhodné pro adolescenty a dospělé)

---

## 1. EXEKUTIVNÍ SOUHRN A VIZE

### 1.1 Čím je Zloděj Mělník jedinečný?

**Zloděj Mělník** je revoluční stealth strategie zasazená do reálného prostředí malého českého města **Mělníka** a jeho okolí v roce **2025**. Na rozdíl od tradičních her s lineárním gameplayem, Zloděj Mělník nabízí unikátní zkušenost dvou hlavních fází, které vytváří napíchaný herní průběh:

1. **FÁZE ADVENTURY (Adventure Mode)** - Hráč se pohybuje po autentickém Mělníku, navazuje styky s místním podsvětím, nakupuje vybavení a prozkumuje cíle
2. **FÁZE PLÁNOVÁNÍ (Planning Mode)** - Hráč pracuje na detailním blueprintu budovy a synchronizuje každý pohyb vícečlenného týmu na dynamické časové ose
3. **FÁZE AKCE (Action Mode)** - Hráč sleduje napínavou exekuci svého plánu s možností real-time komunikace s týmem

Hra respektuje **tvůrčí svobodu** hráče - veškeré rozhodnutí mají důsledky. Neexistuje pouze jedno řešení. Existují desítky způsobů, jak úspěšně provést loupež.

### 1.2 Unikátní prodejní body (USP)

✅ **Otevřená identita**: Hráč si na začátku vybírá vlastní jméno a tím personalizuje postavu  
✅ **Autentické prostředí**: Mělník 2025 s reálnými vlastnostmi města (topografie, architektura, sociální struktura)  
✅ **Timeline-Based Stealth**: Revoluční systém plánování pro dokonalou synchronizaci více postav  
✅ **Čistě taktický**: Hra netrestá pomalé reflexy, ale špatné logické myšlení  
✅ **Permanentní konsekvence**: Neúspěšné loupeže zvyšují Heat Level a ovlivňují dostupnost budoucích misí  
✅ **Živé město**: NPC žijí svými životy, mají rutiny a vzory chování  
✅ **Etické dilema**: Hráč volí mezi neletálním a letálním přístupem s důsledky  
✅ **Systém reputace**: Stavění postavení v mělnickém a středočeském podsvětí

---

## 2. NASTAVENÍ HRY: MĚLNÍK 2025

### 2.1 Proč právě Mělník?

Mělník je ideálním prostředím pro heistový simulátor, protože:

**Geografické výhody**:
- Malé město (cca 20 tisíc obyvatel) s omezeným počtem únikovychest
- Strategické umístění na soutoku Labe a Vltavy
- Blízkost historického hradu a vinic (kulturní a historické cíle)
- Přímá vazba na Praha (možnost expanze v budoucnu)

**Sociální struktura**:
- Jasná společenská hierarchie (místní oligarchie, komunita, podsvětí)
- Silný vliv spodních vrstev (staveniště, průmyslové zóny)
- Nový kriminální prvek kvůli novému rozpočtu (2025)

**Architektonické prvky**:
- Historické budovy (hrad, kostely, hospody)
- Moderní objekty (banky, nákupní centra, kanceláře)
- Průmyslové areály (ideální pro průzkum)
- Obytné čtvrti (realistické návštěvy)

### 2.2 Hra v roce 2025

Děj se odehrává v **současnosti - roce 2025**. To znamená:

**Technologie**:
- Moderní bezpečnostní systémy (AI kamery, biometrické čtenáře)
- Chytrá zařízení a IoT sítě
- Drony a monitorovací technologie
- Ale i staré, zastaralé bezpečnostní prvky v starších budovách

**Společnost**:
- Digitální měny a kryptoměny (ideální pro zločiny bez stop)
- Sociální média (hlídka v čase reálném, informace o rutinách)
- Kamerové systémy s cloudovým úložištěm
- Ale i korumpovaní důstojníci a tradiční "podsvětí"

**Prostředí**:
- Moderní infrastruktura (ploché střechy, skleněné budovy)
- Staré kanály a podzemní části (historické tunely)
- Bezpečnostní pasy a moderní zámky
- Ale i starožitné věci bez digitálního zabezpečení

Hráč musí kombinovat tradiční stealth taktiky s moderní technologickou gramotností.

### 2.3 Hlavní postava - Hráčem zvolené jméno

Na samém začátku hry se hráč setkává s **JMÉNEM VYBÍRACÍ OBRAZOVKOU**:

```
┌──────────────────────────────────────────────┐
│  ZLODĚJ MĚLNÍK - START GAME                 │
│                                              │
│  Vítej v Mělníku, roku 2025...             │
│                                              │
│  Jak se jmenuješ?                           │
│                                              │
│  [________________] (text input)            │
│   VÝCHOZÍ: "Thief"                         │
│                                              │
│  Tvoje poslání začíná tady...              │
│                                              │
│  [CONTINUE] nebo [RANDOM NAME]             │
└──────────────────────────────────────────────┘
```

**Jak to funguje**:
- Hráč si vybírá vlastní jméno pro svou postavu
- Jméno se používá v dialozích a cutscénách
- Hráč se identifikuje s postavou prostřednictvím svého jména
- Příklady: "Petr", "Markéta", "Ivan", atd.
- Hra má generator náhodných jmen, pokud si hráč jméno nevybere

**Personalizace pokračuje**:
- Hráč si v Adventure Mode postupně vybírá:
  - Kdo jste v Mělníku? (Místní, příchádějící z Prahy, cizinec)
  - Jaký je vaše motivace? (Zisk, pomsta, adrenalin)
  - Jaký máte vztah k morálce? (Tichý profesionál vs. Nemilosrdný)

Tyto volby ovlivňují dostupné mise, dialogy a konečný výsledek.

---

## 3. GAME FLOW: KOMPLETNÍ HERNÍ SMYČKA

### 3.0 PŘEHLED MECHANIK (CORE LOOP)

1. **Sbírání informací a tipů**
   Pro každou loupež musíš nejprve zjistit adresu, informace o objektu (zajištění, alarmy, typ dveří, specifika). Tipy získáváš v hospodách, od kontaktů v podsvětí nebo prohlížením města – mapování míst, kde jsou cennosti.

2. **Výběr týmu**
   Najímáš spolupachatele dle jejich schopností (zloději, řidiči, specialisté na alarmy). Každý má unikátní vlastnosti – někdo je rychlý, jiný expert na šperháky nebo tichý pohyb. Platíš jim podíl z výnosu, někdy požadují zálohu.

3. **Nákup a správa vybavení**
   Zajišťuješ si potřebné pomůcky: páčidla, šperháky, výbušniny, rukavice, pytle na kořist, auta. Každý člen týmu můžeš vybavit konkrétními nástroji.

4. **Plánování průběhu loupeže – klíčová fáze**
   Na mapě objektu zakresluješ přesný průběh akce (tzv. „route editor“):
   *   Kdy a kam vstoupit;
   *   Které dveře páčit, co vypínat;
   *   Když je více členů, můžeš synchronizovat akce (např. jeden obchází alarm, druhý sbírá šperky).
   *   Každý krok definuješ do detailu – například: *Otevřít dveře → projít chodbu → otevřít sejf → sbalit kořist → utéct.*
   *   Volíš vhodné nástroje pro každou překážku (např. silné dveře = výbušnina, u skříňky = šperhák).
   *   Nastavuješ časování – některé akce musí proběhnout rychle, jiné až po splnění podmínky (např. vypnutí alarmu).
   Cílem je provést vše co nejrychleji a nejtišeji.

5. **Simulace**
   Můžeš si plán „nanečisto“ otestovat – hra nasimuluje průběh akce v reálném čase s animací členů týmu. Uvidíš, kde plán selhává – kde ztratíš čas nebo spustíš alarm. Plán můžeš ladit – přidávat, měnit, synchronizovat kroky.

6. **Provádění akce**
   Když jsi spokojen, loupež provedeš „naostro“. Výsledek závisí na preciznosti plánu, zvolených schopnostech týmu a vybavení.

7. **Rozdělení kořisti & vývoj postav**
   Kořist rozdělíš, tým získá zkušenosti, otevřou se nové možnosti a složitější tipy.

### 3.1 FÁZE 1: ADVENTURE MODE (Příprava v Mělníku)

Hráč se pohybuje po Mělníku roku 2025 a provádí **přípravné činnosti**.

#### 3.1.1 Počáteční úkoly (Onboarding)

**Tutorial Mise: "Malý zkoušební lup"**

Cíl: Seznámit hráče s mechanikami Adventure Mode

Honza (tvůj kontakt) ti zavolá:
> "Hej [JMÉNO], slyšel jsem, že jseš v Mělníku. Mám pro tebe první robotu - taková ta jednoducha. Když se osvědčíš, máme spousty peněz na tebe. Jezdi za mnou do hospody U Černého Orla."

**Co dělá hráč**:
1. Najít hospodu "U Černého Orla" v Mělníku
2. Provádět dialog s Honzou
3. Dostat první úkol: Ukrást digitální disk z firmy "MelTech s.r.o."
4. Nakoupit základní vybavení (lockpick souprava, černé oblečení)
5. Najít spolupachatele v hospodě
6. Provést jednoduchou loupež

**Reward**: 
- 5,000 CZK
- +20 Reputation
- Seznámení se herním systémem
- Odkryti seznamu budoucích misí

#### 3.1.2 Hlavní činnosti v Adventure Mode

**A) HLEDÁNÍ SPOLUPACHATELŮ (Recruitment)**

Hráč navštěvuje různé lokality v Mělníku a okolí:

**Lokality Mělníka 2025**:

| Lokalita | Typ | Nalazeníci | Heat |
|----------|-----|-----------|------|
| U Černého Orla | Hospoda | Obecní zloději, Řidiči | Nízká |
| Café Vltava | Kavárna | Hackeři, IT specialisté | Střední |
| Stanice Mělník | Nádraží | Běžcové, Kontakty | Střední |
| Podzemí Hradu | Historické | Specialisté na starožitnosti | Vysoká |
| Staveniště U Dubu | Průmysl | Silákové, Mechanici | Střední |
| Střechy Mělníka | Střechy | Akrobati, Střešáři | Vysoká |
| Starost-Sladký Dům | Sídlo bohatých | Špioni, Informátoři | Velmi vysoká |

**Charakteristika specialistů**:

Každý specialista má:
- **Jméno a portrét**: Vytvořená NPC osobnost
- **Primární dovednost**: Lock Picking, Driving, Electronics, Stealth
- **Sekundární dovednosti**: Athletics, Persuasion, Combat
- **Osobnostní rysy**: Greed (0-100), Loyalty (0-100), Nerves (0-100), Dexterity (0-100)
- **Cena najatí**: 2,000 - 15,000 CZK
- **Dostupnost**: Věrohodnost a Heat risk

**Příklady postav v Mělníku**:

```
👤 JOSEF "PEPÍK" NOVÁK (41, Řidič)
├─ Driving: 90/100 (EXPERT)
├─ Lock Picking: 40/100
├─ Greed: 85 (velmi chamtivý)
├─ Loyalty: 50 (nestabilní)
├─ Nerves: 60 (průměrný)
├─ Cena: 5,000 CZK
├─ Lokace: U Černého Orla (každý pátek večer)
└─ Dialog: "Hej, slyšel jsem, že hledáš řidiče. Mám nový Range Rover..."

👤 PETRA "TŘÍSKA" SVOBODOVÁ (28, Hacker)
├─ Electronics: 95/100 (EXPERT)
├─ Lock Picking: 70/100
├─ Greed: 40 (štědrá)
├─ Loyalty: 80 (spolehlivá)
├─ Nerves: 45 (poddajná)
├─ Cena: 8,000 CZK
├─ Lokace: Café Vltava (s notebookem)
└─ Dialog: "Slyšela jsem o tobě. Máš zajímavý projekt?"

👤 MILAN "GRIZZLY" KOVÁŘÍK (55, Silák)
├─ Strength: 100/100 (MAXIMUM)
├─ Lock Picking: 20/100 (slabý)
├─ Greed: 90 (velmi chamtivý)
├─ Loyalty: 40 (nechrání své kamarády)
├─ Nerves: 70 (odolný)
├─ Cena: 6,000 CZK
├─ Lokace: Staveniště U Dubu (kolem oběda)
└─ Dialog: "Já sem tvůj chlap. Ale když nefunguje..."
```

**B) NÁKUP VYBAVENÍ A VOZIDEL (Shopping)**

Hráč navštěvuje "Prodejce" - spekulanty s nelegálním zbožím:

**Typy obchodů**:

1. **Prodejce nářadí** ("Jaroslav Staňa" - pokój nad barem)
   - Lockpick soupravy (500-5,000 CZK)
   - Svářečka (10,000 CZK)
   - Stetoskop (2,000 CZK)

2. **Prodejce elektroniky** ("Věda" - Café Vltava)
   - EMP zařízení (15,000 CZK)
   - Jammer signálu (8,000 CZK)
   - Drátový detektor (5,000 CZK)

3. **Prodejce vozidel** ("Mára" - U Černého Orla)
   - Stará Škoda 120 (pronájem 500 CZK/den)
   - Moderní Dacia Sandero (pronájem 2,000 CZK/den)
   - Sportovní BMW M340i (pronájem 5,000 CZK/den)
   - Dodávka VW Transporter (pronájem 1,500 CZK/den)

**C) PRŮZKUM CÍLE (Target Reconnaissance)**

Hráč musí shromáždit **minimálně 50% informací o budově**, než může přejít do Planning Mode.

**Informace o budově** se dělí na 5 kategorií (každá 20%):

1. **Architektura (Building Layout)** - Počet místností, jejich velikost
2. **Hlídka (Guard Patrols)** - Počet strážců a jejich dovednosti
3. **Zabezpečení (Security Systems)** - Umístění kamer a senzorů
4. **Cíl (Treasure Location)** - Kde je trezor nebo věc
5. **Alternativní cesty (Alternate Routes)** - Skrytá okna, zadní vchody

**Jak se sbírají informace**:

| Metoda | Výstup | Cena | Riziko |
|--------|--------|------|--------|
| Fyzický průzkum | +10% | Zdarma | Heat +5 |
| Nákup plánů | +20% Architecture | 2,000 CZK | Nízké |
| Rozhovor se strážcem | +15% Patrols | 1,000 CZK | Střední |
| Hacking | +20% Security | Zdarma | Heat +10 |

### 3.2 FÁZE 2: PLANNING MODE (Naplánování loupeže)

**Hlavní rozdělení obrazovky**
1. **HORNÍ PÁS ("MOZEK")** – status/infopanel s časem, alarmy, poznámkami k objektům. Jednoduchý rám s čistým textem.
2. **STŘEDNÍ PÁS ("SVĚT")** – přepíná na top‑down technický blueprint budovy. Pixel‑art styl 90. let: tlusté kontury, omezená paleta, jasně čitelné ikony (dveře, sejfy, kamery) a trasy postav.
3. **SPODNÍ PÁS ("OVLADAČ")** – kontextová paleta příkazů (Walk, Use, Wait, Open…) a časová osa s ovládáním (play, pause, step).

**Vizuální feeling**: čisté linie, žádná dekorace, pocit technického nákresu. Postavy jsou malé sprite figurky, jejich „duchové“ (ghost run) ukazují nahrané trasy.

**Pixel‑art styl**: tlusté kontury, omezená paleta, ale dostatečné rozlišení pro čitelnost objektů a dveří.

Jakmile hráč splní všechny podmínky (50% informací, tým, vybavení, vozidlo), aktivuje se režim "Plánování" v hotelové místnosti.

#### 3.2.1 Systém paralelního plánování loupeže (Ghost Run System)

Tento systém umožňuje hráčům koordinovat kroky několika postav v reálném čase. Klíčovým prvkem je **vizuální transformace hry**.

**1. Vizuální mód: Blueprint (Technický výkres)**
Při vstupu do plánování se grafika přepne z realistické "Adventure" grafiky na **Taktický Blueprint**.
*   **Zjednodušení**: Zmizí dekorace, textury a atmosférické efekty.
*   **Čitelnost**: Zdi jsou jasné linky, objekty jsou symboly (dveře = obdélník s obloukem, kamera = kužel).
*   **Funkce**: Hráč se nerozptyluje grafikou, vidí čistou logiku prostoru.

**2. Základní mechanika pohybu a ovládání**
*   **Ovládání:** Hráč ovládá vždy **jednu aktivní postavu** v reálném čase.
*   **Spodní panel (Command Palette):** Místo přímého klikání do světa hráč často volí akce z palety nástrojů (Use Lockpick, Wait, Signal) a aplikuje je na objekty.

**3. Průběh plánování (Příkladový scénář)**

**Fáze 1: Plánování postavy č. 1 (Průkopník)**
*   **Cíl:** Přesun z bodu A (start) do bodu B (uzamčené dveře).
*   **Akce:** Hráč stiskne [RECORD]. Pomocí šipek vede postavu k cíli. Systém nahrává pohyb vteřinu po vteřině.
*   **Doba trvání:** Například 10 sekund.
*   **Dokončení:** Po potvrzení [COMMIT] se postava č. 1 vrátí na start (bod A) a její akce jsou uloženy.

**Fáze 2: Plánování postavy č. 2 (Technik) a synchronizace**
*   **Cíl:** Přesun z bodu A do bodu C (terminál) a odemčení dvěří pro Postavu 1.
*   **Mechanika "Ghost Run":** Hráč začne nahrávat pohyb Postavy 2. V tom okamžiku se **Postava 1 (Duch)** začne automaticky pohybovat po své již nahrané trase.
*   **Vizuální kontrola:** Hráč přesně vidí, kde je Postava 1 v každé vteřině nahrávání.

**Příklad časové souslednosti:**
*   **0.–5. sekunda:** Postava 2 běží k terminálu. Postava 1 (Duch) běží k dveřím.
*   **5.–9. sekunda:** Postava 2 aktivuje terminál (interakce 4s). Postava 1 (Duch) stále běží/čeká u dveří.
*   **10. sekunda:** Postava 2 dokončila hack. Dveře se otevírají. Postava 1 (Duch) právě dorazila k dveřím a může projít (pokud jsme to dobře načasovali).

#### 3.2.2 Klíčové výhody
1.  **Precizní timing:** Eliminuje metodu pokus-omyl, protože vidíte "budoucnost" svých kolegů.
2.  **Vizuální kontrola:** Pocit živé spolupráce, i když hrajete sami.
3.  **Strategická hloubka:** Hráč musí přemýšlet o délce animací a vzdálenostech.

### 3.3 FÁZE 3: ACTION MODE (Exekuce)

Hráč sleduje exekuci svého plánu v reálném čase s možností komunikace.

---

## 4. SYSTÉM REPUTACE A HEAT LEVEL

### 4.1 Reputace (Street Cred)

Hráč si buduje postavení v Mělníku (0-100 bodů).

**Level 1-10 (Nováček)**: Postavy tě neznají  
**Level 11-25 (Profesionál)**: Znají tě v hospodách  
**Level 26-50 (Hráč)**: Znají tě všichni  
**Level 50-100 (Legenda)**: Tvoje jméno je povědomé

**Jak se zvyšuje**:
- Úspěšná loupež: +10-50 bodů
- Loupež bez detekce: +50 bodů
- Pomoc v nouzi: +20 bodů
- Zrada: -100 bodů

### 4.2 Heat Level (Hledanost)

Heat Level v Mělníku (0-100%):

**0-20%**: Policie o tobě neví  
**21-50%**: Máš fotku v centrále  
**51-80%**: Policie tě cílí, hlídky na ulicích  
**81-100%**: MÁXÍMUM HEAT - musíš zmizet

**Jak snížit Heat**:
- Čekání: -2 bodů za týden
- Úplatky: -15 bodů za 10,000 CZK
- Falešný důkaz: -30 bodů

---

## 5. EKONOMICKÝ SYSTÉM

### 5.1 Příjmy

- **Primární**: Loupeže (10,000 - 1,000,000+ CZK)
- **Sekundární**: Malé úkoly (500-2,000 CZK)
- **Terciální**: Prodej informací (3,000-10,000 CZK)

### 5.2 Výdaje

- **Pronájem**: 500-2,000 CZK/noc
- **Vybavení**: 500-50,000 CZK
- **Najímání**: 2,000-15,000 CZK
- **Úplatky**: 10,000-100,000 CZK

### 5.3 Rozdělení kořisti

15% jde administraci, zbytek se dělí:
- Řidič: 20%
- Hacker: 25%
- Silák: 15%
- Ostatní: Podle role

---

## 6. KONEC HRY

Hra má více konců:

1. **Odsunout se do zahraničí** (Happy Ending)
2. **Zůstat v Praze** (Ambiguous Ending)
3. **Být zatčen** (Tragedy Ending)
4. **Být zabit** (Dark Ending)
5. **Reforma** (Redemption Ending)