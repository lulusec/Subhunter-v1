# SubHunter
Tento skript vykonáva pasívnu enumeráciu subdomén pre zadanú doménu pomocou viacerých nástrojov, ako sú Amass, Subfinder, Assetfinder, Findomain, gau a ďalšie. Kombináciou týchto zdrojov sa maximalizuje pokrytie subdomén z verejne dostupných informácií (OSINT). Skript zhromaždí výstupy, odstráni duplicity a vytvorí unifikovaný zoznam pre ďalšiu analýzu.

![SubHunter](https://github.com/user-attachments/assets/e9dfae2b-1816-4eed-982f-765ab5fbef45)

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
| Flag | Description                                         | Example                          |
|------|-----------------------------------------------------|----------------------------------|
| -d   | Target domain to enumerate subdomains               | `./SubHunter.sh -d example.com`  |
| -g   | Use Google Dorking with auto-generated cookies      | `./SubHunter.sh -g`              |
| -h   | Show this help message                              | `./SubHunter.sh -h`              |

```
## API klúče
```
python key_manager.py
```
<p align="center">
 <img src="https://github.com/user-attachments/assets/bc99a933-b02d-4209-8786-55cdb603c30e" alt="image">
</p>

## In progress:
```
The -js switch, which will be used for subdomain enumeration from JavaScript files.
```
