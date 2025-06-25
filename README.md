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
chmod +x SubHunter.sh
./SubHunter.sh -d example.com -g
```
## Help:
```
└─$ ./SubHunter.sh -h
Usage: ./SubHunter.sh -d <domain> [-g]

Options:
  -d <domain>   Target domain to enumerate subdomains
  -g            Use Google Dorking with auto-generated cookies (optional)
  -h            Show this help message
```
