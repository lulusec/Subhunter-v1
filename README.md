# SubHunter
Tento skript vykonáva pasívnu enumeráciu subdomén pre zadanú doménu pomocou viacerých nástrojov, ako sú Amass, Subfinder, Assetfinder, Findomain, gau a ďalšie. Kombináciou týchto zdrojov sa maximalizuje pokrytie subdomén z verejne dostupných informácií (OSINT). Skript zhromaždí výstupy, odstráni duplicity a vytvorí unifikovaný zoznam pre ďalšiu analýzu.

![SubHunter](https://github.com/user-attachments/assets/e9dfae2b-1816-4eed-982f-765ab5fbef45)

## API klúče
Pre maximálny výkon odporúčam pridať API kľúče aspoň do jedného z týchto nástrojov – ideálne do Subfinderu, ktorý podporuje desiatky providerov a v prípade dostupných kľúčov výrazne zvyšuje pokrytie výsledkov.
```
nano /home/kali/.config/subfinder/provider-config.yaml
```
- odporúčame pridať:
  - Virustotal API key
  - dnsdumpster API key
  - zoomeyeapi API key
  - shodan API key
  - chaos API key

## Inštalácia:
```
git clone https://github.com/lulusec/SubHunter/
cd Subhunter
sudo bash install.sh
chmod +x SubHunter.sh
```
## Použitie:
```
./SubHunter.sh -h
./SubHunter.sh -d example.com -c "Cookie: AEC=123dsa456; GTB=123.dsa"
```

## Vysvetlivky:
Na automatizovaný Google dorking sa používajú Google cookies v prepinači -c, aby sa minimalizovalo riziko blokácie a zabezpečila plynulá interakcia so službami vyhľadávania.
