# SubHunter
Tento skript vykonáva pasívnu enumeráciu subdomén pre zadanú doménu pomocou viacerých nástrojov, ako sú Amass, Subfinder, Assetfinder, Findomain, gau a ďalšie. Kombináciou týchto zdrojov sa maximalizuje pokrytie subdomén z verejne dostupných informácií (OSINT). Skript zhromaždí výstupy, odstráni duplicity a vytvorí unifikovaný zoznam pre ďalšiu analýzu.

![SubHunter](https://github.com/user-attachments/assets/e9dfae2b-1816-4eed-982f-765ab5fbef45)

## API klúče
```
python key_manager.py
```


## Inštalácia:
```
git clone https://github.com/lulusec/Subhunter-v1/
cd Subhunter-v1
bash install.sh
```
## Použitie:
```
bash SubHunter.sh -d example.com -g
```

## Vysvetlivky:
Na automatizovaný Google dorking sa používajú Google cookies v prepinači -c, aby sa minimalizovalo riziko blokácie a zabezpečila plynulá interakcia so službami vyhľadávania.
