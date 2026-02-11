@echo off
chcp 65001 >nul
title PILOT LAUNCHER v3.6 [AUTO-UPDATE]
color 0B

:: --- НАСТРОЙКИ ОБНОВЛЕНИЯ ---
set "REPO_URL=https://raw.githubusercontent.com/den2070/minecraft-bat/main/minecraft.bat"
set "LOCAL_BAT=%~nx0"
set "TEMP_BAT=new_version.tmp"

echo [*] Проверка обновлений...
powershell -Command "$web = (New-Object System.Net.WebClient).DownloadString('%REPO_URL%'); $local = Get-Content '%LOCAL_BAT%' -Raw; if ($web.Trim() -ne $local.Trim()) { exit 1 } else { exit 0 }"

if %errorlevel% neq 0 (
    echo [!] НАЙДЕНО ОБНОВЛЕНИЕ!
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%REPO_URL%', '%TEMP_BAT%')"
    ren "%LOCAL_BAT%" "old_version.bak"
    move /y "%TEMP_BAT%" "%LOCAL_BAT%"
    if exist launcher_*.py del /f /q launcher_*.py
    cls
    echo ==========================================
    echo    УЛУЧШЕНО! Файлы обновлены.
    echo ==========================================
    echo [!] ЗАПУСТИ БАТНИК СНОВА!
    pause
    exit
)

