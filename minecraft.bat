@echo off
chcp 65001 >nul
title PILOT LAUNCHER v4.1 [THEMES]

set "PY=launcher_engine.py"

:: Предварительная проверка цвета из конфига (чтобы сразу применить)
if exist config.json (
    powershell -Command "$c = Get-Content config.json | ConvertFrom-Json; if ($c.color) { exit [int]$c.color } else { exit 0 }"
    color %errorlevel%
) else (
    color 0B
)

echo [*] Синхронизация систем...
if exist %PY% del /f /q %PY%

echo # -*- coding: utf-8 -*- > %PY%
echo import os, sys, subprocess, uuid, json, shutil >> %PY%
echo try: import minecraft_launcher_lib >> %PY%
echo except: subprocess.check_call([sys.executable, "-m", "pip", "install", "minecraft-launcher-lib"]) >> %PY%
echo import minecraft_launcher_lib >> %PY%
echo ROOT = os.path.dirname(os.path.abspath(__file__)) >> %PY%
echo GAME_DIR = os.path.join(ROOT, "minecraft_data") >> %PY%
echo INSTANCES = os.path.join(ROOT, "Instances") >> %PY%
echo CONFIG_FILE = os.path.join(ROOT, "config.json") >> %PY%
echo for d in [GAME_DIR, INSTANCES]: os.makedirs(d, exist_ok=True) >> %PY%
echo def set_status(s): print(f"[*] {s}") >> %PY%
echo callback = {"setStatus": set_status, "setProgress": lambda p: None, "setMax": lambda m: None} >> %PY%
echo def load_cfg(): >> %PY%
echo     d = {"nick": "PILOT_DASTR", "ram": "4", "color": "0B"} >> %PY%
echo     if os.path.exists(CONFIG_FILE): >> %PY%
echo         try: >> %PY%
echo             with open(CONFIG_FILE, "r", encoding="utf-8") as f: return {**d, **json.load(f)} >> %PY%
echo         except: pass >> %PY%
echo     return d >> %PY%
echo def save_cfg(c): >> %PY%
echo     with open(CONFIG_FILE, "w", encoding="utf-8") as f: json.dump(c, f, indent=4, ensure_ascii=False) >> %PY%
echo     os.system(f"color {c['color']}") >> %PY%
echo def get_inst(): return [d for d in os.listdir(INSTANCES) if os.path.isdir(os.path.join(INSTANCES, d))] if os.path.exists(INSTANCES) else [] >> %PY%
echo def start_game(tid, gdir): >> %PY%
echo     c = load_cfg() >> %PY%
echo     opt = {"username": c["nick"], "uuid": str(uuid.uuid4()), "token": "0", "jvmArguments": [f"-Xmx{c['ram']}G"], "gameDirectory": gdir} >> %PY%
echo     try: >> %PY%
echo         minecraft_launcher_lib.install.install_minecraft_version(tid, GAME_DIR, callback=callback) >> %PY%
echo         cmd = minecraft_launcher_lib.command.get_minecraft_command(tid, GAME_DIR, opt) >> %PY%
echo         print("=== ЗАПУСК ==="); subprocess.run(cmd) >> %PY%
echo     except Exception as e: print(f"Ошибка: {e}"); input() >> %PY%
echo def main(): >> %PY%
echo     while True: >> %PY%
echo         c = load_cfg(); os.system("cls"); print("==========================================") >> %PY%
echo         print(f"   PILOT v4.1 | NICK: {c['nick']} | RAM: {c['ram']}G") >> %PY%
echo         print("==========================================") >> %PY%
echo         print("1. СОЗДАТЬ FORGE\n2. ВАНИЛЛА\n3. ИГРАТЬ\n4. ПАПКА МОДОВ\n5. НАСТРОЙКИ\n6. ВЫХОД") >> %PY%
echo         m = input("Выбор > ") >> %PY%
echo         if m == "1": >> %PY%
echo             raw = input("Имя-Версия: ") >> %PY%
echo             try: >> %PY%
echo                 n, v = raw.split("-"); ip = os.path.join(INSTANCES, n); mp = os.path.join(ip, ".minecraft") >> %PY%
echo                 os.makedirs(os.path.join(mp, "mods"), exist_ok=True) >> %PY%
echo                 with open(os.path.join(ip, "brains.json"), "w", encoding="utf-8") as f: json.dump({"v": v, "l": "forge"}, f) >> %PY%
echo                 print(f"Установка Forge {v}..."); minecraft_launcher_lib.install.install_minecraft_version(v, GAME_DIR, callback=callback) >> %PY%
echo                 fv = minecraft_launcher_lib.forge.find_forge_version(v) >> %PY%
echo                 if fv: minecraft_launcher_lib.forge.install_forge_version(fv, GAME_DIR, callback=callback) >> %PY%
echo                 print("\n[!] ГОТОВО!"); input() >> %PY%
echo             except Exception as e: print(e); input() >> %PY%
echo         elif m == "2": v = input("Версия > "); start_game(v, GAME_DIR) >> %PY%
echo         elif m == "3": >> %PY%
echo             items = get_inst() >> %PY%
echo             if not items: print("Пусто!"); input(); continue >> %PY%
echo             for i, n in enumerate(items, 1): >> %PY%
echo                 try: >> %PY%
echo                     with open(os.path.join(INSTANCES, n, "brains.json"), "r", encoding="utf-8") as f: b = json.load(f) >> %PY%
echo                     print(f"{i}. {n} [{b['v']} {b['l'].upper()}]") >> %PY%
echo                 except: pass >> %PY%
echo             try: >> %PY%
echo                 s = int(input("> ")) - 1; name = items[s] >> %PY%
echo                 with open(os.path.join(INSTANCES, name, "brains.json"), "r", encoding="utf-8") as f: b = json.load(f) >> %PY%
echo                 tid = b["v"] >> %PY%
echo                 if b["l"] == "forge": >> %PY%
echo                     iv = minecraft_launcher_lib.utils.get_installed_versions(GAME_DIR) >> %PY%
echo                     for v in iv: >> %PY%
echo                         if "forge" in v["id"].lower() and b["v"] in v["id"]: tid = v["id"]; break >> %PY%
echo                 start_game(tid, os.path.join(INSTANCES, name, ".minecraft")) >> %PY%
echo             except: pass >> %PY%
echo         elif m == "4": >> %PY%
echo             items = get_inst() >> %PY%
echo             for i, n in enumerate(items, 1): print(f"{i}. {n}") >> %PY%
echo             try: s = int(input("> ")) - 1; os.startfile(os.path.join(INSTANCES, items[s], ".minecraft", "mods")) >> %PY%
echo             except: pass >> %PY%
echo         elif m == "5": >> %PY%
echo             print("--- НАСТРОЙКИ ---") >> %PY%
echo             c['nick'] = input(f"Ник [{c['nick']}]: ") or c['nick'] >> %PY%
echo             c['ram'] = input(f"ОЗУ [{c['ram']}]: ") or c['ram'] >> %PY%
echo             print("Цвета: 0B (Голубой), 0A (Зеленый), 0C (Красный), 0E (Желтый), 0F (Белый), 5F (Фиолетовый)") >> %PY%
echo             c['color'] = input(f"Цвет [{c['color']}]: ") or c['color'] >> %PY%
echo             save_cfg(c) >> %PY%
echo         elif m == "6": break >> %PY%
echo if __name__ == "__main__": main() >> %PY%

if exist %PY% (
    python %PY%
)
pause
