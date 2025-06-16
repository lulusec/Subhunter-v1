#!/usr/bin/env python3
import time
import random
import sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Funkcia na vypisovanie stavu na chybový výstup (stderr), aby nerušila hlavný výstup
def log_status(message):
    print(message, file=sys.stderr)

def human_like_typing(element, text):
    for char in text:
        element.send_keys(char)
        time.sleep(random.uniform(0.05, 0.2))

# --- NASTAVENIA PRE MASKAROVANIE BOTA ---
options = Options()
user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
options.add_argument(f'user-agent={user_agent}')
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)
options.add_argument("--headless") # Dôležité pre beh na pozadí
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

driver = None
try:
    driver = webdriver.Chrome(options=options)
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

    log_status("Otváram stránku google.com...")
    driver.get("https://www.google.com")

    try:
        log_status("Čakám na tlačidlo pre súhlas s cookies...")
        accept_button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "L2AGLb"))
        )
        accept_button.click()
        log_status("Súhlas s cookies bol prijatý.")
    except Exception:
        log_status("Tlačidlo pre súhlas s cookies sa nenašlo.")

    log_status("Hľadám vyhľadávacie pole...")
    search_box = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.NAME, "q"))
    )
    
    log_status("Zadávam text 'test' do vyhľadávania...")
    human_like_typing(search_box, "test")
    search_box.send_keys(Keys.RETURN)
    log_status("Vyhľadávanie bolo odoslané.")

    log_status("Čakám na výsledky vyhľadávania...")
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, "rcnt"))
    )
    log_status("Výsledky sa načítali.")

    # Získanie cookies a formátovanie pre výstup
    cookies = driver.get_cookies()
    cookie_parts = [f"{cookie['name']}={cookie['value']}" for cookie in cookies]
    final_cookie_header = f"Cookie: {'; '.join(cookie_parts)}"

    # Vytlačíme IBA finálny reťazec na štandardný výstup. Toto zachytí Bash.
    print(final_cookie_header)

finally:
    log_status("Uzatváram prehliadač.")
    if driver:
        driver.quit()