:: --- СОЗДАНИЕ PYTHON ФАЙЛА ЧЕРЕЗ POWERSHELL (ЧТОБЫ НЕ БЫЛО ОШИБОК) ---
echo [*] Запуск систем...
powershell -Command ^
"$code = @'# -*- coding: utf-8 -*- `n" ^
"import os, sys, subprocess, uuid, json, shutil `n" ^
"try: import minecraft_launcher_lib `n" ^
"except: subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'minecraft-launcher-lib']) `n" ^
"import minecraft_launcher_lib `n" ^
"ROOT = os.path.dirname(os.path.abspath(__file__)) `n" ^
"GAME_DIR = os.path.join(ROOT, 'minecraft_data') `n" ^
"INSTANCES = os.path.join(ROOT, 'Instances') `n" ^
"CONFIG_FILE = os.path.join(ROOT, 'config.json') `n" ^
"for d in [GAME_DIR, INSTANCES]: os.makedirs(d, exist_ok=True) `n" ^
"def set_status(s): print(f'[*] {s}') `n" ^
"callback = {'setStatus': set_status, 'setProgress': lambda p: None, 'setMax': lambda m: None} `n" ^
"def load_cfg(): `n" ^
"    d = {'nick': 'PILOT_DASTR', 'ram': '4'} `n" ^
"    if os.path.exists(CONFIG_FILE): `n" ^
"        try: `n" ^
"            with open(CONFIG_FILE, 'r', encoding='utf-8') as f: return {**d, **json.load(f)} `n" ^
"        except: pass `n" ^
"    return d `n" ^
"def save_cfg(c): `n" ^
"    with open(CONFIG_FILE, 'w', encoding='utf-8') as f: json.dump(c, f, indent=4, ensure_ascii=False) `n" ^
"def get_inst(): return [d for d in os.listdir(INSTANCES) if os.path.isdir(os.path.join(INSTANCES, d))] if os.path.exists(INSTANCES) else [] `n" ^
"def start_game(tid, gdir): `n" ^
"    c = load_cfg() `n" ^
"    opt = {'username': c['nick'], 'uuid': str(uuid.uuid4()), 'token': '0', 'jvmArguments': [f'-Xmx{c['ram']}G'], 'gameDirectory': gdir} `n" ^
"    try: `n" ^
"        minecraft_launcher_lib.install.install_minecraft_version(tid, GAME_DIR, callback=callback) `n" ^
"        cmd = minecraft_launcher_lib.command.get_minecraft_command(tid, GAME_DIR, opt) `n" ^
"        print('=== ЗАПУСК ==='); subprocess.run(cmd) `n" ^
"    except Exception as e: print(f'Ошибка: {e}'); input() `n" ^
"def main(): `n" ^
"    while True: `n" ^
"        c = load_cfg(); os.system('cls'); print('==========================================') `n" ^
"        print(f'   PILOT v3.6 | NICK: {c['nick']} | RAM: {c['ram']}G') `n" ^
"        print('==========================================') `n" ^
"        print('1. СОЗДАТЬ FORGE (Имя-Версия)\n2. ВАНИЛЛА (Версия)\n3. ИГРАТЬ\n4. ПАПКА МОДОВ\n5. НАСТРОЙКИ\n6. ВЫХОД') `n" ^
"        m = input('Выбор > ') `n" ^
"        if m == '1': `n" ^
"            raw = input('Имя-Версия: ') `n" ^
"            try: `n" ^
"                n, v = raw.split('-'); ip = os.path.join(INSTANCES, n); mp = os.path.join(ip, '.minecraft') `n" ^
"                os.makedirs(os.path.join(mp, 'mods'), exist_ok=True) `n" ^
"                with open(os.path.join(ip, 'brains.json'), 'w', encoding='utf-8') as f: json.dump({'v': v, 'l': 'forge'}, f) `n" ^
"                print(f'Установка Forge {v}...'); minecraft_launcher_lib.install.install_minecraft_version(v, GAME_DIR, callback=callback) `n" ^
"                fv = minecraft_launcher_lib.forge.find_forge_version(v) `n" ^
"                if fv: minecraft_launcher_lib.forge.install_forge_version(fv, GAME_DIR, callback=callback) `n" ^
"                print('\n[!] ГОТОВО! Нажми 3 чтобы играть!'); input() `n" ^
"            except Exception as e: print(e); input() `n" ^
"        elif m == '2': `n" ^
"            v = input('Версия ваниллы > '); start_game(v, GAME_DIR) `n" ^
"        elif m == '3': `n" ^
"            items = get_inst() `n" ^
"            if not items: print('Пусто!'); input(); continue `n" ^
"            for i, n in enumerate(items, 1): `n" ^
"                try: `n" ^
"                    with open(os.path.join(INSTANCES, n, 'brains.json'), 'r', encoding='utf-8') as f: b = json.load(f) `n" ^
"                    print(f'{i}. {n} [{b[\"v\"]} {b[\"l\"].upper()}]') `n" ^
"                except: pass `n" ^
"            try: `n" ^
"                s = int(input('> ')) - 1; name = items[s] `n" ^
"                with open(os.path.join(INSTANCES, name, 'brains.json'), 'r', encoding='utf-8') as f: b = json.load(f) `n" ^
"                tid = b['v'] `n" ^
"                if b['l'] == 'forge': `n" ^
"                    iv = minecraft_launcher_lib.utils.get_installed_versions(GAME_DIR) `n" ^
"                    for v in iv: `n" ^
"                        if 'forge' in v['id'].lower() and b['v'] in v['id']: tid = v['id']; break `n" ^
"                start_game(tid, os.path.join(INSTANCES, name, '.minecraft')) `n" ^
"            except: pass `n" ^
"        elif m == '4': `n" ^
"            items = get_inst() `n" ^
"            for i, n in enumerate(items, 1): print(f'{i}. {n}') `n" ^
"            try: s = int(input('> ')) - 1; os.startfile(os.path.join(INSTANCES, items[s], '.minecraft', 'mods')) `n" ^
"            except: pass `n" ^
"        elif m == '5': c['nick'] = input('Ник: '); c['ram'] = input('ОЗУ: '); save_cfg(c) `n" ^
"        elif m == '6': break `n" ^
"if __name__ == '__main__': main() `@; $code | Out-File -FilePath launcher_v36.py -Encoding utf8"

:: Запуск
python launcher_v36.py
pause
