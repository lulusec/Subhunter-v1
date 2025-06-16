#!/bin/bash

# --- Farby pre výstup ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Funkcia na zobrazenie bannera ---
print_banner() {
cat << "EOF"
  ____  _   _ ____  _   _ _   _ _   _ _____ _____ ____  
 / ___|| | | | __ )| | | | | | | \ | |_   _| ____|  _ \ 
 \___ \| | | |  _ \| |_| | | | |  \| | | | |  _| | |_) |
  ___) | |_| | |_) |  _  | |_| | |\  | | | | |___|  _ < 
 |____/ \___/|____/|_| |_|\___/|_| \_| |_| |_____|_| \_\                                                        
           Passive Subdomain Enumeration Tool
EOF
echo ""
}

# --- Funkcia na zobrazenie nápovedy ---
print_help() {
    echo -e "${YELLOW}Usage:${NC} $0 -d <domain> [-g]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -d <domain>   Target domain to enumerate subdomains"
    echo "  -g            Use Google Dorking with auto-generated cookies (optional)"
    echo "  -h            Show this help message"
}

# --- Spracovanie argumentov ---
USE_GOOGLE_DORKING=false
if [[ $# -eq 0 ]]; then print_help; exit 1; fi
while getopts ":d:gh" opt; do
    case ${opt} in
        d ) DOMAIN=$OPTARG ;;
        g ) USE_GOOGLE_DORKING=true ;;
        h ) print_help; exit 0 ;;
        \? ) echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2; print_help; exit 1 ;;
        : ) echo -e "${RED}Option -$OPTARG requires an argument.${NC}" >&2; print_help; exit 1 ;;
    esac
done
if [[ -z "$DOMAIN" ]]; then echo -e "${RED}Error: No domain provided.${NC}"; print_help; exit 1; fi

# --- Hlavná časť skriptu ---
print_banner
echo -e "${CYAN}[*] Starting subdomain enumeration for: ${YELLOW}$DOMAIN${NC}"
mkdir -p results
OUTFILE="results/subdomains_$DOMAIN.txt"
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SGOO_SCRIPT_PATH="$SCRIPT_DIR/tools/sd-goo/sd-goo.sh"
PYTHON_BOT_PATH="$SCRIPT_DIR/GoogleBot.py"

# --- Funkcia na spustenie nástroja a spočítanie výsledkov ---
run_and_count() {
    local cmd="$1"
    local label="$2"
    local outfile="$3"
    echo -e "${BLUE}[+] Running $label...${NC}"
    eval "$cmd" > "$outfile" 2>/dev/null
    local count=$(wc -l < "$outfile" 2>/dev/null || echo 0)
    printf "${GREEN}[*] %-18s:${NC} %s\n" "$label" "$count"
}

# --- Spustenie jednotlivých nástrojov ---
if [ "$USE_GOOGLE_DORKING" = true ]; then
    # --- ZMENA: Automatická správa a POUŽITIE virtuálneho prostredia ---
    VENV_DIR="$SCRIPT_DIR/venv"
    VENV_PYTHON="$VENV_DIR/bin/python3" # Cesta k Pythonu vo vnútri venv

    # Skontrolujeme, či venv existuje. Ak nie, vytvoríme ho a nainštalujeme závislosti.
    if [ ! -d "$VENV_DIR" ]; then
        # Tieto správy sa zobrazia len raz, pri prvom spustení
        echo -e "${YELLOW}[*] First time setup: Creating Python virtual environment...${NC}"
        python3 -m venv "$VENV_DIR" > /dev/null 2>&1
        echo -e "${YELLOW}[*] Installing dependencies (Selenium)...${NC}"
        "$VENV_DIR/bin/pip" install selenium > /dev/null 2>&1
        echo -e "${GREEN}[*] Setup complete.${NC}"
    fi
    
    if [[ -f "$SGOO_SCRIPT_PATH" && -x "$SGOO_SCRIPT_PATH" && -f "$PYTHON_BOT_PATH" ]]; then
        # Spustenie Python bota pomocou Pythonu z virtuálneho prostredia
        # Toto je kľúčová oprava!
        GENERATED_COOKIES=$("$VENV_PYTHON" "$PYTHON_BOT_PATH" 2> /dev/null)

        if [ -n "$GENERATED_COOKIES" ]; then
            SGOO_CMD="$SGOO_SCRIPT_PATH -d \"$DOMAIN\" -c \"$GENERATED_COOKIES\""
            run_and_count "$SGOO_CMD" "Google Dorking" "$TMP_DIR/sgoo.tmp"
        fi
    fi
fi

run_and_count "assetfinder -subs-only \"$DOMAIN\"" "Assetfinder" "$TMP_DIR/assetfinder.tmp"
run_and_count "amass enum -passive -d \"$DOMAIN\"" "Amass" "$TMP_DIR/amass.tmp"
run_and_count "subfinder -d \"$DOMAIN\" -silent" "Subfinder" "$TMP_DIR/subfinder.tmp"
run_and_count "findomain -t \"$DOMAIN\" -q" "Findomain" "$TMP_DIR/findomain.tmp"
# ... ostatné tvoje príkazy ...

# --- Zjednotenie, filtrovanie a uloženie výsledkov ---
echo -e "${BLUE}[+] Combining and filtering results...${NC}"
cat "$TMP_DIR"/*.tmp 2>/dev/null | grep -E "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$" | sort -u > "$OUTFILE"
FINALCOUNT=$(wc -l < "$OUTFILE")
rm -rf -- "$TMP_DIR"

echo ""
echo -e "${GREEN}[*] Total unique and valid subdomains found:${NC} $FINALCOUNT"
echo -e "${CYAN}[+] Subdomain enumeration completed. Results saved in ${YELLOW}$OUTFILE${NC}"
                                                                                               
