@echo off
chcp 65001 >nul
title PILOT LAUNCHER v3.7 [FIXED]
color 0B

:: --- ОБНОВЛЕНИЕ ---
set "REPO_URL=https://raw.githubusercontent.com/den2070/minecraft-bat/main/minecraft.bat"
set "LOCAL_BAT=%~nx0"

echo [*] Проверка обновлений...
powershell -Command "$web = (New-Object System.Net.WebClient).DownloadString('%REPO_URL%'); $local = Get-Content '%LOCAL_BAT%' -Raw; if ($web.Trim() -ne $local.Trim()) { exit 1 } else { exit 0 }"

if %errorlevel% neq 0 (
    echo [!] ОБНОВЛЯЮСЬ...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%REPO_URL%', 'new_bat.tmp')"
    copy /y "new_bat.tmp" "%LOCAL_BAT%" >nul
    del /f /q "new_bat.tmp"
    cls
    echo ==========================================
    echo    ОБНОВЛЕНО ДО v3.7! ЗАПУСТИ СНОВА.
    echo ==========================================
    pause
    exit
)

:: --- СОЗДАНИЕ PYTHON ФАЙЛА (БЕЗОПАСНЫЙ МЕТОД) ---
echo [*] Синхронизация систем...

:: Очищаем старые файлы
if exist launcher_engine.py del /f /q launcher_engine.py

:: Записываем код построчно через блок ( ... )
(
echo # -*- coding: utf-8 -*-
echo import os, sys, subprocess, uuid, json, shutil
echo try: import minecraft_launcher_lib
echo except: subprocess.check_call([sys.executable, "-m", "pip", "install", "minecraft-launcher-lib"])
echo import minecraft_launcher_lib
echo ROOT = os.path.dirname(os.path.abspath(__file__^))
echo GAME_DIR = os.path.join(ROOT, "minecraft_data"^)
echo INSTANCES = os.path.join(ROOT, "Instances"^)
echo CONFIG_FILE = os.path.join(ROOT, "config.json"^)
echo for d in [GAME_DIR, INSTANCES]: os.makedirs(d, exist_ok=True^)
echo def set_status(s^): print(f"[*] {s}"^)
echo callback = {"setStatus": set_status, "setProgress": lambda p: None, "setMax": lambda m: None}
echo def load_cfg(^):
echo     d = {"nick": "PILOT_DASTR", "ram": "4"}
echo     if os.path.exists(CONFIG_FILE^):
echo         try:
echo             with open(CONFIG_FILE, "r", encoding="utf-8"^) as f: return {**d, **json.load(f^)}
echo         except: pass
echo     return d
echo def save_cfg(c^):
echo     with open(CONFIG_FILE, "w", encoding="utf-8"^) as f: json.dump(c, f, indent=4, ensure_ascii=False^)
echo def get_inst(^): return [d for d in os.listdir(INSTANCES^) if os.path.isdir(os.path.join(INSTANCES, d^)^)] if os.path.exists(INSTANCES^) else []
echo def start_game(tid, gdir^):
echo     c = load_cfg(^); opt = {"username": c["nick"], "uuid": str(uuid.uuid4(^)^), "token": "0", "jvmArguments": [f"-Xmx{c['ram']}G"], "gameDirectory": gdir}
echo     try:
echo         minecraft_launcher_lib.install.install_minecraft_version(tid, GAME_DIR, callback=callback^)
echo         cmd = minecraft_launcher_lib.command.get_minecraft_command(tid, GAME_DIR, opt^)
echo         print("=== ЗАПУСК ==="^); subprocess.run(cmd^)
echo     except Exception as e: print(f"Ошибка: {e}"^); input(^)
echo def main(^):
echo     while True:
echo         c = load_cfg(^); os.system("cls"^); print("=========================================="^)
echo         print(f"   PILOT v3.7 | NICK: {c['nick']} | RAM: {c['ram']}G"^)
echo         print("=========================================="^)
echo         print("1. СОЗДАТЬ FORGE (Имя-Версия)\n2. ВАНИЛЛА (Версия)\n3. ИГРАТЬ\n4. ПАПКА МОДОВ\n5. НАСТРОЙКИ\n6. ВЫХОД"^)
echo         m = input("Выбор > "^)
echo         if m == "1":
echo             raw = input("Имя-Версия: "^)
echo             try:
echo                 n, v = raw.split("-"^); ip = os.path.join(INSTANCES, n^); mp = os.path.join(ip, ".minecraft"^)
echo                 os.makedirs(os.path.join(mp, "mods"^), exist_ok=True^)
echo                 with open(os.path.join(ip, "brains.json"^), "w", encoding="utf-8"^) as f: json.dump({"v": v, "l": "forge"}, f^)
echo                 print(f"Установка Forge {v}..."^); minecraft_launcher_lib.install.install_minecraft_version(v, GAME_DIR, callback=callback^)
echo                 fv = minecraft_launcher_lib.forge.find_forge_version(v^)
echo                 if fv: minecraft_launcher_lib.forge.install_forge_version(fv, GAME_DIR, callback=callback^)
echo                 print("\n[!] ГОТОВО! Нажми 3 чтобы играть!"^); input(^)
echo             except Exception as e: print(e^); input(^)
echo         elif m == "2":
echo             v = input("Версия ваниллы > "^); start_game(v, GAME_DIR^)
echo         elif m == "3":
echo             items = get_inst(^)
echo             if not items: print("Пусто!"^); input(^); continue
echo             for i, n in enumerate(items, 1^):
echo                 try:
echo                     with open(os.path.join(INSTANCES, n, "brains.json"^), "r", encoding="utf-8"^) as f: b = json.load(f^)
echo                     print(f"{i}. {n} [{b['v']} {b['l'].upper()}]"^)
echo                 except: pass
echo             try:
echo                 s = int(input("> "^)^) - 1; name = items[s]
echo                 with open(os.path.join(INSTANCES, name, "brains.json"^), "r", encoding="utf-8"^) as f: b = json.load(f^)
echo                 tid = b["v"]
echo                 if b["l"] == "forge":
echo                     iv = minecraft_launcher_lib.utils.get_installed_versions(GAME_DIR^)
echo                     for v in iv:
echo                         if "forge" in v["id"].lower(^) and b["v"] in v["id"]: tid = v["id"]; break
echo                 start_game(tid, os.path.join(INSTANCES, name, ".minecraft"^)^)
echo             except: pass
echo         elif m == "4":
echo             items = get_inst(^)
echo             for i, n in enumerate(items, 1^): print(f"{i}. {n}"^)
echo             try: s = int(input("> "^)^) - 1; os.startfile(os.path.join(INSTANCES, items[s], ".minecraft", "mods"^)^)
echo             except: pass
echo         elif m == "5": c["nick"] = input("Ник: "^); c["ram"] = input("ОЗУ: "^); save_cfg(c^)
echo         elif m == "6": break
echo if __name__ == "__main__": main(^)
) > launcher_engine.py

:: Запуск
python launcher_engine.py
pause
