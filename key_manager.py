import tkinter as tk
from tkinter import messagebox, Frame, Canvas, ttk
import yaml
import os

# --- KONFIGURÁCIA ---
HOME_DIR = os.path.expanduser("~")
CONFIG_PATH = os.path.join(HOME_DIR, ".config", "subfinder", "provider-config.yaml")

ALL_PROVIDERS = [
    "bevigil", "binaryedge", "bufferover", "c99", "censys", "certspotter", "chaos", 
    "chinaz", "dnsdb", "dnsrepo", "fofa", "fullhunt", "github", "hunter", "intelx", 
    "leakix", "netlas", "passivetotal", "quake", "robtex", "securitytrails", "shodan", 
    "threatbook", "virustotal", "whoisxmlapi", "zoomeye", "zoomeyeapi"
]

RECOMMENDED_PROVIDERS = ["chaos", "virustotal", "c99", "zoomeyeapi", "zoomeye", "securitytrails"]
OTHER_PROVIDERS = sorted([p for p in ALL_PROVIDERS if p not in RECOMMENDED_PROVIDERS])


# --- DEFINITÍVNE RIEŠENIE PRE FORMÁTOVANIE YAML ---

# 1. Vytvoríme si vlastnú triedu Dumper, ktorá dedí od SafeDumper
class MyDumper(yaml.SafeDumper):
    pass

# 2. Vytvoríme funkciu, ktorá povie, ako presne formátovať zoznam (list)
def flow_style_list_representer(dumper, data):
    """Táto funkcia prinúti YAML použiť flow style ([...]) pre zoznamy."""
    return dumper.represent_sequence('tag:yaml.org,2002:seq', data, flow_style=True)

# 3. Zaregistrujeme našu funkciu pre dátový typ 'list' v našom Dumperi.
# Toto je kľúčový krok: "Vždy, keď narazíš na 'list', použi túto funkciu."
MyDumper.add_representer(list, flow_style_list_representer)


# --- LOGIKA APLIKÁCIE ---

def load_keys_from_file():
    if not os.path.exists(CONFIG_PATH):
        return {}
    try:
        with open(CONFIG_PATH, 'r') as f:
            config = yaml.safe_load(f)
            return config if config is not None else {}
    except Exception as e:
        messagebox.showerror("Chyba", f"Chyba pri načítaní súboru: {e}")
        return {}

def save_keys_to_file():
    new_config = {}
    for provider in ALL_PROVIDERS:
        entry_widget = provider_entries.get(provider)
        if not entry_widget:
            continue
        key = entry_widget.get().strip()
        if key:
            new_config[provider] = [key]
        else:
            new_config[provider] = []
            
    try:
        os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
        with open(CONFIG_PATH, 'w') as f:
            # Použijeme náš vlastný, nakonfigurovaný MyDumper
            yaml.dump(new_config, f, Dumper=MyDumper, indent=4, sort_keys=False)
        messagebox.showinfo("Úspech", "Kľúče boli úspešne uložené!")
    except Exception as e:
        messagebox.showerror("Chyba", f"Chyba pri ukladaní súboru: {e}")

def populate_ui_with_keys():
    existing_keys = load_keys_from_file()
    for provider, entry_widget in provider_entries.items():
        if provider in existing_keys and existing_keys[provider]:
            entry_widget.insert(0, existing_keys[provider][0])


# --- GRAFICKÉ ROZHRANIE (UI) - bez zmien ---

BG_COLOR = "#1e1e1e"
FG_COLOR = "#d4d4d4"
ACCENT_COLOR = "#ce3333"
ENTRY_BG = "#2a2a2a"
ENTRY_FG = "#ffffff"
BUTTON_HOVER = "#a82929"
FONT_TITLE = ("Consolas", 24, "bold")
FONT_SECTION = ("Consolas", 16, "bold")
FONT_NORMAL = ("Consolas", 12)

root = tk.Tk()
root.title("API Key Manager")
root.geometry("800x750")
root.configure(bg=BG_COLOR)

style = ttk.Style(root)
style.theme_use('clam')
style.configure('.', background=BG_COLOR, foreground=FG_COLOR, font=FONT_NORMAL)
style.configure('TFrame', background=BG_COLOR)
style.configure('TLabel', background=BG_COLOR, foreground=FG_COLOR)
style.configure('TSeparator', background=ACCENT_COLOR)
style.configure('TEntry', fieldbackground=ENTRY_BG, foreground=ENTRY_FG, insertcolor=ENTRY_FG, borderwidth=1, relief='flat')
style.configure('Save.TButton', background=ACCENT_COLOR, foreground=ENTRY_FG, font=("Consolas", 14, "bold"), borderwidth=0, relief='flat', padding=10)
style.map('Save.TButton', background=[('active', BUTTON_HOVER)])

title_label = ttk.Label(root, text="API Key Manager", font=FONT_TITLE, foreground=ACCENT_COLOR)
title_label.pack(pady=(20, 15))

container = ttk.Frame(root, padding=10)
container.pack(fill="both", expand=True, padx=10, pady=5)
canvas = Canvas(container, bg=BG_COLOR, highlightthickness=0)
scrollbar = ttk.Scrollbar(container, orient="vertical", command=canvas.yview)
scrollable_frame = ttk.Frame(canvas)
scrollable_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
canvas.configure(yscrollcommand=scrollbar.set)
canvas.pack(side="left", fill="both", expand=True)
scrollbar.pack(side="right", fill="y")
scrollable_frame.grid_columnconfigure(1, weight=1)

def _on_mousewheel(event):
    delta = 0
    if hasattr(event, 'delta'):
        delta = event.delta
    elif hasattr(event, 'num'):
        if event.num == 4: delta = 120
        if event.num == 5: delta = -120
    if delta:
        canvas.yview_scroll(int(-1 * (delta / 120)), "units")

root.bind_all("<MouseWheel>", _on_mousewheel)
root.bind_all("<Button-4>", _on_mousewheel)
root.bind_all("<Button-5>", _on_mousewheel)

provider_entries = {}
current_row = 0

def create_section(title, providers):
    global current_row
    section_label = ttk.Label(scrollable_frame, text=title, font=FONT_SECTION, foreground=ACCENT_COLOR)
    section_label.grid(row=current_row, column=0, columnspan=2, pady=(20, 5), padx=10, sticky="w")
    current_row += 1
    ttk.Separator(scrollable_frame, orient='horizontal').grid(row=current_row, column=0, columnspan=2, sticky='ew', pady=(0, 15), padx=10)
    current_row += 1
    for provider_name in providers:
        label = ttk.Label(scrollable_frame, text=f"{provider_name}:")
        label.grid(row=current_row, column=0, padx=(15, 10), pady=8, sticky="w")
        entry = ttk.Entry(scrollable_frame, width=60, font=FONT_NORMAL)
        entry.grid(row=current_row, column=1, padx=10, pady=8, sticky="ew")
        provider_entries[provider_name] = entry
        current_row += 1

create_section("--- Odporúčané ---", RECOMMENDED_PROVIDERS)
create_section("--- Ostatné ---", OTHER_PROVIDERS)

save_button = ttk.Button(root, text="Uložiť kľúče", style='Save.TButton', command=save_keys_to_file)
save_button.pack(pady=25)

populate_ui_with_keys()
root.mainloop()
