@echo off
chcp 65001 >nul
title PILOT LAUNCHER v4.4
color 0B

:: --- НАСТРОЙКИ ---
set "REPO_URL=https://raw.githubusercontent.com/den2070/minecraft-bat/main/minecraft.bat"
set "LOCAL_BAT=%~nx0"
set "TEMP_BAT=check.tmp"

echo [*] Проверка обновлений...

:: Качаем временный файл для сравнения
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%REPO_URL%', '%TEMP_BAT%')" >nul 2>&1

if not exist "%TEMP_BAT%" (
    echo [!] Нет связи с GitHub. Работаем в офлайн режиме.
    goto :RUN_LAUNCHER
)

:: Сравниваем байты
fc /b "%LOCAL_BAT%" "%TEMP_BAT%" >nul
if %errorlevel% neq 0 (
    echo ==========================================
    echo    [!] НАЙДЕНО ОБНОВЛЕНИЕ!
    echo ==========================================
    :: Удаляем старые версии логики
    del /f /q launcher_v*.py >nul 2>&1
    :: Обновляем сам батник
    copy /y "%TEMP_BAT%" "%LOCAL_BAT%" >nul
    del /f /q "%TEMP_BAT%"
    cls
    echo ==========================================
    echo    УЛУЧШЕНО! Перезапусти файл: %LOCAL_BAT%
    echo ==========================================
    pause
    exit
)

:: Если обновления не нужны, удаляем временный файл и идем дальше
del /f /q "%TEMP_BAT%" >nul 2>&1

:RUN_LAUNCHER
:: --- ЗАПУСК PYTHON ЛОГИКИ ---
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Python не найден!
    pause
    exit
)

