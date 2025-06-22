#!/bin/bash

# Inštalačný skript pre nástroje potrebné pre recon tool.
# Spúšťajte s sudo, napr.: sudo bash install.sh

# --- Farby pre výstup ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Kontrola, či je skript spustený ako root ---
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Prosím, spustite tento skript ako root alebo pomocou sudo.${NC}"
  exit 1
fi

echo -e "${BLUE}[*] Štartujem inštaláciu potrebných nástrojov...${NC}"

# --- Aktualizácia balíčkov ---
echo -e "${BLUE}[*] Aktualizujem zoznam balíčkov...${NC}"
apt update -y

# --- Funkcia na inštaláciu balíčkov cez APT ---
install_apt_tool() {
    local tool_name="$1"
    local package_name="$2"
    [[ -z "$package_name" ]] && package_name="$tool_name"

    if command -v "$tool_name" >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] $tool_name je už nainštalovaný.${NC}"
    else
        echo -e "${YELLOW}[*] Inštalujem $package_name...${NC}"
        apt install -y "$package_name"
        if command -v "$tool_name" >/dev/null 2>&1; then
            echo -e "${GREEN}[+] $tool_name bol úspešne nainštalovaný.${NC}"
        else
            echo -e "${RED}[!] Nepodarilo sa nainštalovať $tool_name.${NC}"
        fi
    fi
}

# --- Inštalácia základných nástrojov cez APT ---
install_apt_tool "assetfinder"
install_apt_tool "subfinder"
install_apt_tool "jq"
install_apt_tool "findomain"
install_apt_tool "git"
install_apt_tool "curl"
install_apt_tool "timeout" "coreutils" # Dôležité pre subhunter.sh

# --- Inštalácia Go (potrebné pre gau, amass, waybackurls) ---
echo -e "${BLUE}[*] Inštalujem Go programovací jazyk...${NC}"
install_apt_tool "go" "golang-go"

# --- Nastavenie Go prostredia ---
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME=$HOME
fi

GO_PATH="$USER_HOME/go"
GO_BIN_PATH="$GO_PATH/bin"
mkdir -p "$GO_BIN_PATH"
chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/go"

# --- Inteligentná inštalácia Amass ---
echo -e "${BLUE}[*] Spracovávam inštaláciu Amass...${NC}"
NEEDS_INSTALL=false
if command -v "amass" >/dev/null 2>&1; then
    echo -e "${YELLOW}[*] Kontrolujem verziu existujúceho Amass...${NC}"
    if amass -version 2>/dev/null | grep -q '^v3'; then
        AMASS_VERSION=$(amass --version 2>/dev/null)
        echo -e "${GREEN}[✓] Nájdená kompatibilná verzia Amass ($AMASS_VERSION). Inštalácia sa preskakuje.${NC}"
    else
        echo -e "${YELLOW}[!] Nájdená nekompatibilná alebo stará verzia Amass. Bude preinštalovaná.${NC}"
        NEEDS_INSTALL=true
    fi
else
    echo -e "${YELLOW}[*] Amass nie je nainštalovaný.${NC}"
    NEEDS_INSTALL=true
fi

if [ "$NEEDS_INSTALL" = true ]; then
    echo -e "${YELLOW}[*] Odinštalovávam starú verziu Amass (ak existuje)...${NC}"
    apt-get purge -y amass >/dev/null 2>&1
    rm -f /usr/bin/amass /usr/local/bin/amass

    echo -e "${YELLOW}[*] Inštalujem najnovšiu verziu Amass z GitHubu (môže to chvíľu trvať)...${NC}"
    sudo -u "$SUDO_USER" go install -v github.com/owasp-amass/amass/v3/...@master

    if [ -f "$GO_BIN_PATH/amass" ]; then
        echo -e "${YELLOW}[*] Kopírujem amass do /usr/local/bin/ pre globálny prístup...${NC}"
        cp "$GO_BIN_PATH/amass" /usr/local/bin/
        chmod +x /usr/local/bin/amass
        echo -e "${GREEN}[+] Amass bol úspešne nainštalovaný.${NC}"
    else
        echo -e "${RED}[!] Nepodarilo sa skompilovať Amass.${NC}"
    fi
fi

# --- Funkcia na inštaláciu Go nástrojov ---
install_go_tool() {
    local tool_name="$1"
    local repo_path="$2"
    echo -e "${BLUE}[*] Inštalujem $tool_name...${NC}"
    if command -v "$tool_name" >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] $tool_name je už nainštalovaný.${NC}"
    else
        echo -e "${YELLOW}[*] Sťahujem a kompilujem $tool_name...${NC}"
        sudo -u "$SUDO_USER" go install "$repo_path"
        if [ -f "$GO_BIN_PATH/$tool_name" ]; then
            echo -e "${YELLOW}[*] Kopírujem $tool_name do /usr/local/bin/...${NC}"
            cp "$GO_BIN_PATH/$tool_name" /usr/local/bin/
            chmod +x "/usr/local/bin/$tool_name"
            echo -e "${GREEN}[+] $tool_name bol úspešne nainštalovaný.${NC}"
        else
            echo -e "${RED}[!] Nepodarilo sa skompilovať $tool_name.${NC}"
        fi
    fi
}

# --- Inštalácia gau a waybackurls ---
install_go_tool "gau" "github.com/lc/gau/v2/cmd/gau@latest"
install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls@latest"

# --- ZMENA: Inštalácia sd-goo do lokálneho podadresára ---
echo -e "${BLUE}[*] Inštalujem sd-goo...${NC}"

# Zistíme absolútnu cestu k adresáru, v ktorom sa nachádza tento inštalačný skript
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Nastavíme cestu pre inštaláciu do podadresára 'tools'
TOOLS_DIR="$SCRIPT_DIR/tools"
SDGOO_FINAL_PATH="$TOOLS_DIR/sd-goo"

if [ -f "$SDGOO_FINAL_PATH/sd-goo.sh" ]; then
    echo -e "${GREEN}[✓] sd-goo je už nainštalovaný v $SDGOO_FINAL_PATH.${NC}"
else
    echo -e "${YELLOW}[*] Sťahujem sd-goo z GitHubu do $SDGOO_FINAL_PATH...${NC}"
    mkdir -p "$TOOLS_DIR"
    chown -R "$SUDO_USER:$SUDO_USER" "$TOOLS_DIR"
    
    sudo -u "$SUDO_USER" git clone https://github.com/darklotuskdb/sd-goo.git "$SDGOO_FINAL_PATH"
    
    if [ -d "$SDGOO_FINAL_PATH" ]; then
        echo -e "${YELLOW}[*] Nastavujem práva pre sd-goo.sh...${NC}"
        chmod +x "$SDGOO_FINAL_PATH/sd-goo.sh"
        echo -e "${GREEN}[+] sd-goo bol úspešne nainštalovaný do $SDGOO_FINAL_PATH.${NC}"
    else
        echo -e "${RED}[!] Nepodarilo sa stiahnuť sd-goo.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}======================================================"
echo -e "          INŠTALÁCIA DOKONČENÁ"
echo -e "======================================================${NC}"
echo ""
echo -e "${YELLOW}DÔLEŽITÉ KROKY:${NC}"
echo -e "1. Ak niektorý z Go nástrojov nefunguje, skúste reštartovať terminál."
echo -e "2. ${GREEN}Váš hlavný skript 'subhunter.sh' by mal teraz nájsť sd-goo.sh automaticky.${NC}"
echo -e "3. ${GREEN}Nie je potrebná žiadna manuálna úprava ciest.${NC}"
echo ""