:: Создаем свежий файл логики (v4.4)
echo # -*- coding: utf-8 -*- > launcher_v44.py
echo import os, sys, subprocess, uuid, json, shutil >> launcher_v44.py
echo try: import minecraft_launcher_lib >> launcher_v44.py
echo except: subprocess.check_call([sys.executable, "-m", "pip", "install", "minecraft-launcher-lib"]) >> launcher_v44.py
echo ROOT = os.path.dirname(os.path.abspath(__file__)) >> launcher_v44.py
echo GAME_DIR = os.path.join(ROOT, "minecraft_data") >> launcher_v44.py
echo INSTANCES = os.path.join(ROOT, "Instances") >> launcher_v44.py
echo CONFIG_FILE = os.path.join(ROOT, "config.json") >> launcher_v44.py
echo for d in [GAME_DIR, INSTANCES]: os.makedirs(d, exist_ok=True) >> launcher_v44.py
echo def set_status(s): print(f"[*] {s}") >> launcher_v44.py
echo callback = {"setStatus": set_status, "setProgress": lambda p: None, "setMax": lambda m: None} >> launcher_v44.py
echo def load_cfg(): >> launcher_v44.py
echo     d = {"nick": "PILOT_DASTR", "ram": "4"} >> launcher_v44.py
echo     if os.path.exists(CONFIG_FILE): >> launcher_v44.py
echo         try: >> launcher_v44.py
echo             with open(CONFIG_FILE, "r", encoding='utf-8') as f: return {**d, **json.load(f)} >> launcher_v44.py
echo         except: pass >> launcher_v44.py
echo     return d >> launcher_v44.py
echo def save_cfg(c): >> launcher_v44.py
echo     with open(CONFIG_FILE, "w", encoding='utf-8') as f: json.dump(c, f, indent=4, ensure_ascii=False) >> launcher_v44.py
echo def get_inst(): return [d for d in os.listdir(INSTANCES) if os.path.isdir(os.path.join(INSTANCES, d))] if os.path.exists(INSTANCES) else [] >> launcher_v44.py
echo def start_game(tid, gdir): >> launcher_v44.py
echo     c = load_cfg() >> launcher_v44.py
echo     opt = {"username": c["nick"], "uuid": str(uuid.uuid4()), "token": "0", "jvmArguments": [f"-Xmx{c['ram']}G"], "gameDirectory": gdir} >> launcher_v44.py
echo     try: >> launcher_v44.py
echo         minecraft_launcher_lib.install.install_minecraft_version(tid, GAME_DIR, callback=callback) >> launcher_v44.py
echo         cmd = minecraft_launcher_lib.command.get_minecraft_command(tid, GAME_DIR, opt) >> launcher_v44.py
echo         print("=== ЗАПУСК v4.4 ==="); subprocess.run(cmd) >> launcher_v44.py
echo     except Exception as e: print(f"Ошибка: {e}"); input() >> launcher_v44.py
echo def main(): >> launcher_v44.py
echo     while True: >> launcher_v44.py
echo         c = load_cfg(); os.system('cls'); print("==========================================") >> launcher_v44.py
echo         print(f"   PILOT v4.4 | NICK: {c['nick']} | RAM: {c['ram']}G") >> launcher_v44.py
echo         print("==========================================") >> launcher_v44.py
echo         print("1. СОЗДАТЬ FORGE (Имя-Версия)\n2. ВАНИЛЛА (Версия)\n3. ИГРАТЬ (Сборки)\n4. ПАПКА МОДОВ\n5. НАСТРОЙКИ\n6. ВЫХОД") >> launcher_v44.py
echo         m = input("Выбор > ") >> launcher_v44.py
echo         if m == "1": >> launcher_v44.py
echo             raw = input("Имя-Версия: ") >> launcher_v44.py
echo             try: >> launcher_v44.py
echo                 n, v = raw.split("-"); ip = os.path.join(INSTANCES, n); mp = os.path.join(ip, ".minecraft") >> launcher_v44.py
echo                 os.makedirs(os.path.join(mp, "mods"), exist_ok=True) >> launcher_v44.py
echo                 with open(os.path.join(ip, "brains.json"), "w", encoding='utf-8') as f: json.dump({"v": v, "l": "forge"}, f) >> launcher_v44.py
echo                 minecraft_launcher_lib.install.install_minecraft_version(v, GAME_DIR, callback=callback) >> launcher_v44.py
echo                 fv = minecraft_launcher_lib.forge.find_forge_version(v) >> launcher_v44.py
echo                 if fv: minecraft_launcher_lib.forge.install_forge_version(fv, GAME_DIR, callback=callback) >> launcher_v44.py
echo                 print("\n[!] ГОТОВО! Жми 3!"); input() >> launcher_v44.py
echo             except Exception as e: print(e); input() >> launcher_v44.py
echo         elif m == "2": >> launcher_v44.py
echo             v = input("Версия > "); start_game(v, GAME_DIR) >> launcher_v44.py
echo         elif m == "3": >> launcher_v44.py
echo             items = get_inst() >> launcher_v44.py
echo             if not items: print("Пусто!"); input(); continue >> launcher_v44.py
echo             for i, n in enumerate(items, 1): >> launcher_v44.py
echo                 try: >> launcher_v44.py
echo                     with open(os.path.join(INSTANCES, n, "brains.json"), "r", encoding='utf-8') as f: b = json.load(f) >> launcher_v44.py
echo                     print(f"{i}. {n} [{b['v']} {b['l'].upper()}]") >> launcher_v44.py
echo                 except: pass >> launcher_v44.py
echo             try: >> launcher_v44.py
echo                 s = int(input("> ")) - 1; name = items[s] >> launcher_v44.py
echo                 with open(os.path.join(INSTANCES, name, "brains.json"), "r", encoding='utf-8') as f: b = json.load(f) >> launcher_v44.py
echo                 tid = b['v'] >> launcher_v44.py
echo                 if b['l'] == "forge": >> launcher_v44.py
echo                     iv = minecraft_launcher_lib.utils.get_installed_versions(GAME_DIR) >> launcher_v44.py
echo                     for v in iv: >> launcher_v44.py
echo                         if "forge" in v['id'].lower() and b['v'] in v['id']: tid = v['id']; break >> launcher_v44.py
echo                 start_game(tid, os.path.join(INSTANCES, name, ".minecraft")) >> launcher_v44.py
echo             except: pass >> launcher_v44.py
echo         elif m == "4": >> launcher_v44.py
echo             items = get_inst() >> launcher_v44.py
echo             for i, n in enumerate(items, 1): print(f"{i}. {n}") >> launcher_v44.py
echo             try: s = int(input("> ")) - 1; os.startfile(os.path.join(INSTANCES, items[s], ".minecraft", "mods")) >> launcher_v44.py
echo             except: pass >> launcher_v44.py
echo         elif m == "5": c['nick'] = input("Ник: "); c['ram'] = input("ОЗУ: "); save_cfg(c) >> launcher_v44.py
echo         elif m == "6": break >> launcher_v44.py
echo if __name__ == "__main__": main() >> launcher_v44.py

python launcher_v44.py
pause
