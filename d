"""
Загрузка Fortran-ядра физики через ctypes.
Если physics.dll/.so не найден — используются Python-фолбэки.
"""
import os
import ctypes
import math

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

_lib = None
for name in ("physics.dll", "physics.so", "physics.dylib"):
    path = os.path.join(BASE_DIR, name)
    if os.path.exists(path):
        try:
            _lib = ctypes.CDLL(path)
            print(f"[i] Физика Fortran загружена: {name}")
            break
        except Exception as e:
            print(f"[!] Не удалось загрузить {name}: {e}")


if _lib:
    # update_gravity(y*, vy*, dt, gravity) — y,vy по ссылке; dt,gravity by value
    _lib.update_gravity.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.c_double,
    ]
    _lib.update_gravity.restype = None

    # rects_collide(8 doubles by value) -> int
    _lib.rects_collide.argtypes = [ctypes.c_double] * 8
    _lib.rects_collide.restype = ctypes.c_int

    # distance(4 doubles) -> double
    _lib.distance.argtypes = [ctypes.c_double] * 4
    _lib.distance.restype = ctypes.c_double

    # lerp(3 doubles) -> double
    _lib.lerp.argtypes = [ctypes.c_double] * 3
    _lib.lerp.restype = ctypes.c_double

    # clamp(3 doubles) -> double
    _lib.clamp.argtypes = [ctypes.c_double] * 3
    _lib.clamp.restype = ctypes.c_double


# ============ PYTHON-ОБЁРТКИ ============

def update_gravity(y, vy, dt, gravity):
    if _lib:
        _y  = ctypes.c_double(y)
        _vy = ctypes.c_double(vy)
        _lib.update_gravity(
            ctypes.byref(_y), ctypes.byref(_vy),
            ctypes.c_double(dt), ctypes.c_double(gravity),
        )
        return _y.value, _vy.value
    vy += gravity * dt
    y  += vy * dt
    return y, vy


def rects_collide(ax, ay, aw, ah, bx, by, bw, bh):
    if _lib:
        try:
            return bool(_lib.rects_collide(
                ctypes.c_double(ax), ctypes.c_double(ay),
                ctypes.c_double(aw), ctypes.c_double(ah),
                ctypes.c_double(bx), ctypes.c_double(by),
                ctypes.c_double(bw), ctypes.c_double(bh),
            ))
        except Exception:
            pass
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by


def distance(x1, y1, x2, y2):
    if _lib:
        return _lib.distance(x1, y1, x2, y2)
    return math.hypot(x2 - x1, y2 - y1)


def lerp(a, b, t):
    if _lib:
        return _lib.lerp(a, b, t)
    return a + (b - a) * t


def clamp(v, lo, hi):
    if _lib:
        return _lib.clamp(v, lo, hi)
    return max(lo, min(hi, v))
{
  "player_name": "popc",
  "music_volume": 0.43333333333333335,
  "sfx_volume": 0.48518518518518516,
  "accel_3d": true,
  "fullscreen": false
}
{
  "_comment": "PvZ-style tower defense. Все пути — относительно корня проекта.",

  "screen": {
    "width": 1200,
    "height": 750,
    "fps": 60,
    "title": "Plants vs Zombies — Edgewalk",
    "vsync": true
  },

  "field": {
    "cols": 9,
    "rows": 5,
    "cell_w": 96,
    "cell_h": 98,
    "x": 210,
    "y": 100,
    "grid_alpha": 30,
    "show_grid": true
  },

  "paths": {
    "root": ".",
    "assets": "assets",
    "images": "assets/images",
    "audio": "assets/audio",
    "data": "data",
    "icon": "PvZ-Edgewalk.png",
    "cache": "animations.json",
    "effects": "effects.json",
    "worlds": "data/worlds.json",
    "levels": "data/levels.json",
    "save": "save/profile.json"
  },

  "ui": {
    "card_x0": 215,
    "card_y": 10,
    "card_gap": 6,
    "max_cards": 10,
    "sun_rect":   [10, 10, 110, 90],
    "shovel_rect":[125, 10, 80, 90],
    "progress_bar": {
      "w": 280,
      "h": 24,
      "margin_right": 20,
      "margin_bottom": 10
    },
    "dave_pos": [10, 620],
    "message_y": 170,
    "hint_y_offset": 30,
    "fonts": {
      "small": 14,
      "normal": 18,
      "mid": 24,
      "big": 56
    }
  },

  "intro": {
    "enabled": true,
    "duration": 2.4,
    "phases": ["READY", "SET", "PLANT!"],
    "colors": ["YELLOW", "YELLOW", "YELLOW"]
  },

  "sun": {
    "start": 100,
    "value": 25,
    "fall_interval": 8.0,
    "lifetime": 12.0,
    "fall_speed": 60.0,
    "collect_radius": 1.4,
    "float_text_lifetime": 0.9
  },

  "lawnmower": {
    "enabled": true,
    "speed": 720.0,
    "sound": "lawnmower",
    "start_offset_x": -55
  },

  "plants": {
    "SunFlower":       {"cost": 50,   "hp": 300,  "cd": 7.5,  "sun_interval": 24.0, "sun_value": 25},
    "TwinSunflower":   {"cost": 150,  "hp": 300,  "cd": 50.0, "sun_interval": 24.0, "sun_value": 50},
    "SunShroom":       {"cost": 25,   "hp": 300,  "cd": 7.5,  "sun_interval": 24.0, "sun_value": 15},
    "Peashooter":      {"cost": 100,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4},
    "Repeater":        {"cost": 200,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "shots": 2},
    "SnowPea":         {"cost": 175,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "freeze": 5.0},
    "SnowRepeater":    {"cost": 250,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "freeze": 5.0, "shots": 2},
    "Threepeater":     {"cost": 325,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "rows": [-1, 0, 1]},
    "GatlingPea":      {"cost": 250,  "hp": 300,  "cd": 50.0, "damage": 20,  "rate": 1.4, "shots": 4},
    "SplitPea":        {"cost": 125,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "backward": true},
    "LotusRoot":       {"cost": 200,  "hp": 300,  "cd": 7.5,  "damage": 500, "rate": 1.4},
    "Cactus":          {"cost": 125,  "hp": 300,  "cd": 7.5,  "damage": 30,  "rate": 1.4, "air": true},
    "Starfruit":       {"cost": 125,  "hp": 300,  "cd": 7.5,  "damage": 20,  "rate": 1.4, "dirs": 4},
    "LaserBean":       {"cost": 200,  "hp": 300,  "cd": 7.5,  "damage": 850, "rate": 3.0, "pierce": 5},
    "Gun":             {"cost": 100,  "hp": 300,  "cd": 7.5},
    "WallNut":         {"cost": 50,   "hp": 4000, "cd": 30.0},
    "TallNut":         {"cost": 125,  "hp": 8000, "cd": 30.0},
    "Ling":            {"cost": 150,  "hp": 10000,"cd": 50.0},
    "TenManNut":       {"cost": 200,  "hp": 11000,"cd": 50.0},
    "PumpkinHead":     {"cost": 125,  "hp": 4000, "cd": 30.0},
    "Garlic":          {"cost": 50,   "hp": 400,  "cd": 7.5,  "lure": true},
    "CherryBomb":      {"cost": 150,  "hp": 9999, "cd": 50.0, "damage": 1800, "radius": 1.5},
    "Jalapeno":        {"cost": 125,  "hp": 9999, "cd": 50.0, "damage": 1800, "row_wide": true},
    "PotatoMine":      {"cost": 25,   "hp": 1000, "cd": 30.0, "damage": 1800, "arm_time": 14.0},
    "Squash":          {"cost": 50,   "hp": 300,  "cd": 30.0, "damage": 1800},
    "Torchwood":       {"cost": 175,  "hp": 300,  "cd": 7.5,  "damage_bonus": 20},
    "Spikeweed":       {"cost": 100,  "hp": 300,  "cd": 7.5,  "damage": 20},
    "Spikerock":       {"cost": 125,  "hp": 300,  "cd": 7.5,  "damage": 40},
    "Chomper":         {"cost": 150,  "hp": 300,  "cd": 7.5,  "chew_time": 42.0},
    "BigChomper":      {"cost": 200,  "hp": 300,  "cd": 7.5,  "chew_time": 20.0},
    "FumeShroom":      {"cost": 75,   "hp": 300,  "cd": 7.5,  "damage": 20,  "range": 4},
    "IceFumeShroom":   {"cost": 125,  "hp": 300,  "cd": 7.5,  "damage": 20,  "range": 4, "freeze": 5.0},
    "GloomShroom":     {"cost": 150,  "hp": 300,  "cd": 7.5,  "damage": 20,  "radius": 1},
    "PuffShroom":      {"cost": 0,    "hp": 300,  "cd": 7.5,  "damage": 20,  "range": 3},
    "ScaredyShroom":   {"cost": 25,   "hp": 300,  "cd": 7.5,  "damage": 20,  "range": 3},
    "HypnoShroom":     {"cost": 75,   "hp": 300,  "cd": 30.0, "hypnotize": true},
    "IceShroom":       {"cost": 75,   "hp": 300,  "cd": 50.0, "freeze_all": 10.0},
    "DoomShroom":      {"cost": 125,  "hp": 300,  "cd": 50.0, "damage": 1800, "radius": 3, "crater": true},
    "CoffeeBean":      {"cost": 75,   "hp": 300,  "cd": 7.5,  "wake": true},
    "SeaShroom":       {"cost": 0,    "hp": 300,  "cd": 7.5,  "damage": 20},
    "MagneticmuShroom":{"cost": 100,  "hp": 300,  "cd": 7.5,  "magnet": true},
    "FlamesMushroom":  {"cost": 75,   "hp": 2000, "cd": 30.0, "fire_damage": 150},
    "TangleKlep":      {"cost": 25,   "hp": 300,  "cd": 30.0, "grab": true},
    "SeaAnemone":      {"cost": 100,  "hp": 300,  "cd": 7.5,  "damage": 20},
    "LilyPad":         {"cost": 25,   "hp": 1000, "cd": 7.5,  "platform": true},
    "Oxygen":          {"cost": 100,  "hp": 300,  "cd": 7.5},
    "Plantern":        {"cost": 25,   "hp": 300,  "cd": 7.5,  "light": 3},
    "TTS":             {"cost": 150,  "hp": 300,  "cd": 30.0},
    "star":            {"cost": 100,  "hp": 4000, "cd": 30.0},
    "GraveBuster":     {"cost": 75,   "hp": 300,  "cd": 7.5,  "clear_grave": true},
    "FlowerPot":       {"cost": 25,   "hp": 1000, "cd": 7.5,  "platform": true},
    "CFlowerPot":      {"cost": 25,   "hp": 1000, "cd": 7.5,  "platform": true},
    "LilyPad1":        {"cost": 25,   "hp": 1000, "cd": 7.5,  "platform": true},
    "OG":              {"cost": 0,    "hp": 1000, "cd": 7.5},
    "Jackfruit":       {"cost": 75,   "hp": 300,  "cd": 15.0, "damage": 100}
  },

  "zombies": {
    "Zombie":              {"hp": 200,  "speed": 18.0, "damage": 100},
    "FlagZombie":          {"hp": 200,  "speed": 22.0, "damage": 100, "flag": true},
    "ConeheadZombie":      {"hp": 200,  "armor_hp": 370,  "speed": 18.0, "damage": 100, "ornaments": 1},
    "BucketheadZombie":    {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2},
    "CBucketheadZombie":   {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2},
    "CConeheadZombie":     {"hp": 200,  "armor_hp": 370,  "speed": 18.0, "damage": 100, "ornaments": 1},
    "FootballZombie":      {"hp": 200,  "armor_hp": 1400, "speed": 32.0, "damage": 100, "ornaments": 2},
    "HeiFootballZombie":   {"hp": 200,  "armor_hp": 1400, "speed": 36.0, "damage": 100, "ornaments": 2},
    "CFootballZombie":     {"hp": 200,  "armor_hp": 1400, "speed": 32.0, "damage": 100, "ornaments": 2},
    "SmallFootballZombie": {"hp": 200,  "armor_hp": 700,  "speed": 40.0, "damage": 100, "ornaments": 2},
    "ScreenDoorZombie":    {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2, "block_front": true},
    "TrashZombie":         {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2},
    "JY":                  {"hp": 1000, "armor_hp": 1000, "speed": 26.0, "damage": 100, "ornaments": 2},
    "NewspaperZombie":     {"hp": 200,  "armor_hp": 200,  "speed": 18.0, "damage": 100, "ornaments": 1, "rage_speed": 45.0},
    "CNewspaperZombie":    {"hp": 200,  "armor_hp": 200,  "speed": 18.0, "damage": 100, "ornaments": 1, "rage_speed": 45.0},
    "DuckyTubeZombie":     {"hp": 200,  "speed": 18.0, "damage": 100, "water": true},
    "DuckyTubeZombie2":    {"hp": 200,  "armor_hp": 370,  "speed": 18.0, "damage": 100, "ornaments": 1, "water": true},
    "DuckyTubeZombie3":    {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2, "water": true},
    "DuckyTubeZombie4":    {"hp": 200,  "armor_hp": 1100, "speed": 18.0, "damage": 100, "ornaments": 2, "water": true},
    "SnorkelZombie":       {"hp": 200,  "speed": 20.0, "damage": 100, "water": true, "submerge": true},
    "DolphinRiderZombie":  {"hp": 200,  "speed": 45.0, "damage": 100, "water": true, "jump": true},
    "PoleVaultingZombie":  {"hp": 340,  "speed": 30.0, "damage": 100, "jump": true},
    "DancingZombie":       {"hp": 500,  "speed": 22.0, "damage": 100, "summon": ["BackupDancer", 4]},
    "BackupDancer":        {"hp": 200,  "speed": 22.0, "damage": 100},
    "BalloonZombie":       {"hp": 200,  "armor_hp": 20,   "speed": 25.0, "damage": 100, "ornaments": 1, "flying": true},
    "JackInTheBoxZombie":  {"hp": 500,  "speed": 24.0, "damage": 100, "explode_at": 0.3},
    "DiggerZombie":        {"hp": 200,  "speed": 30.0, "damage": 100, "underground": true},
    "PogoZombie":          {"hp": 340,  "speed": 30.0, "damage": 100, "jump": true},
    "Zomboni":             {"hp": 1350, "speed": 40.0, "damage": 0,   "ice_trail": true},
    "ZombieBobSled":       {"hp": 200,  "speed": 50.0, "damage": 100},
    "ZombieYeti":          {"hp": 1350, "speed": 20.0, "damage": 100},
    "Gargantuar":          {"hp": 3000, "speed": 12.0, "damage": 1800, "smash": true},
    "RedGargantuar":       {"hp": 3000, "speed": 14.0, "damage": 1800, "smash": true},
    "Imp":                 {"hp": 270,  "speed": 30.0, "damage": 100},
    "PeashooterZombie":    {"hp": 200,  "speed": 18.0, "damage": 100, "ranged": true},
    "WallnutZombie":       {"hp": 200,  "speed": 18.0, "damage": 100},
    "GatlingZombie":       {"hp": 200,  "speed": 18.0, "damage": 100, "ranged": true},
    "SquashZombie":        {"hp": 200,  "speed": 18.0, "damage": 100},
    "TallnutZombie":       {"hp": 200,  "speed": 18.0, "damage": 100},
    "JalapenoZombie":      {"hp": 200,  "speed": 18.0, "damage": 100},
    "CherryZombie":        {"hp": 200,  "speed": 18.0, "damage": 100},
    "SunflowerZombie":     {"hp": 200,  "speed": 18.0, "damage": 100},
    "ChomperZombie":       {"hp": 200,  "speed": 18.0, "damage": 100}
  },

  "waves": [
    [20.0,  {"Zombie": 1}],
    [50.0,  {"Zombie": 2}],
    [90.0,  {"Zombie": 1, "ConeheadZombie": 1}],
    [140.0, {"Zombie": 2, "ConeheadZombie": 1}],
    [200.0, {"Zombie": 2, "ConeheadZombie": 2, "BucketheadZombie": 1}],
    [270.0, {"Zombie": 3, "ConeheadZombie": 2, "BucketheadZombie": 1}],
    [350.0, {"Zombie": 3, "ConeheadZombie": 3, "BucketheadZombie": 2}],
    [440.0, {"Zombie": 4, "ConeheadZombie": 3, "BucketheadZombie": 2, "FootballZombie": 1}],
    [540.0, {"Zombie": 5, "ConeheadZombie": 4, "BucketheadZombie": 3, "ScreenDoorZombie": 1}],
    [650.0, {"Zombie": 6, "ConeheadZombie": 4, "BucketheadZombie": 3, "Gargantuar": 1}]
  ],

  "worlds": {
    "default": "modern",
    "list": [
      "egypt", "pirate", "wild_west", "kongfu", "frozen",
      "dark_ages", "lost_city", "neon", "jurassic",
      "big_wave", "modern", "china"
    ]
  },

  "card_order": [
    "SunFlower", "Peashooter", "WallNut", "PotatoMine",
    "SnowPea", "Chomper", "Repeater", "PuffShroom",
    "SunShroom", "FumeShroom", "Jackfruit"
  ],

  "sounds": {
    "enabled": true,
    "volume": 0.7
  },

  "colors": {
    "WHITE":  [255, 255, 255],
    "BLACK":  [0, 0, 0],
    "RED":    [220, 40, 40],
    "GREEN":  [60, 180, 60],
    "YELLOW": [255, 220, 0],
    "GRAY":   [120, 120, 120],
    "DARK":   [40, 40, 40],
    "SUN_BG": [240, 220, 160],
    "CARD_BG":[60, 40, 20],
    "PROGRESS": [200, 60, 60]
  }
}
"""
Загрузчик settings.json.
Все константы экспортируются как раньше — код, который делал
`from settings import FIELD_X, PLANTS` — продолжит работать.
"""
import os
import json

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SETTINGS_FILE = os.path.join(BASE_DIR, "settings.json")


def _load():
    with open(SETTINGS_FILE, "r", encoding="utf-8") as fp:
        return json.load(fp)


_cfg = _load()

# === ЭКРАН ===
SCREEN_WIDTH  = _cfg["screen"]["width"]
SCREEN_HEIGHT = _cfg["screen"]["height"]
FPS           = _cfg["screen"]["fps"]

# === ПОЛЕ ===
FIELD_COLS = _cfg["field"]["cols"]
FIELD_ROWS = _cfg["field"]["rows"]
CELL_W     = _cfg["field"]["cell_w"]
CELL_H     = _cfg["field"]["cell_h"]
FIELD_X    = _cfg["field"]["x"]
FIELD_Y    = _cfg["field"]["y"]
FIELD_W    = FIELD_COLS * CELL_W
FIELD_H    = FIELD_ROWS * CELL_H

# === ПУТИ ===
ASSETS    = os.path.join(BASE_DIR, _cfg["paths"]["assets"])
IMG       = os.path.join(BASE_DIR, _cfg["paths"]["images"])
AUDIO     = os.path.join(BASE_DIR, _cfg["paths"]["audio"])
ICON_PATH = os.path.join(BASE_DIR, _cfg["paths"]["icon"])
CACHE_FILE = os.path.join(BASE_DIR, _cfg["paths"]["cache"])
WORLDS_FILE = os.path.join(BASE_DIR, _cfg["paths"].get("worlds", "data/worlds.json"))
LEVELS_FILE = os.path.join(BASE_DIR, _cfg["paths"].get("levels", "data/levels.json"))
EFFECTS_FILE = os.path.join(BASE_DIR, _cfg["paths"].get("effects", "effects.json"))
CRAFTING_FILE = os.path.join(BASE_DIR, _cfg["paths"].get("crafting", "crafting.json"))
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")

# === СОЛНЦЕ ===
START_SUN         = _cfg["sun"]["start"]
SUN_VALUE         = _cfg["sun"]["value"]
SUN_FALL_INTERVAL = _cfg["sun"]["fall_interval"]
SUN_LIFETIME      = _cfg["sun"]["lifetime"]
SUN_FALL_SPEED    = _cfg["sun"]["fall_speed"]

# === БАЛАНС ===
PLANTS = dict(_cfg["plants"])   # копия, чтобы JSON мог дополнять

# === ЗАГРУЗКА РАСТЕНИЙ ИЗ plants.json ===
try:
    from entities.plants_loader import load_plants, plants_to_settings_dict
    _json_plants = load_plants()
    if _json_plants:
        _json_dict = plants_to_settings_dict(_json_plants)
        # JSON переопределяет одноимённые из settings.json и добавляет новые
        PLANTS.update(_json_dict)
        print(f"[i] Загружено растений из plants.json: {len(_json_dict)}")
    else:
        print("[i] plants.json пуст или не найден — использую settings.json")
except Exception as e:
    print(f"[!] plants.json не загружен: {e}")

# === ЗОМБИ / ВОЛНЫ / СПИСКИ ===
ZOMBIES   = _cfg["zombies"]
WAVES     = [tuple(w) for w in _cfg["waves"]]
ALL_PLANTS = list(PLANTS.keys())

# CARD_ORDER — какие растения доступны в игре по умолчанию.
# Если хочешь, чтобы ВСЕ растения из PLANTS были доступны:
#   CARD_ORDER = list(PLANTS.keys())
# Сейчас — дефолтная пятёрка + новые из plants.json:
DEFAULT_CARDS = ["SunFlower", "Peashooter", "WallNut", "CherryBomb", "BigChomper"]
CARD_ORDER = [k for k in DEFAULT_CARDS if k in PLANTS]

# === ЦВЕТА ===
_c = _cfg["colors"]
WHITE  = tuple(_c["WHITE"])
BLACK  = tuple(_c["BLACK"])
RED    = tuple(_c["RED"])
GREEN  = tuple(_c["GREEN"])
YELLOW = tuple(_c["YELLOW"])
GRAY   = tuple(_c["GRAY"])
DARK   = tuple(_c["DARK"])
# world_data.py
"""
Список миров PvZ 2. Иконки лежат в interface/worlds/<id>.png
"""

WORLDS = [
    {
        "id": "egypt",
        "name": "Ancient Egypt",
        "difficulty": 1,
        "levels": 25,
        "color": (200, 170, 90),
    },
    {
        "id": "pirate",
        "name": "Pirate Seas",
        "difficulty": 2,
        "levels": 25,
        "color": (90, 150, 200),
    },
    {
        "id": "wild_west",
        "name": "Wild West",
        "difficulty": 2,
        "levels": 25,
        "color": (200, 120, 60),
    },
    {
        "id": "kongfu",
        "name": "Kongfu",
        "difficulty": 3,
        "levels": 25,
        "color": (180, 80, 80),
    },
    {
        "id": "frozen",
        "name": "Frostbite Caves",
        "difficulty": 3,
        "levels": 25,
        "color": (150, 200, 230),
    },
    {
        "id": "dark_ages",
        "name": "Dark Ages",
        "difficulty": 3,
        "levels": 20,
        "color": (100, 80, 150),
    },
    {
        "id": "lost_city",
        "name": "Lost City",
        "difficulty": 4,
        "levels": 25,
        "color": (120, 180, 100),
    },
    {
        "id": "neon",
        "name": "Neon Mixtape Tour",
        "difficulty": 4,
        "levels": 25,
        "color": (200, 80, 200),
    },
    {
        "id": "jurassic",
        "name": "Jurassic Marsh",
        "difficulty": 4,
        "levels": 25,
        "color": (100, 160, 80),
    },
    {
        "id": "big_wave",
        "name": "Big Wave Beach",
        "difficulty": 5,
        "levels": 25,
        "color": (80, 180, 200),
    },
    {
        "id": "modern",
        "name": "Modern Day",
        "difficulty": 5,
        "levels": 25,
        "color": (150, 150, 170),
    },
    {
        "id": "china",
        "name": "China",
        "difficulty": 5,
        "levels": 25,
        "color": (200, 60, 60),
    },
]
"""
Редактор анимаций PvZ-Edgewalk.
Запуск: python anim_editor.py

Требует: pip install Pillow tkinterdnd2

Управление:
  ЛКМ по карточке — выбрать анимацию
  Перетаскивание карточки на категорию/растение/зомби — привязать
  Delete — удалить выбранную из animations.json
  S — сохранить
  A — добавить GIF через диалог
  Esc — выход
"""
import os
import json
import shutil
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from PIL import Image, ImageTk, ImageSequence

try:
    from tkinterdnd2 import DND_FILES, TkinterDnD
    HAS_DND = True
except ImportError:
    HAS_DND = False
    print("[!] tkinterdnd2 не установлен — drag&drop не будет работать. "
          "pip install tkinterdnd2")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_FILE = os.path.join(BASE_DIR, "animations.json")
IMG_DIR = os.path.join(BASE_DIR, "assets", "images")

# Все возможные цели привязки
PLANTS = [
    "SunFlower", "TwinSunflower", "SunShroom",
    "Peashooter", "Repeater", "SnowPea", "SnowRepeater", "Threepeater",
    "GatlingPea", "SplitPea", "LotusRoot", "Cactus", "Starfruit",
    "LaserBean", "Gun",
    "WallNut", "TallNut", "Ling", "TenManNut", "PumpkinHead", "Garlic",
    "CherryBomb", "Jalapeno", "PotatoMine", "Squash",
    "Torchwood", "Spikeweed", "Spikerock",
    "Chomper", "BigChomper",
    "FumeShroom", "IceFumeShroom", "GloomShroom", "PuffShroom",
    "ScaredyShroom", "HypnoShroom", "IceShroom", "DoomShroom",
    "CoffeeBean", "MagneticmuShroom", "FlamesMushroom",
    "SeaShroom", "TangleKlep", "SeaAnemone",
    "Plantern", "Oxygen", "OG", "TTS", "star", "star1",
    "GraveBuster", "LawnCleaner", "Cleaner", "PoolCleaner",
    "FlowerPot", "CFlowerPot", "LilyPad", "LilyPad1",
    "GoldenPrize", "Brains",
]

ZOMBIES = [
    "Zombie", "FlagZombie", "ConeheadZombie", "BucketheadZombie",
    "CBucketheadZombie", "CConeheadZombie",
    "FootballZombie", "HeiFootballZombie", "CFootballZombie",
    "SmallFootballZombie",
    "ScreenDoorZombie", "TrashZombie", "JY",
    "NewspaperZombie", "CNewspaperZombie",
    "DuckyTubeZombie", "DuckyTubeZombie2", "DuckyTubeZombie3", "DuckyTubeZombie4",
    "SnorkelZombie", "DolphinRiderZombie",
    "PoleVaultingZombie", "DancingZombie", "BackupDancer",
    "BalloonZombie", "JackInTheBoxZombie",
    "DiggerZombie", "PogoZombie", "Zomboni", "ZombieBobSled",
    "ZombieYeti", "Gargantuar", "RedGargantuar", "Imp",
    "PeashooterZombie", "WallnutZombie", "GatlingZombie",
    "SquashZombie", "TallnutZombie", "JalapenoZombie",
    "CherryZombie", "SunflowerZombie", "ChomperZombie",
]

OTHER_GROUPS = {
    "UI": ["Sun.gif", "Dave.gif", "PointerUP.gif", "PointerDown.gif",
           "Shovel", "FinalWave.gif", "LargeWave.gif"],
    "Card": ["Card"],
    "Effects": ["effects", "Effects", "Boom", "Explosion"],
    "Interface": ["Interface", "interface", "background"],
    "Прочее": [],
}

ALL_TARGETS = {
    "Растения": PLANTS,
    "Зомби": ZOMBIES,
    "UI": OTHER_GROUPS["UI"],
    "Effects": OTHER_GROUPS["Effects"],
    "Прочее": OTHER_GROUPS["Прочее"],
}


def load_json():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r", encoding="utf-8") as fp:
                return json.load(fp)
        except Exception as e:
            print(f"[!] animations.json битый: {e}")
    return {}


def save_json(data):
    with open(CACHE_FILE, "w", encoding="utf-8") as fp:
        json.dump(data, fp, indent=2, ensure_ascii=False)


def first_frame_path(rel_path):
    folder = os.path.dirname(rel_path)
    base = os.path.splitext(os.path.basename(rel_path))[0]
    frames_dir = os.path.join(BASE_DIR, folder, f"{base}_frames")
    if not os.path.isdir(frames_dir):
        return None
    pngs = sorted(f for f in os.listdir(frames_dir) if f.endswith(".png"))
    if not pngs:
        return None
    return os.path.join(frames_dir, pngs[0])


class AnimEditor:
    THUMB = 96
    CARD_H = 130

    def __init__(self, root):
        self.root = root
        self.root.title("PvZ-Edgewalk — Редактор анимаций")
        self.root.geometry("1400x820")
        self.root.configure(bg="#2b2b2b")

        self.data = load_json()
        self.dirty = False
        self.selected_key = None
        self.cards = {}
        self.photo_cache = {}
        self.filter_text = tk.StringVar()
        self.target_filter = tk.StringVar()
        self.assignments = {}   # key -> target_name (растение/зомби/UI)

        self._build_ui()
        self._refresh_list()
        self._refresh_targets()

    # ================= UI =================
    def _build_ui(self):
        # --- ЛЕВАЯ: список анимаций ---
        left = tk.Frame(self.root, bg="#2b2b2b")
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=8, pady=8)

        tk.Label(left, text="Анимации (GIF)", bg="#2b2b2b", fg="white",
                 font=("Arial", 14, "bold")).pack(anchor="w")

        top = tk.Frame(left, bg="#2b2b2b")
        top.pack(fill=tk.X)
        tk.Label(top, text="Фильтр:", bg="#2b2b2b", fg="white").pack(side=tk.LEFT)
        tk.Entry(top, textvariable=self.filter_text).pack(side=tk.LEFT, fill=tk.X,
                                                          expand=True, padx=4)
        self.filter_text.trace("w", lambda *a: self._refresh_list())
        tk.Button(top, text="Сброс", command=lambda: self.filter_text.set("")).pack(side=tk.LEFT)

        # Canvas + Scrollbar
        cf = tk.Frame(left, bg="#2b2b2b")
        cf.pack(fill=tk.BOTH, expand=True, pady=4)
        self.canvas = tk.Canvas(cf, bg="#1e1e1e", highlightthickness=0)
        sb = tk.Scrollbar(cf, orient="vertical", command=self.canvas.yview)
        self.canvas.configure(yscrollcommand=sb.set)
        sb.pack(side=tk.RIGHT, fill=tk.Y)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.inner = tk.Frame(self.canvas, bg="#1e1e1e")
        self.canvas.create_window((0, 0), window=self.inner, anchor="nw")
        self.inner.bind("<Configure>",
                        lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")))

        # --- ПРАВАЯ: список целей ---
        right = tk.Frame(self.root, bg="#3a3a3a", width=320)
        right.pack(side=tk.RIGHT, fill=tk.Y, padx=8, pady=8)
        right.pack_propagate(False)

        tk.Label(right, text="Цели привязки", bg="#3a3a3a", fg="white",
                 font=("Arial", 14, "bold")).pack(anchor="w")
        tk.Entry(right, textvariable=self.target_filter,
                 bg="#1e1e1e", fg="white").pack(fill=tk.X, pady=4)
        self.target_filter.trace("w", lambda *a: self._refresh_targets())

        # Notebook с вкладками
        self.nb = ttk.Notebook(right)
        self.nb.pack(fill=tk.BOTH, expand=True)
        self.tabs = {}
        for group_name in ALL_TARGETS:
            frame = tk.Frame(self.nb, bg="#2b2b2b")
            self.nb.add(frame, text=group_name)
            self.tabs[group_name] = frame

        # --- НИЖНЯЯ: кнопки ---
        bottom = tk.Frame(self.root, bg="#2b2b2b")
        bottom.pack(side=tk.BOTTOM, fill=tk.X, padx=8, pady=8)

        tk.Button(bottom, text="💾 Сохранить (S)", command=self.save,
                  bg="#2d6a2d", fg="white", font=("Arial", 11, "bold")).pack(side=tk.LEFT)
        tk.Button(bottom, text="➕ Добавить GIF (A)", command=self.add_gif,
                  bg="#2d4a6a", fg="white", font=("Arial", 11, "bold")).pack(side=tk.LEFT, padx=6)
        tk.Button(bottom, text="❌ Удалить (Del)", command=self.delete_selected,
                  bg="#6a2d2d", fg="white", font=("Arial", 11, "bold")).pack(side=tk.LEFT, padx=6)
        tk.Button(bottom, text="🔄 Пересканировать", command=self.rescan,
                  bg="#4a4a2d", fg="white", font=("Arial", 11, "bold")).pack(side=tk.LEFT, padx=6)
        tk.Button(bottom, text="🗑 Очистить привязку", command=self.clear_assignment,
                  bg="#5a2d5a", fg="white", font=("Arial", 11, "bold")).pack(side=tk.LEFT, padx=6)

        self.status = tk.Label(bottom, text="Готов", bg="#2b2b2b", fg="#0f0")
        self.status.pack(side=tk.RIGHT)

        # Хоткеи
        self.root.bind("<Delete>", lambda e: self.delete_selected())
        self.root.bind("<s>", lambda e: self.save())
        self.root.bind("<a>", lambda e: self.add_gif())
        self.root.bind("<Escape>", lambda e: self._on_close())
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)

    # ================= список анимаций =================
    def _refresh_list(self):
        for w in self.inner.winfo_children():
            w.destroy()
        self.cards.clear()
        self.photo_cache.clear()

        flt = self.filter_text.get().lower()
        keys = sorted(self.data.keys())
        shown = 0
        for key in keys:
            if flt and flt not in key.lower():
                continue
            self._make_card(shown, key)
            shown += 1

        if shown == 0:
            tk.Label(self.inner, text="Ничего не найдено",
                     bg="#1e1e1e", fg="#888",
                     font=("Arial", 12)).grid(row=0, column=0, padx=20, pady=20)

    def _make_card(self, i, key):
        card = tk.Frame(self.inner, bg="#2b2b2b", bd=1, relief="solid",
                        width=self.THUMB + 20, height=self.CARD_H)
        card.grid(row=i // 7, column=i % 7, padx=6, pady=6)
        card.grid_propagate(False)

        # Превью
        thumb = first_frame_path(key)
        if thumb and os.path.exists(thumb):
            try:
                pil = Image.open(thumb).convert("RGBA")
                pil.thumbnail((self.THUMB, self.THUMB))
                photo = ImageTk.PhotoImage(pil)
                lbl = tk.Label(card, image=photo, bg="#2b2b2b")
                lbl.image = photo
                lbl.pack(pady=4)
                self.photo_cache[key] = photo
            except Exception:
                tk.Label(card, text="ERR", bg="#2b2b2b", fg="red").pack(pady=4)
        else:
            tk.Label(card, text="нет\nкадров", bg="#2b2b2b", fg="#888",
                     font=("Arial", 9)).pack(pady=4)

        # Имя
        name = os.path.basename(key)
        lbl_name = tk.Label(card, text=name[:20], bg="#2b2b2b", fg="white",
                            font=("Arial", 8), wraplength=self.THUMB + 10)
        lbl_name.pack()

        # Метка цели
        target = self.assignments.get(key)
        if target:
            lbl_t = tk.Label(card, text=f"→ {target}", bg="#2b2b2b", fg="#6c6",
                             font=("Arial", 8, "italic"))
            lbl_t.pack()

        # Клик — выбрать
        for w in (card, lbl_name):
            w.bind("<Button-1>", lambda e, k=key, c=card: self._select(k, c))

        # Настоящий drag & drop — если tkinterdnd2 установлен
        if HAS_DND:
            for w in (card, lbl, lbl_name):
                try:
                    w.drag_source_register(1, DND_FILES)
                    w.dnd_bind("<<DragInitCmd>>",
                               lambda e, k=key: (e.widget, k) and None)
                except Exception:
                    pass

        self.cards[key] = card

    def _select(self, key, card):
        if self.selected_key and self.selected_key in self.cards:
            self.cards[self.selected_key].config(bg="#2b2b2b")
            for w in self.cards[self.selected_key].winfo_children():
                w.config(bg="#2b2b2b")
        self.selected_key = key
        card.config(bg="#6a6a2d")
        for w in card.winfo_children():
            w.config(bg="#6a6a2d")
        self.status.config(text=f"Выбрано: {key}", fg="#0f0")

    # ================= список целей =================
    def _refresh_targets(self):
        flt = self.target_filter.get().lower()
        for group, frame in self.tabs.items():
            for w in frame.winfo_children():
                w.destroy()
            targets = ALL_TARGETS[group]
            for t in targets:
                if flt and flt not in t.lower():
                    continue
                btn = tk.Button(frame, text=t, anchor="w",
                                bg="#4a4a4a", fg="white",
                                activebackground="#6a6a2d",
                                command=lambda tt=t: self._assign(tt))
                btn.pack(fill=tk.X, padx=4, pady=2)
                # Принимаем drop
                if HAS_DND:
                    try:
                        btn.drop_target_register(DND_FILES)
                        btn.dnd_bind("<<Drop>>",
                                     lambda e, tt=t: self._assign(tt))
                    except Exception:
                        pass

    def _assign(self, target):
        if not self.selected_key:
            self.status.config(text="Сначала выбери анимацию", fg="#f80")
            return
        self.assignments[self.selected_key] = target
        self.dirty = True
        self._refresh_list()
        self.status.config(text=f"'{self.selected_key}' → {target}", fg="#0f0")

    def clear_assignment(self):
        if not self.selected_key:
            return
        if self.selected_key in self.assignments:
            del self.assignments[self.selected_key]
            self.dirty = True
            self._refresh_list()
            self.status.config(text="Привязка очищена", fg="#f80")

    # ================= операции =================
    def save(self):
        # Сохраняем привязки в отдельный файл
        assign_file = os.path.join(BASE_DIR, "assignments.json")
        with open(assign_file, "w", encoding="utf-8") as fp:
            json.dump(self.assignments, fp, indent=2, ensure_ascii=False)
        save_json(self.data)
        self.dirty = False
        self.status.config(text="Сохранено (animations.json + assignments.json)", fg="#0f0")

    def delete_selected(self):
        if not self.selected_key:
            self.status.config(text="Нечего удалять", fg="#f80")
            return
        key = self.selected_key
        if not messagebox.askyesno("Удалить", f"Удалить '{key}' из animations.json?\n"
                                              "(папка _frames останется на диске)"):
            return
        del self.data[key]
        self.assignments.pop(key, None)
        self.selected_key = None
        self.dirty = True
        self._refresh_list()
        self.status.config(text=f"Удалено: {key}", fg="#f80")

    def add_gif(self):
        path = filedialog.askopenfilename(
            title="Выбери GIF",
            filetypes=[("GIF", "*.gif"), ("Все файлы", "*.*")],
            initialdir=IMG_DIR,
        )
        if not path:
            return
        if not path.lower().endswith(".gif"):
            messagebox.showerror("Ошибка", "Только .gif")
            return
        rel = os.path.relpath(path, BASE_DIR).replace("\\", "/")
        try:
            folder = os.path.dirname(path)
            base = os.path.splitext(os.path.basename(path))[0]
            out_folder = os.path.join(folder, f"{base}_frames")
            os.makedirs(out_folder, exist_ok=True)
            frames = []
            with Image.open(path) as im:
                for i, frame in enumerate(ImageSequence.Iterator(im)):
                    rgba = frame.convert("RGBA")
                    name = f"frame_{i:03d}.png"
                    rgba.save(os.path.join(out_folder, name))
                    frames.append(name)
            self.data[rel] = frames
            self.dirty = True
            self._refresh_list()
            self.status.config(text=f"Добавлено: {rel} ({len(frames)} кадров)", fg="#0f0")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось: {e}")

    def rescan(self):
        if not messagebox.askyesno("Пересканировать",
                                   "Пройти по assets/images и добавить новые GIF?"):
            return
        try:
            count = 0
            for root, _, files in os.walk(IMG_DIR):
                for f in files:
                    if not f.lower().endswith(".gif"):
                        continue
                    gif_path = os.path.join(root, f)
                    rel = os.path.relpath(gif_path, BASE_DIR).replace("\\", "/")
                    if rel in self.data:
                        continue
                    folder = os.path.dirname(gif_path)
                    base = os.path.splitext(f)[0]
                    out_folder = os.path.join(folder, f"{base}_frames")
                    os.makedirs(out_folder, exist_ok=True)
                    frames = []
                    with Image.open(gif_path) as im:
                        for i, frame in enumerate(ImageSequence.Iterator(im)):
                            rgba = frame.convert("RGBA")
                            name = f"frame_{i:03d}.png"
                            rgba.save(os.path.join(out_folder, name))
                            frames.append(name)
                    self.data[rel] = frames
                    count += 1
            self.dirty = True
            self._refresh_list()
            self.status.config(text=f"Найдено новых: {count}", fg="#0f0")
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def _on_close(self):
        if self.dirty:
            if not messagebox.askyesno("Выход", "Есть несохранённые изменения. Выйти?"):
                return
        self.root.destroy()


def main():
    if HAS_DND:
        root = TkinterDnD.Tk()
    else:
        root = tk.Tk()
    AnimEditor(root)
    root.mainloop()


if __name__ == "__main__":
    main()
{
  "assets/images/interface/0.gif": [
    "frame_000.png"
  ],
  "assets/images/interface/Dave.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/interface/Dave2.gif": [
    "frame_000.png"
  ],
  "assets/images/interface/Dave3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/interface/FinalWave.gif": [
    "frame_000.png"
  ],
  "assets/images/interface/GrowSoil.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/interface/GrowSpray.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/interface/LargeWave.gif": [
    "frame_000.png"
  ],
  "assets/images/interface/PointerDown.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/interface/PointerUP.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/interface/Sun.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/interface/yicixingxiaofei.gif": [
    "frame_000.png"
  ],
  "assets/images/interface/Shovel/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/BackupDancer/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/BackupDancer/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png"
  ],
  "assets/images/Zombies/BackupDancer/BackupDancer.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/BackupDancer/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/BackupDancer/Dancing.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/BackupDancer/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png"
  ],
  "assets/images/Zombies/BackupDancer/Head.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/BackupDancer/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/BackupDancer/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png"
  ],
  "assets/images/Zombies/BackupDancer/LostHeadDancing.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/BackupDancer/Mound.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/BalloonZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/BalloonZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/BalloonZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/BalloonZombie/Attack2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/BalloonZombie/Boom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/BalloonZombie/Boom2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/BalloonZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/BalloonZombie/Drop.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/BalloonZombie/Head.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/BalloonZombie/Walk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png"
  ],
  "assets/images/Zombies/BalloonZombie/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png"
  ],
  "assets/images/Zombies/BucketheadZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/BucketheadZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/BucketheadZombie/BucketheadZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/BucketheadZombie/BucketheadZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/ConeheadZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/ConeheadZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/ConeheadZombie/ConeheadZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/ConeheadZombie/ConeheadZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/CX/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/CX/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/CX/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/CX/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/CX/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/CX/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Zombies/CX/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/CX/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/DancingZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/DancingZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/DancingZombie/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/DancingZombie/Dancing.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/DancingZombie/DancingZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/DancingZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png"
  ],
  "assets/images/Zombies/DancingZombie/Head.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/DancingZombie/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/DancingZombie/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/DancingZombie/LostHeadDancing.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/DancingZombie/LostHeadSlidingStep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png"
  ],
  "assets/images/Zombies/DancingZombie/LostHeadSummon.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/DancingZombie/SlidingStep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png"
  ],
  "assets/images/Zombies/DancingZombie/Summon1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/DancingZombie/Summon2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png"
  ],
  "assets/images/Zombies/DancingZombie/Summon3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Die2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Head.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Jump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Jump2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Jump3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Walk3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png"
  ],
  "assets/images/Zombies/DolphinRiderZombie/Walk4.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie1/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie2/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie2/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie2/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie3/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie3/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie3/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie4/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie4/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/DuckyTubeZombie4/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png"
  ],
  "assets/images/Zombies/FlagZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/FlagZombie/FlagZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/FlagZombie/FlagZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/FlagZombie/FlagZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/FlagZombie/FlagZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/FootballZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/FootballZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/FootballZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/FootballZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png"
  ],
  "assets/images/Zombies/FootballZombie/FootballZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/FootballZombie/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/FootballZombie/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/FootballZombie/OrnLost.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/FootballZombie/OrnLostAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/FootballZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/FootballZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/FootballZombieOrnLost.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/FootballZombieOrnLostAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/OrnLost.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/HeiFootballZombie/OrnLostAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/Imp/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Imp/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Imp/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/Imp/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png"
  ],
  "assets/images/Zombies/Imp/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Zombies/Imp/ZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Imp/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/Imp/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/Boom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/OpenBox.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/JackinTheBoxZombie/Walk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/JX/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JX/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Zombies/JX/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/JX/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/JX/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/JX/ZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JX/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/JX/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/JY/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JY/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/JY/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/JY/Attack2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/JY/Boom.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JY/Boom2.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/JY/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/JY/Drop.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/JY/Head.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/JY/Walk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/JY/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/LGBOSS/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/LGBOSS/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/LGBOSS/2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/LGBOSS/3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/LGBOSS/5.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/LGBOSS/BoomDie.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/LionDanceZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/LionDanceZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ConeheadZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ConeheadZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/LionDanceZombie/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/LionDanceZombie/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/MustacheZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/MustacheZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/MustacheZombie/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/MustacheZombie/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/NewspaperZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/NewspaperZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/NewspaperZombie/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/NewspaperZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/NewspaperZombie/Head.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/NewspaperZombie/HeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png"
  ],
  "assets/images/Zombies/NewspaperZombie/HeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png"
  ],
  "assets/images/Zombies/NewspaperZombie/HeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/NewspaperZombie/HeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/NewspaperZombie/LostHeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png"
  ],
  "assets/images/Zombies/NewspaperZombie/LostHeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png"
  ],
  "assets/images/Zombies/NewspaperZombie/LostHeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/NewspaperZombie/LostHeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/NewspaperZombie/LostNewspaper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/PB-10.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PB00.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PB01.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PB10.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/PeaBulletHit.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PeaBulletHit1.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PeaBulletHit2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Zombies/Plants/ShroomBullet.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/Plants/ShroomBulletHit.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/BigChomper/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/BigChomper/Chomper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/BigChomper/ChomperAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/BigChomper/ChomperDigest.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/Cactus/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Attack2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Cactus.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Cactus2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Elongation.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Cactus/Shorten.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/CherryBomb/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/CherryBomb/Boom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/CherryBomb/CherryBomb.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/Plants/Chomper/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Chomper/Chomper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Chomper/ChomperAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Chomper/ChomperDigest.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/CoffeeBean/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/CoffeeBean/CoffeeBean.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/Plants/CoffeeBean/CoffeeBeanEat.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/Plants/DoomShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/DoomShroom/BeginBoom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Zombies/Plants/DoomShroom/DoomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/DoomShroom/Sleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/FlamesMushroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FlamesMushroom/FlamesMushroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/FlamesMushroom/FlamesMushroom1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/FlamesMushroom/FlamesMushroom2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/FlowerPot/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FlowerPot/FlowerPot.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/FlowerPot/C/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FlowerPot/C/CFlowerPot.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/FumeShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FumeShroom/FumeShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/FumeShroom/FumeShroomAttack.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FumeShroom/FumeShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/FumeShroom/FumeShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/Garlic/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Garlic/Garlic.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Garlic/Garlic_body2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Garlic/Garlic_body3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/GatlingPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/GatlingPea/GatlingPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/GloomShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/GloomShroom/GloomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/Plants/GloomShroom/GloomShroomAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/GloomShroom/GloomShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/GloomShroom/GloomShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/Plants/GraveBuster/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/GraveBuster/GraveBuster.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/Plants/gun/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/gun/SeaShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/Plants/gun/SeaShroomSleep.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/gun/ShroomBullet.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Zombies/Plants/gun/ShroomBulletHit.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Zombies/Plants/HypnoShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/HypnoShroom/HypnoShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/HypnoShroom/HypnoShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/IceShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/IceShroom/IceShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/IceShroom/IceShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/IceShroom/icetrap.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/IceShroom/Snow.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Jalapeno/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Jalapeno/Jalapeno.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/Jalapeno/JalapenoAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/LaserPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/LaserPea/LaserPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/LaserPea/LaserPeaAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/Plants/LaserPea/LaserPeaBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/LilyPad/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/LilyPad/LilyPad.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Ling/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Ling/Ling.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/Plants/LotusRoot/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/LotusRoot/Peashooter.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/Plants/MagneticmuShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/MagneticmuShroom/Shrubbery.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/Plants/MagneticmuShroom/ShrubberyBoom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png"
  ],
  "assets/images/Zombies/Plants/Oxygen/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Oxygen/Oxygen.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/Oxygen/Oxygen1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Peashooter/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Peashooter/Peashooter.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Plantern/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Plantern/Plantern.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/PotatoMine/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PotatoMine/ExplosionSpudow.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PotatoMine/PotatoMine.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/Plants/PotatoMine/PotatoMineNotReady.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PotatoMine/PotatoMine_mashed.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PuffShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PuffShroom/PuffShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/PuffShroom/PuffShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/PumpkinHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/PumpkinHead1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/PumpkinHead2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/Pumpkin_back.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/pumpkin_damage1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/PumpkinHead/Pumpkin_damage2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/Repeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Repeater/Repeater.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/ScaredyShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/ScaredyShroom/ScaredyShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/ScaredyShroom/ScaredyShroomCry.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/Plants/ScaredyShroom/ScaredyShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/SeaAnemone/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SeaAnemone/GloomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/Plants/SeaAnemone/GloomShroomAttack.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SeaAnemone/GloomShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SeaAnemone/GloomShroomSleep.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SeaShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SeaShroom/SeaShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/SeaShroom/SeaShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/SnowPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SnowPea/SnowPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/SnowRepeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SnowRepeater/SnowPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Spikerock/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Spikerock/2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Spikerock/3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Spikerock/Spikerock.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Plants/Spikeweed/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Spikeweed/Spikeweed.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/SplitPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SplitPea/SplitPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/Plants/Squash/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Squash/Squash.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/Plants/Squash/SquashAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/Plants/star/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/star/starRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/Starfruit/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Starfruit/Star.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Starfruit/Starfruit.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/SunFlower/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SunFlower/SunFlower1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/SunShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/SunShroom/SunShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/Plants/SunShroom/SunShroom2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/Plants/SunShroom/SunShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/Plants/TallNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/TallNut/TallNut.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/TallNut/TallnutCracked1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/TallNut/TallnutCracked2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/TangleKlep/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/TangleKlep/Float.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Zombies/Plants/TenManNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/TenManNut/Spikeweed.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/Threepeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Threepeater/Threepeater.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Plants/Torchwood/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/Torchwood/Torchwood.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/Plants/TTS/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/TTS/Float.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/Plants/TwinSunflower/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/TwinSunflower/TwinSunflower.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/TwinSunflower/TwinSunflower1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/Plants/WallNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/WallNut/1.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/WallNut/2.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Plants/WallNut/BoomWallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/Plants/WallNut/HugeWallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/Plants/WallNut/WallNut.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/WallNut/WallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Plants/WallNut/Wallnut_cracked1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/Plants/WallNut/Wallnut_cracked2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieJump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieJump2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieLostHeadWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png"
  ],
  "assets/images/Zombies/PoleVaultingZombie/PoleVaultingZombieWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/HeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/HeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/LostHeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/LostHeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/ScreenDoorZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/ScreenDoorZombie/ScreenDoorZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/SnorkelZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/SnorkelZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Head.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Jump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Risk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Sink.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png"
  ],
  "assets/images/Zombies/SnorkelZombie/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/SubZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/SubZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/SubZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/SubZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/SubZombie/Head.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/SubZombie/Jump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/SubZombie/Risk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/SubZombie/Sink.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Zombies/SubZombie/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/SubZombie/Walk2.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/TrashZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/TrashZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/TrashZombie/HeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/TrashZombie/HeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/TrashZombie/LostHeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/TrashZombie/LostHeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/TrashZombie/ScreenDoorZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/TrashZombie/ScreenDoorZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/wall/BucketheadZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/BucketheadZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/wall/BucketheadZombie/BucketheadZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/wall/BucketheadZombie/BucketheadZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/wall/ConeheadZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ConeheadZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/wall/ConeheadZombie/ConeheadZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/wall/ConeheadZombie/ConeheadZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/wall/Emperor/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/Emperor/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/wall/Emperor/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/wall/Emperor/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/Emperor/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/wall/Emperor/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Zombies/wall/Emperor/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/EunZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/EunZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png"
  ],
  "assets/images/Zombies/wall/EunZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/wall/EunZombie/Head.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/EunZombie/HeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/wall/EunZombie/HeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/wall/EunZombie/HeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/wall/EunZombie/HeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/wall/EunZombie/LostHeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/wall/EunZombie/LostHeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/wall/EunZombie/LostHeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/wall/EunZombie/LostHeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/wall/EunZombie/LostNewspaper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/FootballZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/LostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/LostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/OrnLost.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/wall/FootballZombie/OrnLostAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieJump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieJump2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieLostHeadWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png"
  ],
  "assets/images/Zombies/wall/PoleVaultingZombie/PoleVaultingZombieWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png"
  ],
  "assets/images/Zombies/wall/thugZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/thugZombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieJump.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieJump2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieLostHeadWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/wall/thugZombie/PoleVaultingZombieWalk.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/wall/Zombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/Zombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Zombies/wall/Zombie/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/wall/Zombie/Zombie2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/wall/Zombie/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/wall/Zombie/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png"
  ],
  "assets/images/Zombies/wall/Zombie/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/wall/Zombie/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/wall/Zombie/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/wall/Zomboni/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/Zomboni/2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/Zomboni/3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/wall/Zomboni/4.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/wall/Zomboni/5.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png"
  ],
  "assets/images/Zombies/wall/Zomboni/BoomDie.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ZZ/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ZZ/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png"
  ],
  "assets/images/Zombies/wall/ZZ/Zombie.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ZZ/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/wall/ZZ/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png"
  ],
  "assets/images/Zombies/wall/ZZ/ZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ZZ/ZombieLostHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/wall/ZZ/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/WarshipsZombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WarshipsZombie/1.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WarshipsZombie/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/WarshipsZombie/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/WarshipsZombie/Walk1.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WarshipsZombie/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/WarshipsZombie/ZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WJY/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WJY/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/WJY/BoomDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Zombies/WJY/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png"
  ],
  "assets/images/Zombies/WJY/Head.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WJY/HeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/WJY/HeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/WJY/HeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/WJY/HeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/WJY/LostHeadAttack0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/WJY/LostHeadAttack1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/WJY/LostHeadWalk0.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Zombies/WJY/LostHeadWalk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/WJY/LostNewspaper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Zombies/WJY/water/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WJY/water/1.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/WJY/water/Attack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/WJY/water/Die.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Zombies/WJY/water/Walk1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/WJY/water/Walk2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/WJY/water/ZombieHead.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/XB/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/XB/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Zombies/XB/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/XB/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/XB/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Zombies/XB/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Zombies/XB/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Zombies/XB/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Zombie/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Zombie/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Zombies/Zombie/Zombie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/Zombie/ZombieAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/Zombie/ZombieDie.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png"
  ],
  "assets/images/Zombies/Zombie/ZombieHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Zombies/Zombie/ZombieLostHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png",
    "frame_040.png",
    "frame_041.png",
    "frame_042.png",
    "frame_043.png",
    "frame_044.png",
    "frame_045.png",
    "frame_046.png"
  ],
  "assets/images/Zombies/Zombie/ZombieLostHeadAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Zombies/Zomboni/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Zombies/Zomboni/1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Zomboni/2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Zomboni/3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Zombies/Zomboni/4.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Zombies/Zomboni/5.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Zombies/Zomboni/BoomDie.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PB-10.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PB00.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PB01.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PB10.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/PeaBulletHit.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PeaBulletHit1.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PeaBulletHit2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Plants/ShroomBullet.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Plants/ShroomBulletHit.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/BigChomper/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/BigChomper/Chomper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/BigChomper/ChomperAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/BigChomper/ChomperDigest.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/Cactus/Attack2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Plants/Cactus/Cactus.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Cactus/Cactus2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Cactus/Elongation.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Cactus/Shorten.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/CherryBomb/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/CherryBomb/Boom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/CherryBomb/CherryBomb.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Plants/Chomper/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Chomper/Chomper.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/Chomper/ChomperAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/Chomper/ChomperDigest.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/CoffeeBean/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/CoffeeBean/CoffeeBean.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Plants/CoffeeBean/CoffeeBeanEat.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Plants/DoomShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/DoomShroom/BeginBoom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Plants/DoomShroom/DoomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/DoomShroom/Sleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/FlamesMushroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FlamesMushroom/FlamesMushroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/FlamesMushroom/FlamesMushroom1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/FlamesMushroom/FlamesMushroom2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/FlowerPot/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FlowerPot/FlowerPot.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/FlowerPot/C/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FlowerPot/C/CFlowerPot.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/FumeShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FumeShroom/FumeShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/FumeShroom/FumeShroomAttack.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FumeShroom/FumeShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/FumeShroom/FumeShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/Garlic/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Garlic/Garlic.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Garlic/Garlic_body2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Garlic/Garlic_body3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/GatlingPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/GatlingPea/GatlingPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/GloomShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/GloomShroom/GloomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Plants/GloomShroom/GloomShroomAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/GloomShroom/GloomShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/GloomShroom/GloomShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Plants/GraveBuster/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/GraveBuster/GraveBuster.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png"
  ],
  "assets/images/Plants/gun/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/gun/SeaShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Plants/gun/SeaShroomSleep.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/gun/ShroomBullet.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Plants/gun/ShroomBulletHit.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Plants/HypnoShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/HypnoShroom/HypnoShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/HypnoShroom/HypnoShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/IceShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/IceShroom/IceShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/IceShroom/IceShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/IceShroom/icetrap.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/IceShroom/Snow.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Jalapeno/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Jalapeno/Jalapeno.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/Jalapeno/JalapenoAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/LaserPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/LaserPea/LaserPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/LaserPea/LaserPeaAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png",
    "frame_035.png",
    "frame_036.png",
    "frame_037.png",
    "frame_038.png",
    "frame_039.png"
  ],
  "assets/images/Plants/LaserPea/LaserPeaBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/LilyPad/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/LilyPad/LilyPad.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Ling/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Ling/Ling.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Plants/LotusRoot/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/LotusRoot/Peashooter.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png"
  ],
  "assets/images/Plants/MagneticmuShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/MagneticmuShroom/Shrubbery.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Plants/MagneticmuShroom/ShrubberyBoom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png",
    "frame_029.png",
    "frame_030.png",
    "frame_031.png",
    "frame_032.png",
    "frame_033.png",
    "frame_034.png"
  ],
  "assets/images/Plants/Oxygen/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Oxygen/Oxygen.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/Oxygen/Oxygen1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/Plantern/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Plantern/Plantern.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/PotatoMine/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PotatoMine/ExplosionSpudow.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PotatoMine/PotatoMine.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png"
  ],
  "assets/images/Plants/PotatoMine/PotatoMineNotReady.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PotatoMine/PotatoMine_mashed.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PuffShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PuffShroom/PuffShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/PuffShroom/PuffShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/PumpkinHead/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/PumpkinHead/PumpkinHead.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/PumpkinHead/PumpkinHead1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/PumpkinHead/PumpkinHead2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/PumpkinHead/Pumpkin_back.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/PumpkinHead/pumpkin_damage1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/PumpkinHead/Pumpkin_damage2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/Repeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Repeater/Repeater.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/ScaredyShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/ScaredyShroom/ScaredyShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/ScaredyShroom/ScaredyShroomCry.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Plants/ScaredyShroom/ScaredyShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/SeaAnemone/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SeaAnemone/GloomShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Plants/SeaAnemone/GloomShroomAttack.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SeaAnemone/GloomShroomBullet.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SeaAnemone/GloomShroomSleep.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SeaShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SeaShroom/SeaShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/SeaShroom/SeaShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/SnowPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SnowPea/SnowPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/SnowRepeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SnowRepeater/SnowPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/Spikerock/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Spikerock/2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Spikerock/3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Spikerock/Spikerock.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png"
  ],
  "assets/images/Plants/Spikeweed/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Spikeweed/Spikeweed.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/SplitPea/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SplitPea/SplitPea.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png"
  ],
  "assets/images/Plants/Squash/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Squash/Squash.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png"
  ],
  "assets/images/Plants/Squash/SquashAttack.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png"
  ],
  "assets/images/Plants/star/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/star/starRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/Starfruit/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Starfruit/Star.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Starfruit/Starfruit.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/SunShroom/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/SunShroom/SunShroom.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Plants/SunShroom/SunShroom2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png"
  ],
  "assets/images/Plants/SunShroom/SunShroomSleep.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png"
  ],
  "assets/images/Plants/TallNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/TallNut/TallNut.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/TallNut/TallnutCracked1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/TallNut/TallnutCracked2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/TangleKlep/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/TangleKlep/Float.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png"
  ],
  "assets/images/Plants/TenManNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/TenManNut/Spikeweed.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/Threepeater/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Threepeater/Threepeater.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png"
  ],
  "assets/images/Plants/Torchwood/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/Torchwood/Torchwood.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png"
  ],
  "assets/images/Plants/TTS/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/TTS/Float.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png"
  ],
  "assets/images/Plants/TwinSunflower/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/TwinSunflower/TwinSunflower.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/TwinSunflower/TwinSunflower1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png"
  ],
  "assets/images/Plants/WallNut/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/WallNut/1.gif": [
    "frame_000.png"
  ],
  "assets/images/Plants/WallNut/BoomWallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Plants/WallNut/HugeWallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png"
  ],
  "assets/images/Plants/WallNut/WallNut.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/WallNut/WallNutRoll.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Plants/WallNut/Wallnut_cracked1.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Plants/WallNut/Wallnut_cracked2.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Interface/0.gif": [
    "frame_000.png"
  ],
  "assets/images/Interface/Dave.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png"
  ],
  "assets/images/Interface/Dave2.gif": [
    "frame_000.png"
  ],
  "assets/images/Interface/Dave3.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png"
  ],
  "assets/images/Interface/FinalWave.gif": [
    "frame_000.png"
  ],
  "assets/images/Interface/GrowSoil.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png"
  ],
  "assets/images/Interface/GrowSpray.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png"
  ],
  "assets/images/Interface/LargeWave.gif": [
    "frame_000.png"
  ],
  "assets/images/Interface/PointerDown.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Interface/PointerUP.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png"
  ],
  "assets/images/Interface/Sun.gif": [
    "frame_000.png",
    "frame_001.png",
    "frame_002.png",
    "frame_003.png",
    "frame_004.png",
    "frame_005.png",
    "frame_006.png",
    "frame_007.png",
    "frame_008.png",
    "frame_009.png",
    "frame_010.png",
    "frame_011.png",
    "frame_012.png",
    "frame_013.png",
    "frame_014.png",
    "frame_015.png",
    "frame_016.png",
    "frame_017.png",
    "frame_018.png",
    "frame_019.png",
    "frame_020.png",
    "frame_021.png",
    "frame_022.png",
    "frame_023.png",
    "frame_024.png",
    "frame_025.png",
    "frame_026.png",
    "frame_027.png",
    "frame_028.png"
  ],
  "assets/images/Interface/yicixingxiaofei.gif": [
    "frame_000.png"
  ],
  "assets/images/Interface/Shovel/0.gif": [
    "frame_000.png"
  ]
}
{
  "assets/images/Zombies/Plants/Peashooter/0.gif": "Peashooter",
  "assets/images/Zombies/Plants/Repeater/Repeater.gif": "Repeater",
  "assets/images/Zombies/Plants/SnowPea/0.gif": "SnowPea",
  "assets/images/Zombies/Plants/Threepeater/Threepeater.gif": "Threepeater",
  "assets/images/Zombies/Plants/GatlingPea/GatlingPea.gif": "GatlingPea",
  "assets/images/Plants/BigChomper/Chomper.gif": "BigChomper"
}
"""
Конвертер GIF -> PNG-секвенции для Pygame.
Запускать ОДИН РАЗ: python convert_assets.py
Требует: pip install Pillow
"""
import os
import json
from PIL import Image, ImageSequence

BASE_DIR = r"C:\Users\Ярослав\OneDrive\Desktop\PvZ-Edgewalk"
CACHE_FILE = os.path.join(BASE_DIR, "animations.json")

# Папки, которые сканируем (все GIF в них и подпапках)
SEARCH_DIRS = [
    os.path.join(BASE_DIR, "assets", "images", "Plants"),
    os.path.join(BASE_DIR, "assets", "images", "Zombies"),
    os.path.join(BASE_DIR, "assets", "images", "interface"),
    os.path.join(BASE_DIR, "assets", "images", "Interface"),
    os.path.join(BASE_DIR, "assets", "images", "Card"),
]


def convert_gif(gif_path):
    """Раскладывает GIF на PNG-кадры рядом с исходником."""
    folder = os.path.dirname(gif_path)
    base = os.path.splitext(os.path.basename(gif_path))[0]
    out_folder = os.path.join(folder, f"{base}_frames")
    os.makedirs(out_folder, exist_ok=True)
    frames = []
    try:
        with Image.open(gif_path) as im:
            for i, frame in enumerate(ImageSequence.Iterator(im)):
                rgba = frame.convert("RGBA")
                name = f"frame_{i:03d}.png"
                rgba.save(os.path.join(out_folder, name))
                frames.append(name)
    except Exception as e:
        print(f"[!] Ошибка {gif_path}: {e}")
    return frames


def main():
    # Если JSON уже есть — загружаем его, чтобы НЕ терять старые записи
    animations = {}
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r", encoding="utf-8") as fp:
                animations = json.load(fp)
            print(f"[i] Загружено старых записей: {len(animations)}")
        except Exception as e:
            print(f"[!] Не удалось прочитать старый JSON: {e}")
            animations = {}

    count_new = 0
    count_updated = 0

    for img_dir in SEARCH_DIRS:
        if not os.path.isdir(img_dir):
            print(f"[i] Папка не найдена, пропускаю: {img_dir}")
            continue

        print(f"\n[i] Сканирую: {img_dir}")
        for root, _, files in os.walk(img_dir):
            for f in files:
                if not f.lower().endswith(".gif"):
                    continue
                gif_path = os.path.join(root, f)
                rel = os.path.relpath(gif_path, BASE_DIR).replace("\\", "/")

                # Уже есть в JSON и папка с кадрами существует? Пропускаем.
                frames_dir_name = os.path.splitext(os.path.basename(gif_path))[0] + "_frames"
                frames_dir = os.path.join(root, frames_dir_name)
                if rel in animations and os.path.isdir(frames_dir):
                    continue

                frames = convert_gif(gif_path)
                if frames:
                    if rel in animations:
                        count_updated += 1
                    else:
                        count_new += 1
                    animations[rel] = frames
                    print(f"[+] {rel} -> {len(frames)} кадров")

    # Сохраняем объединённый JSON
    with open(CACHE_FILE, "w", encoding="utf-8") as fp:
        json.dump(animations, fp, indent=2, ensure_ascii=False)

    print(f"\nГотово!")
    print(f"  Новых: {count_new}")
    print(f"  Обновлено: {count_updated}")
    print(f"  Всего в JSON: {len(animations)}")
    print(f"Кэш: {CACHE_FILE}")


if __name__ == "__main__":
    main()
{
  "items": {
    "H": { "name": "Водород (H)", "color": [255, 255, 255] },
    "He": { "name": "Гелий (He)", "color": [217, 255, 255] },
    "Li": { "name": "Литий (Li)", "color": [204, 128, 255] },
    "Be": { "name": "Бериллий (Be)", "color": [194, 255, 0] },
    "B": { "name": "Бор (B)", "color": [255, 181, 181] },
    "C": { "name": "Углерод (C)", "color": [144, 144, 144] },
    "N": { "name": "Азот (N)", "color": [48, 80, 248] },
    "O": { "name": "Кислород (O)", "color": [255, 13, 13] },
    "F": { "name": "Фтор (F)", "color": [144, 224, 80] },
    "Ne": { "name": "Неон (Ne)", "color": [179, 227, 245] },
    "Na": { "name": "Натрий (Na)", "color": [171, 92, 242] },
    "Mg": { "name": "Магний (Mg)", "color": [138, 255, 0] },
    "Al": { "name": "Алюминий (Al)", "color": [191, 166, 166] },
    "Si": { "name": "Кремний (Si)", "color": [240, 200, 160] },
    "P": { "name": "Фосфор (P)", "color": [255, 128, 0] },
    "S": { "name": "Сера (S)", "color": [255, 255, 48] },
    "Cl": { "name": "Хлор (Cl)", "color": [31, 240, 31] },
    "Ar": { "name": "Аргон (Ar)", "color": [128, 209, 227] },
    "K": { "name": "Калий (K)", "color": [143, 64, 212] },
    "Ca": { "name": "Кальций (Ca)", "color": [61, 255, 0] },
    "Sc": { "name": "Скандий (Sc)", "color": [230, 230, 230] },
    "Ti": { "name": "Титан (Ti)", "color": [191, 194, 199] },
    "V": { "name": "Ванадий (V)", "color": [166, 166, 171] },
    "Cr": { "name": "Хром (Cr)", "color": [138, 153, 199] },
    "Mn": { "name": "Марганец (Mn)", "color": [156, 122, 199] },
    "Fe": { "name": "Железо (Fe)", "color": [224, 102, 51] },
    "Co": { "name": "Кобальт (Co)", "color": [24, 120, 208] },
    "Ni": { "name": "Никель (Ni)", "color": [80, 208, 80] },
    "Cu": { "name": "Медь (Cu)", "color": [200, 128, 51] },
    "Zn": { "name": "Цинк (Zn)", "color": [125, 128, 176] },
    "Ga": { "name": "Галлий (Ga)", "color": [194, 143, 143] },
    "Ge": { "name": "Германий (Ge)", "color": [102, 143, 143] },
    "As": { "name": "Мышьяк (As)", "color": [189, 128, 227] },
    "Se": { "name": "Селен (Se)", "color": [255, 161, 0] },
    "Br": { "name": "Бром (Br)", "color": [166, 41, 41] },
    "Kr": { "name": "Криптон (Kr)", "color": [92, 184, 209] },
    "Rb": { "name": "Рубидий (Rb)", "color": [112, 46, 176] },
    "Sr": { "name": "Стронций (Sr)", "color": [0, 255, 0] },
    "Y": { "name": "Иттрий (Y)", "color": [148, 255, 255] },
    "Zr": { "name": "Цирконий (Zr)", "color": [148, 224, 224] },
    "Nb": { "name": "Ниобий (Nb)", "color": [115, 194, 201] },
    "Mo": { "name": "Молибден (Mo)", "color": [84, 181, 181] },
    "Tc": { "name": "Технеций (Tc)", "color": [59, 158, 158] },
    "Ru": { "name": "Рутений (Ru)", "color": [36, 143, 143] },
    "Rh": { "name": "Родий (Rh)", "color": [10, 125, 140] },
    "Pd": { "name": "Палладий (Pd)", "color": [0, 105, 133] },
    "Ag": { "name": "Серебро (Ag)", "color": [192, 192, 192] },
    "Cd": { "name": "Кадмий (Cd)", "color": [255, 217, 143] },
    "In": { "name": "Индий (In)", "color": [166, 117, 115] },
    "Sn": { "name": "Олово (Sn)", "color": [102, 128, 128] },
    "Sb": { "name": "Сурьма (Sb)", "color": [158, 99, 181] },
    "Te": { "name": "Теллур (Te)", "color": [212, 122, 0] },
    "I": { "name": "Иод (I)", "color": [148, 0, 148] },
    "Xe": { "name": "Ксенон (Xe)", "color": [66, 158, 176] },
    "Cs": { "name": "Цезий (Cs)", "color": [87, 23, 143] },
    "Ba": { "name": "Барий (Ba)", "color": [0, 201, 0] },
    "La": { "name": "Лантан (La)", "color": [112, 212, 255] },
    "Ce": { "name": "Церий (Ce)", "color": [255, 255, 199] },
    "Pr": { "name": "Празеодим (Pr)", "color": [217, 255, 199] },
    "Nd": { "name": "Неодим (Nd)", "color": [199, 255, 199] },
    "Pm": { "name": "Прометий (Pm)", "color": [163, 255, 199] },
    "Sm": { "name": "Самарий (Sm)", "color": [143, 255, 199] },
    "Eu": { "name": "Европий (Eu)", "color": [97, 255, 199] },
    "Gd": { "name": "Гадолиний (Gd)", "color": [69, 255, 199] },
    "Tb": { "name": "Тербий (Tb)", "color": [48, 255, 199] },
    "Dy": { "name": "Диспрозий (Dy)", "color": [31, 255, 199] },
    "Ho": { "name": "Гольмий (Ho)", "color": [0, 255, 156] },
    "Er": { "name": "Эрбий (Er)", "color": [0, 230, 117] },
    "Tm": { "name": "Тулий (Tm)", "color": [0, 212, 82] },
    "Yb": { "name": "Иттербий (Yb)", "color": [0, 191, 56] },
    "Lu": { "name": "Лютеций (Lu)", "color": [0, 171, 36] },
    "Hf": { "name": "Гафний (Hf)", "color": [77, 194, 255] },
    "Ta": { "name": "Тантал (Ta)", "color": [77, 166, 255] },
    "W": { "name": "Вольфрам (W)", "color": [33, 148, 214] },
    "Re": { "name": "Рений (Re)", "color": [38, 125, 171] },
    "Os": { "name": "Осмий (Os)", "color": [38, 102, 150] },
    "Ir": { "name": "Иридий (Ir)", "color": [23, 84, 135] },
    "Pt": { "name": "Платина (Pt)", "color": [208, 208, 224] },
    "Au": { "name": "Золото (Au)", "color": [255, 209, 35] },
    "Hg": { "name": "Ртуть (Hg)", "color": [184, 184, 208] },
    "Tl": { "name": "Таллий (Tl)", "color": [166, 84, 77] },
    "Pb": { "name": "Свинец (Pb)", "color": [87, 89, 97] },
    "Bi": { "name": "Висмут (Bi)", "color": [158, 79, 181] },
    "Po": { "name": "Полоний (Po)", "color": [171, 92, 0] },
    "At": { "name": "Астат (At)", "color": [117, 79, 69] },
    "Rn": { "name": "Радон (Rn)", "color": [66, 130, 150] },
    "Fr": { "name": "Франций (Fr)", "color": [66, 0, 102] },
    "Ra": { "name": "Радий (Ra)", "color": [0, 125, 0] },
    "Ac": { "name": "Актиний (Ac)", "color": [112, 171, 250] },
    "Th": { "name": "Торий (Th)", "color": [0, 186, 255] },
    "Pa": { "name": "Протактиний (Pa)", "color": [0, 161, 255] },
    "U": { "name": "Уран (U)", "color": [0, 143, 255] },
    "Np": { "name": "Нептуний (Np)", "color": [0, 128, 255] },
    "Pu": { "name": "Плутоний (Pu)", "color": [0, 107, 255] },
    "Am": { "name": "Америций (Am)", "color": [84, 92, 242] },
    "Cm": { "name": "Кюрий (Cm)", "color": [120, 92, 227] },
    "Bk": { "name": "Берклий (Bk)", "color": [138, 79, 227] },
    "Cf": { "name": "Калифорний (Cf)", "color": [161, 54, 212] },
    "Es": { "name": "Эйнштейний (Es)", "color": [179, 31, 212] },
    "Fm": { "name": "Фермий (Fm)", "color": [179, 31, 186] },
    "Md": { "name": "Менделевий (Md)", "color": [179, 13, 166] },
    "No": { "name": "Нобелий (No)", "color": [189, 13, 135] },
    "Lr": { "name": "Лоуренсий (Lr)", "color": [199, 0, 102] },
    "Rf": { "name": "Резерфордий (Rf)", "color": [204, 0, 89] },
    "Db": { "name": "Дубний (Db)", "color": [209, 0, 79] },
    "Sg": { "name": "Сиборгий (Sg)", "color": [217, 0, 69] },
    "Bh": { "name": "Борий (Bh)", "color": [224, 0, 56] },
    "Hs": { "name": "Хассий (Hs)", "color": [230, 0, 46] },
    "Mt": { "name": "Майтнерий (Mt)", "color": [235, 0, 38] },
    "Ds": { "name": "Дармштадтий (Ds)", "color": [235, 0, 38] },
    "Rg": { "name": "Рентгений (Rg)", "color": [235, 0, 38] },
    "Cn": { "name": "Коперниций (Cn)", "color": [235, 0, 38] },
    "Nh": { "name": "Нихоний (Nh)", "color": [235, 0, 38] },
    "Fl": { "name": "Флеровий (Fl)", "color": [235, 0, 38] },
    "Mc": { "name": "Московий (Mc)", "color": [235, 0, 38] },
    "Lv": { "name": "Ливерморий (Lv)", "color": [235, 0, 38] },
    "Ts": { "name": "Теннессин (Ts)", "color": [235, 0, 38] },
    "Og": { "name": "Оганесон (Og)", "color": [235, 0, 38] },

    "H2O": { "name": "Вода (H2O)", "color": [30, 144, 255] },
    "CO2": { "name": "Углекислый газ (CO2)", "color": [169, 169, 169] },
    "NaCl": { "name": "Соль (NaCl)", "color": [245, 245, 245] },
    "CH4": { "name": "Метан (CH4)", "color": [0, 250, 154] },
    "HCl": { "name": "Соляная кислота (HCl)", "color": [173, 255, 47] },
    "H2SO4": { "name": "Серная кислота (H2SO4)", "color": [255, 215, 0] },
    "SiO2": { "name": "Кварц/Песок (SiO2)", "color": [238, 214, 175] }
  },
  "recipes": [
    {
      "type": "shapeless",
      "ingredients": ["H", "H", "O"],
      "result": { "item": "H2O", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["C", "O", "O"],
      "result": { "item": "CO2", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["Na", "Cl"],
      "result": { "item": "NaCl", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["C", "H", "H", "H", "H"],
      "result": { "item": "CH4", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["H", "Cl"],
      "result": { "item": "HCl", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["H", "H", "S", "O", "O", "O", "O"],
      "result": { "item": "H2SO4", "count": 1 }
    },
    {
      "type": "shapeless",
      "ingredients": ["Si", "O", "O"],
      "result": { "item": "SiO2", "count": 1 }
    }
  ]
}
"""
Система крафта на Q.
Сетка 5×5 + слот результата + инвентарь 9×5 снизу.
Рецепты — в crafting.json (поддерживает shaped и shapeless).
Клик по результату — забрать.
Клик по элементу в инвентаре — выбрать.
Клик по слоту сетки — положить/вернуть.
"""
import os
import json
import pygame

from settings import (
    SCREEN_WIDTH, SCREEN_HEIGHT, WHITE, BLACK, YELLOW, GRAY, RED, GREEN, BASE_DIR
)

CRAFTING_FILE = os.path.join(BASE_DIR, "crafting.json")


def load_crafting():
    if not os.path.exists(CRAFTING_FILE):
        print(f"[!] {CRAFTING_FILE} не найден")
        return {"items": {}, "recipes": []}
    try:
        with open(CRAFTING_FILE, "r", encoding="utf-8") as fp:
            return json.load(fp)
    except Exception as e:
        print(f"[!] Ошибка crafting.json: {e}")
        return {"items": {}, "recipes": []}


class CraftingScreen:
    """Экран крафта. Открывается по Q."""
    GRID = 5            # 5×5 — влезет H2SO4 (7 атомов)
    SLOT = 60
    PAD = 4

    INV_COLS = 9
    INV_ROWS = 5

    def __init__(self, inventory=None):
        self.data = load_crafting()
        self.inventory = inventory if inventory is not None else {}
        self.craft_grid = [[None] * self.GRID for _ in range(self.GRID)]
        self.result = None
        self.selected = None
        self.message = ""
        self.message_timer = 0.0

        self.font = pygame.font.SysFont("Arial", 18, bold=True)
        self.small = pygame.font.SysFont("Arial", 11, bold=True)
        self.big = pygame.font.SysFont("Arial", 28, bold=True)
        self.sym_font = pygame.font.SysFont("Arial", 22, bold=True)

        # Прокрутка инвентаря
        self.inv_scroll = 0

    # ---------- Раскладка ----------
    def _grid_origin(self):
        gw = self.GRID * (self.SLOT + self.PAD) - self.PAD
        return (SCREEN_WIDTH // 2 - gw // 2 - 100, 100)

    def _result_rect(self):
        gx, gy = self._grid_origin()
        gw = self.GRID * (self.SLOT + self.PAD) - self.PAD
        x = gx + gw + 90
        y = gy + (self.GRID // 2) * (self.SLOT + self.PAD)
        return pygame.Rect(x, y, self.SLOT, self.SLOT)

    def _inv_origin(self):
        gw = self.INV_COLS * (self.SLOT + self.PAD) - self.PAD
        return (SCREEN_WIDTH // 2 - gw // 2, SCREEN_HEIGHT - 300)

    def _grid_slot_rect(self, r, c):
        gx, gy = self._grid_origin()
        return pygame.Rect(
            gx + c * (self.SLOT + self.PAD),
            gy + r * (self.SLOT + self.PAD),
            self.SLOT, self.SLOT
        )

    def _inv_slot_rect(self, i):
        iy, ix = divmod(i, self.INV_COLS)
        ox, oy = self._inv_origin()
        return pygame.Rect(
            ox + ix * (self.SLOT + self.PAD),
            oy + iy * (self.SLOT + self.PAD),
            self.SLOT, self.SLOT
        )

    # ---------- Рецепты ----------
    def _match_recipe(self):
        current_items = [item for row in self.craft_grid for item in row if item is not None]

        for recipe in self.data.get("recipes", []):
            rec_type = recipe.get("type", "shaped")

            if rec_type == "shapeless":
                ingredients = recipe.get("ingredients", [])
                if sorted(ingredients) == sorted(current_items):
                    return recipe
            else:
                pat = recipe.get("pattern")
                if self._pattern_matches(pat):
                    return recipe
        return None

    def _pattern_matches(self, pattern):
        if not pattern or len(pattern) != self.GRID:
            return False
        for r in range(self.GRID):
            if len(pattern[r]) != self.GRID:
                return False
            for c in range(self.GRID):
                need = pattern[r][c]
                have = self.craft_grid[r][c]
                if need is None and have is None:
                    continue
                if need != have:
                    return False
        return True

    def _recalc_result(self):
        rec = self._match_recipe()
        self.result = rec["result"] if rec else None

    # ---------- Ввод ----------
    def handle(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 4:
            self.inv_scroll = max(0, self.inv_scroll - 1)
            return
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 5:
            self.inv_scroll += 1
            return

        if event.type != pygame.MOUSEBUTTONDOWN or event.button != 1:
            return
        mx, my = event.pos

        # 1. Сетка крафта
        for r in range(self.GRID):
            for c in range(self.GRID):
                if self._grid_slot_rect(r, c).collidepoint(mx, my):
                    if self.craft_grid[r][c] is not None:
                        item = self.craft_grid[r][c]
                        self.inventory[item] = self.inventory.get(item, 0) + 1
                        self.craft_grid[r][c] = None
                    elif self.selected:
                        if self.inventory.get(self.selected, 0) > 0:
                            self.craft_grid[r][c] = self.selected
                            self.inventory[self.selected] -= 1
                            if self.inventory[self.selected] <= 0:
                                del self.inventory[self.selected]
                                self.selected = None
                    self._recalc_result()
                    return

        # 2. Результат
        if self.result and self._result_rect().collidepoint(mx, my):
            item = self.result["item"]
            count = self.result.get("count", 1)
            self.inventory[item] = self.inventory.get(item, 0) + count
            for r in range(self.GRID):
                for c in range(self.GRID):
                    self.craft_grid[r][c] = None
            self.result = None
            return

        # 3. Инвентарь
        keys = list(self.inventory.keys())
        start = self.inv_scroll * self.INV_COLS
        i = 0
        for r in range(self.INV_ROWS):
            for c in range(self.INV_COLS):
                if self._inv_slot_rect(i).collidepoint(mx, my):
                    idx = start + i
                    if idx < len(keys):
                        self.selected = keys[idx] if self.selected != keys[idx] else None
                    return
                i += 1

    def update(self, dt):
        if self.message_timer > 0:
            self.message_timer -= dt

    # ---------- Отрисовка ----------
    def _draw_item(self, surface, rect, item_id):
        cfg = self.data.get("items", {}).get(item_id, {})
        color = cfg.get("color", [180, 180, 180])

        # Заливка
        inner = rect.inflate(-6, -6)
        pygame.draw.rect(surface, color, inner, border_radius=5)
        pygame.draw.rect(surface, BLACK, inner, 2, border_radius=5)

        # Символ элемента крупно
        symbol = item_id[:4]
        txt_color = BLACK if sum(color) > 400 else WHITE
        sym = self.sym_font.render(symbol, True, txt_color)
        surface.blit(sym, (rect.centerx - sym.get_width() // 2,
                           rect.centery - sym.get_height() // 2 - 4))

        # Имя мелко снизу
        name = cfg.get("name", item_id)
        # Берём только часть в скобках или до 10 символов
        short = name
        if "(" in name and ")" in name:
            short = name.split("(")[0].strip()[:10]
        nm = self.small.render(short, True, txt_color)
        surface.blit(nm, (rect.centerx - nm.get_width() // 2, rect.bottom - 14))

    def draw(self, surface):
        # Затемнение
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 200))
        surface.blit(overlay, (0, 0))

        # Заголовок
        title = self.big.render("Лабораторный Верстак", True, YELLOW)
        surface.blit(title, (SCREEN_WIDTH // 2 - title.get_width() // 2, 35))

        sub = self.font.render(f"Рецептов: {len(self.data.get('recipes', []))} | "
                               f"Элементов: {len(self.data.get('items', {}))}",
                               True, (200, 200, 200))
        surface.blit(sub, (SCREEN_WIDTH // 2 - sub.get_width() // 2, 70))

        # Сетка 5×5
        for r in range(self.GRID):
            for c in range(self.GRID):
                rect = self._grid_slot_rect(r, c)
                pygame.draw.rect(surface, (45, 45, 55), rect, border_radius=6)
                pygame.draw.rect(surface, (90, 90, 110), rect, 2, border_radius=6)
                item = self.craft_grid[r][c]
                if item:
                    self._draw_item(surface, rect, item)

        # Стрелка
        gx, gy = self._grid_origin()
        gw = self.GRID * (self.SLOT + self.PAD) - self.PAD
        arrow_x = gx + gw + 15
        arrow_y = gy + (self.GRID // 2) * (self.SLOT + self.PAD) + self.SLOT // 2
        pygame.draw.polygon(surface, WHITE, [
            (arrow_x, arrow_y - 20),
            (arrow_x + 50, arrow_y),
            (arrow_x, arrow_y + 20),
        ])

        # Результат
        rr = self._result_rect()
        pygame.draw.rect(surface, (50, 90, 60), rr, border_radius=6)
        pygame.draw.rect(surface, (120, 220, 140) if self.result else (90, 90, 110),
                         rr, 3, border_radius=6)
        if self.result:
            self._draw_item(surface, rr, self.result["item"])
        else:
            q = self.small.render("?", True, (150, 150, 150))
            surface.blit(q, (rr.centerx - q.get_width() // 2,
                             rr.centery - q.get_height() // 2))

        # Инвентарь
        inv_title = self.font.render(
            f"Инвентарь (стр. {self.inv_scroll + 1}) — клик для выбора",
            True, WHITE)
        ox, oy = self._inv_origin()
        surface.blit(inv_title, (ox, oy - 26))

        keys = list(self.inventory.keys())
        start = self.inv_scroll * self.INV_COLS

        for i in range(self.INV_COLS * self.INV_ROWS):
            rect = self._inv_slot_rect(i)
            pygame.draw.rect(surface, (55, 55, 65), rect, border_radius=6)

            idx = start + i
            border = BLACK
            if idx < len(keys) and keys[idx] == self.selected:
                border = YELLOW
            pygame.draw.rect(surface, border, rect, 2 if border == BLACK else 3,
                             border_radius=6)

            if idx < len(keys):
                item_id = keys[idx]
                self._draw_item(surface, rect, item_id)
                cnt = self.inventory[item_id]
                cnt_txt = self.small.render(f"{cnt}", True, WHITE)
                bg = pygame.Surface((cnt_txt.get_width() + 4, cnt_txt.get_height() + 2),
                                    pygame.SRCALPHA)
                bg.fill((0, 0, 0, 180))
                surface.blit(bg, (rect.right - cnt_txt.get_width() - 6, rect.y + 2))
                surface.blit(cnt_txt, (rect.right - cnt_txt.get_width() - 4, rect.y + 3))

        # Подсказка
        hint1 = self.small.render("Q — закрыть верстак", True, WHITE)
        hint2 = self.small.render("Колёсико — прокрутка инвентаря", True, (180, 180, 180))
        surface.blit(hint1, (SCREEN_WIDTH - 170, SCREEN_HEIGHT - 40))
        surface.blit(hint2, (SCREEN_WIDTH - 240, SCREEN_HEIGHT - 22))
"""
PvZ2 Egypt Plant Setup Script
Создаёт папки и plants.json для растений Египта.
Спрайты нужно скачать вручную и положить в sprites/.
"""
import os
import json

# Список растений Египта (международная версия)
EGYPT_PLANTS = [
    {"id": "CabbagePult", "name_ru": "Капуста-метатель", "cost": 100, "cd": 5.0,
     "type": "catapult", "damage": 40, "attack_interval": 2.9},
    {"id": "Bloomerang", "name_ru": "Бумеранг", "cost": 175, "cd": 5.0,
     "type": "shooter", "damage": 20, "attack_interval": 2.9, "pierce": 3},
    {"id": "IcebergLettuce", "name_ru": "Айсберг-салат", "cost": 0, "cd": 20.0,
     "type": "instant", "freeze_duration": 10.0},
    {"id": "GraveBuster", "name_ru": "Пожиратель надгробий", "cost": 0, "cd": 15.0,
     "type": "instant_grave"},
    {"id": "BonkChoy", "name_ru": "Боксёр", "cost": 150, "cd": 5.0,
     "type": "melee", "damage": 15, "attack_interval": 0.4},
    {"id": "Repeater", "name_ru": "Двойной горохострел", "cost": 200, "cd": 5.0,
     "type": "shooter", "damage": 20, "attack_interval": 1.4, "shots": 2},
    {"id": "TwinSunflower", "name_ru": "Двойной подсолнух", "cost": 125, "cd": 15.0,
     "type": "sun_producer", "sun_value": 100, "sun_interval": 24.3},
]

BASE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(BASE, "pvz2_egypt_plants")
SPRITES_DIR = os.path.join(OUT_DIR, "sprites")
CARDS_DIR = os.path.join(OUT_DIR, "cards")

def main():
    os.makedirs(SPRITES_DIR, exist_ok=True)
    os.makedirs(CARDS_DIR, exist_ok=True)

    # plants.json
    plants_data = {}
    for p in EGYPT_PLANTS:
        plants_data[p["id"]] = {
            "name_ru": p["name_ru"],
            "cost": p["cost"],
            "cd": p["cd"],
            "type": p["type"],
            "damage": p.get("damage", 0),
            "attack_interval": p.get("attack_interval", 0),
            "pierce": p.get("pierce", 0),
            "freeze_duration": p.get("freeze_duration", 0),
            "sun_value": p.get("sun_value", 0),
            "sun_interval": p.get("sun_interval", 0),
            "sprite": f"sprites/{p['id']}.png",
            "card": f"cards/{p['id']}.png",
        }

    json_path = os.path.join(OUT_DIR, "plants.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(plants_data, f, ensure_ascii=False, indent=2)

    print(f"[i] Создано: {OUT_DIR}")
    print(f"[i] plants.json: {json_path}")
    print(f"[i] Положи спрайты в: {SPRITES_DIR}")
    print(f"[i] Положи карточки в: {CARDS_DIR}")
    print()
    print("Список растений:")
    for p in EGYPT_PLANTS:
        print(f"  - {p['id']:20s} ({p['name_ru']}) — {p['cost']} солнца")

if __name__ == "__main__":
    main()
{
  "fire": {
    "frames": ["assets/images/effects/fire1.png", "assets/images/effects/fire2.png", "assets/images/effects/fire3.png"],
    "fps": 12,
    "loop": true,
    "size": [40, 40]
  },
  "explosion": {
    "frames": ["assets/images/effects/explosion1.png", "assets/images/effects/explosion2.png"],
    "fps": 15,
    "loop": false,
    "size": [120, 120]
  },
  "pea_hit": {
    "frames": ["assets/images/effects/pea_hit1.png", "assets/images/effects/pea_hit2.png"],
    "fps": 20,
    "loop": false,
    "size": [30, 30]
  },
  "freeze": {
    "frames": ["assets/images/effects/freeze1.png"],
    "fps": 8,
    "loop": true,
    "size": [50, 50]
  }
}
"""
Редактор хотспотов для меню PvZ-Edgewalk.
Запуск: python hotspot_editor.py

Управление:
  ЛКМ + тяни              — нарисовать новую зону
  ЛКМ по зоне             — выбрать
  Тянуть зону             — двигать
  Delete / Backspace      — удалить выбранную
  T                       — сменить callback (start → almanac → ...)
  R                       — переименовать
  Z                       — undo
  S                       — сохранить в hotspots.json
  H                       — показать/скрыть помощь
  Esc                     — выход
"""
import os
import json
import pygame


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
IMG_DIR = os.path.join(BASE_DIR, "assets", "images")
HOTSPOTS_FILE = os.path.join(BASE_DIR, "hotspots.json")
SETTINGS_FILE = os.path.join(BASE_DIR, "settings.json")


def load_settings():
    with open(SETTINGS_FILE, "r", encoding="utf-8") as fp:
        return json.load(fp)


_cfg = load_settings()
SCREEN_WIDTH = _cfg["screen"]["width"]
SCREEN_HEIGHT = _cfg["screen"]["height"]


def load_hotspots():
    if os.path.exists(HOTSPOTS_FILE):
        try:
            with open(HOTSPOTS_FILE, "r", encoding="utf-8") as fp:
                return json.load(fp)
        except Exception:
            pass
    return {"hotspots": []}


def save_hotspots(data):
    with open(HOTSPOTS_FILE, "w", encoding="utf-8") as fp:
        json.dump(data, fp, ensure_ascii=False, indent=2)


def find_bg():
    for folder in ("interface", "Interface", ""):
        for name in ("main_menu_bg.png", "MainMenu.png", "mainmenu.png",
                     "menu_bg.png", "SelectorScreenBackground.jpg",
                     "background1.jpg"):
            p = os.path.join(IMG_DIR, folder, name) if folder else os.path.join(IMG_DIR, name)
            if os.path.exists(p):
                return p
    return None


class Hotspot:
    def __init__(self, rect, name="hotspot"):
        self.rect = pygame.Rect(rect)
        self.name = name
        self.callback = "none"
        self.hover = False

    def to_dict(self):
        return {
            "name": self.name,
            "callback": self.callback,
            "rect": [self.rect.x, self.rect.y, self.rect.w, self.rect.h],
        }


class Editor:
    CALLBACKS = [
        "none",
        "start", "almanac", "options", "quit",
        "zen", "shop", "help",
        "mini_games", "puzzle", "survival",
        "reset_name", "custom",
    ]

    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("Редактор хотспотов — PvZ-Edgewalk")
        self.clock = pygame.time.Clock()
        self.font = pygame.font.SysFont("Arial", 16, bold=True)
        self.small = pygame.font.SysFont("Arial", 12)
        self.big = pygame.font.SysFont("Arial", 22, bold=True)

        # Фон
        self.bg_path = find_bg()
        if self.bg_path:
            try:
                img = pygame.image.load(self.bg_path).convert()
                self.bg = pygame.transform.smoothscale(img, (SCREEN_WIDTH, SCREEN_HEIGHT))
                print(f"[i] Фон: {self.bg_path}")
            except Exception as e:
                print(f"[!] Ошибка фона: {e}")
                self.bg = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
                self.bg.fill((60, 60, 60))
        else:
            print("[!] Фон не найден")
            self.bg = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
            self.bg.fill((60, 60, 60))

        # Хотспоты
        data = load_hotspots()
        self.hotspots = []
        for h in data.get("hotspots", []):
            hs = Hotspot(h["rect"], h.get("name", "hotspot"))
            hs.callback = h.get("callback", "none")
            self.hotspots.append(hs)
        print(f"[i] Загружено хотспотов: {len(self.hotspots)}")

        # Состояние
        self.selected = None
        self.dragging = False
        self.drag_offset = (0, 0)
        self.creating = False
        self.create_start = (0, 0)
        self.create_end = (0, 0)
        self.history = []
        self.status = "Готов. ЛКМ+тяни — новая зона. T — сменить callback."
        self.show_help = True
        self.rename_mode = False
        self.rename_text = ""

    # ---------- ОПЕРАЦИИ ----------
    def save(self):
        data = {"hotspots": [h.to_dict() for h in self.hotspots]}
        save_hotspots(data)
        self.status = f"[S] Сохранено: {len(self.hotspots)} зон → hotspots.json"

    def push_history(self):
        snapshot = []
        for h in self.hotspots:
            nh = Hotspot(h.rect.copy(), h.name)
            nh.callback = h.callback
            snapshot.append(nh)
        self.history.append(snapshot)
        if len(self.history) > 50:
            self.history.pop(0)

    def undo(self):
        if self.history:
            self.hotspots = self.history.pop()
            self.selected = None
            self.status = "[Z] Отменено"

    def next_callback(self):
        if self.selected is None:
            self.status = "Сначала выбери зону (клик)"
            return
        hs = self.hotspots[self.selected]
        try:
            idx = self.CALLBACKS.index(hs.callback)
        except ValueError:
            idx = 0
        idx = (idx + 1) % len(self.CALLBACKS)
        hs.callback = self.CALLBACKS[idx]
        self.status = f"[T] Callback: {hs.callback}"

    # ---------- ЦИКЛ ----------
    def run(self):
        running = True
        while running:
            self.clock.tick(60)
            mouse = pygame.mouse.get_pos()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

                elif event.type == pygame.KEYDOWN:
                    if self.rename_mode:
                        self._handle_rename_key(event)
                        continue

                    if event.key == pygame.K_ESCAPE:
                        running = False
                    elif event.key == pygame.K_s:
                        self.save()
                    elif event.key == pygame.K_z:
                        self.undo()
                    elif event.key in (pygame.K_DELETE, pygame.K_BACKSPACE):
                        if self.selected is not None:
                            self.push_history()
                            self.hotspots.pop(self.selected)
                            self.selected = None
                            self.status = "[Del] Удалено"
                    elif event.key == pygame.K_t:
                        self.next_callback()
                    elif event.key == pygame.K_r:
                        if self.selected is not None:
                            self.rename_mode = True
                            self.rename_text = self.hotspots[self.selected].name
                    elif event.key == pygame.K_h:
                        self.show_help = not self.show_help

                elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                    if self.rename_mode:
                        self.rename_mode = False
                        continue

                    hit = None
                    for i in range(len(self.hotspots) - 1, -1, -1):
                        if self.hotspots[i].rect.collidepoint(mouse):
                            hit = i
                            break

                    if hit is not None:
                        self.selected = hit
                        self.dragging = True
                        self.drag_offset = (
                            mouse[0] - self.hotspots[hit].rect.x,
                            mouse[1] - self.hotspots[hit].rect.y,
                        )
                        self.push_history()
                    else:
                        self.creating = True
                        self.create_start = mouse
                        self.create_end = mouse

                elif event.type == pygame.MOUSEBUTTONUP and event.button == 1:
                    if self.creating:
                        x1, y1 = self.create_start
                        x2, y2 = self.create_end
                        x, y = min(x1, x2), min(y1, y2)
                        w, h = abs(x2 - x1), abs(y2 - y1)
                        if w > 10 and h > 10:
                            self.push_history()
                            hs = Hotspot((x, y, w, h), f"hotspot_{len(self.hotspots)}")
                            self.hotspots.append(hs)
                            self.selected = len(self.hotspots) - 1
                            self.status = f"[+] Создано: {w}×{h} в ({x},{y})"
                        self.creating = False
                    if self.dragging:
                        self.dragging = False

                elif event.type == pygame.MOUSEMOTION:
                    if self.creating:
                        self.create_end = mouse
                    if self.dragging and self.selected is not None:
                        r = self.hotspots[self.selected].rect
                        r.x = mouse[0] - self.drag_offset[0]
                        r.y = mouse[1] - self.drag_offset[1]
                        self.status = f"Двигаю: {r.x},{r.y} {r.w}×{r.h}"

            # Ховер
            for h in self.hotspots:
                h.hover = h.rect.collidepoint(mouse)

            self.draw()
            pygame.display.flip()

        pygame.quit()

    def _handle_rename_key(self, event):
        if event.key == pygame.K_RETURN:
            if self.selected is not None:
                self.hotspots[self.selected].name = self.rename_text
                self.status = f"[R] Переименовано: {self.rename_text}"
            self.rename_mode = False
        elif event.key == pygame.K_ESCAPE:
            self.rename_mode = False
        elif event.key == pygame.K_BACKSPACE:
            self.rename_text = self.rename_text[:-1]
        elif event.unicode and event.unicode.isprintable():
            self.rename_text += event.unicode

    # ---------- ОТРИСОВКА ----------
    def draw(self):
        self.screen.blit(self.bg, (0, 0))

        # Сетка
        for x in range(0, SCREEN_WIDTH, 50):
            pygame.draw.line(self.screen, (255, 255, 255), (x, 0), (x, SCREEN_HEIGHT), 1)
        for y in range(0, SCREEN_HEIGHT, 50):
            pygame.draw.line(self.screen, (255, 255, 255), (0, y), (SCREEN_WIDTH, y), 1)

        # Зоны
        for i, h in enumerate(self.hotspots):
            is_sel = (i == self.selected)
            if is_sel:
                color = (255, 80, 80)
                w = 3
            elif h.hover:
                color = (255, 200, 80)
                w = 2
            else:
                color = (80, 200, 255)
                w = 2

            s = pygame.Surface((h.rect.w, h.rect.h), pygame.SRCALPHA)
            s.fill((*color, 40))
            self.screen.blit(s, h.rect.topleft)
            pygame.draw.rect(self.screen, color, h.rect, w, border_radius=4)

            label = f"{h.name} [{h.callback}]"
            txt = self.small.render(label, True, (255, 255, 255))
            bg = pygame.Surface((txt.get_width() + 6, txt.get_height() + 4),
                                pygame.SRCALPHA)
            bg.fill((0, 0, 0, 180))
            self.screen.blit(bg, (h.rect.x, h.rect.y - 20))
            self.screen.blit(txt, (h.rect.x + 3, h.rect.y - 18))

            size_txt = self.small.render(f"{h.rect.w}×{h.rect.h}", True, (220, 220, 220))
            self.screen.blit(size_txt, (h.rect.x + 4, h.rect.y + 4))

        # Рисование новой
        if self.creating:
            x1, y1 = self.create_start
            x2, y2 = self.create_end
            r = pygame.Rect(min(x1, x2), min(y1, y2), abs(x2 - x1), abs(y2 - y1))
            pygame.draw.rect(self.screen, (80, 255, 80), r, 2)
            size_txt = self.font.render(f"{r.w}×{r.h}", True, (80, 255, 80))
            self.screen.blit(size_txt, (r.x, r.y - 20))

        self._draw_topbar()
        self._draw_statusbar()
        if self.rename_mode:
            self._draw_rename_overlay()
        if self.show_help:
            self._draw_help()

    def _draw_topbar(self):
        bar = pygame.Surface((SCREEN_WIDTH, 30), pygame.SRCALPHA)
        bar.fill((0, 0, 0, 200))
        self.screen.blit(bar, (0, 0))
        title = self.big.render("Редактор хотспотов", True, (255, 255, 100))
        self.screen.blit(title, (10, 2))
        info = self.font.render(
            f"Зон: {len(self.hotspots)} | T — callback | S — сохранить | H — помощь",
            True, (200, 200, 200),
        )
        self.screen.blit(info, (SCREEN_WIDTH - info.get_width() - 10, 6))

    def _draw_statusbar(self):
        bar = pygame.Surface((SCREEN_WIDTH, 28), pygame.SRCALPHA)
        bar.fill((0, 0, 0, 200))
        self.screen.blit(bar, (0, SCREEN_HEIGHT - 28))
        txt = self.font.render(self.status, True, (180, 255, 180))
        self.screen.blit(txt, (10, SCREEN_HEIGHT - 24))

    def _draw_rename_overlay(self):
        w, h = 400, 100
        x = SCREEN_WIDTH // 2 - w // 2
        y = SCREEN_HEIGHT // 2 - h // 2
        pygame.draw.rect(self.screen, (40, 40, 40), (x, y, w, h), border_radius=10)
        pygame.draw.rect(self.screen, (255, 220, 100), (x, y, w, h), 3, border_radius=10)
        lbl = self.font.render("Новое имя (Enter — сохранить):", True, (255, 255, 255))
        self.screen.blit(lbl, (x + 20, y + 15))
        pygame.draw.rect(self.screen, (20, 20, 20), (x + 20, y + 45, w - 40, 35),
                         border_radius=6)
        txt = self.font.render(self.rename_text + "|", True, (255, 255, 200))
        self.screen.blit(txt, (x + 30, y + 52))

    def _draw_help(self):
        w, h = 460, 360
        x = SCREEN_WIDTH - w - 10
        y = 40
        s = pygame.Surface((w, h), pygame.SRCALPHA)
        s.fill((0, 0, 0, 220))
        self.screen.blit(s, (x, y))
        pygame.draw.rect(self.screen, (255, 220, 100), (x, y, w, h), 2, border_radius=8)

        lines = [
            ("H — скрыть/показать помощь", (255, 255, 100)),
            ("", (255, 255, 255)),
            ("ЛКМ + тяни — новая зона", (200, 200, 255)),
            ("ЛКМ по зоне — выбрать", (200, 200, 255)),
            ("Тянуть зону — двигать", (200, 200, 255)),
            ("Delete — удалить", (255, 150, 150)),
            ("T — сменить callback", (150, 255, 255)),
            ("R — переименовать", (150, 255, 150)),
            ("Z — undo", (255, 200, 100)),
            ("S — сохранить", (100, 255, 100)),
            ("Esc — выход", (255, 150, 150)),
            ("", (255, 255, 255)),
            ("Callback — что делает кнопка:", (255, 255, 100)),
            ("  start — начать игру", (200, 200, 200)),
            ("  almanac — альманах", (200, 200, 200)),
            ("  options — настройки", (200, 200, 200)),
            ("  quit — выход", (200, 200, 200)),
            ("  zen — Zen Garden", (200, 200, 200)),
            ("  shop — магазин", (200, 200, 200)),
            ("  help — помощь", (200, 200, 200)),
            ("  mini_games / puzzle / survival", (200, 200, 200)),
            ("  reset_name — сброс имени", (200, 200, 200)),
            ("  custom — кастом", (200, 200, 200)),
        ]
        yy = y + 10
        for text, color in lines:
            if text:
                t = self.font.render(text, True, color)
                self.screen.blit(t, (x + 12, yy))
            yy += 14


def main():
    Editor().run()


if __name__ == "__main__":
    main()
{
  "hotspots": [
    {
      "name": "hotspot_0",
      "callback": "start",
      "rect": [
        611,
        101,
        363,
        116
      ]
    },
    {
      "name": "hotspot_1",
      "callback": "mini_games",
      "rect": [
        614,
        215,
        325,
        115
      ]
    },
    {
      "name": "hotspot_2",
      "callback": "puzzle",
      "rect": [
        628,
        323,
        306,
        98
      ]
    },
    {
      "name": "hotspot_3",
      "callback": "survival",
      "rect": [
        625,
        422,
        288,
        115
      ]
    },
    {
      "name": "hotspot_4",
      "callback": "options",
      "rect": [
        804,
        566,
        54,
        89
      ]
    },
    {
      "name": "hotspot_5",
      "callback": "help",
      "rect": [
        891,
        600,
        31,
        88
      ]
    },
    {
      "name": "hotspot_6",
      "callback": "quit",
      "rect": [
        969,
        605,
        53,
        77
      ]
    },
    {
      "name": "hotspot_7",
      "callback": "shop",
      "rect": [
        602,
        632,
        121,
        72
      ]
    },
    {
      "name": "hotspot_8",
      "callback": "almanac",
      "rect": [
        521,
        550,
        93,
        94
      ]
    },
    {
      "name": "hotspot_9",
      "callback": "zen",
      "rect": [
        365,
        530,
        121,
        143
      ]
    },
    {
      "name": "hotspot_10",
      "callback": "custom",
      "rect": [
        180,
        426,
        124,
        278
      ]
    },
    {
      "name": "hotspot_11",
      "callback": "reset_name",
      "rect": [
        181,
        78,
        310,
        70
      ]
    }
  ]
}
import sys
import os
import subprocess
import pygame

from settings import (
    SCREEN_WIDTH, SCREEN_HEIGHT, FPS, ICON_PATH, ALL_PLANTS, BASE_DIR
)
from entities.ui import MainMenu, load_save, write_save
from entities.game import Game
from entities.seed_chooser import SeedChooser
from entities.console import Console
from entities.docs import Docs
from entities.loading import LoadingScreen
from entities.help_window import HelpWindow
from entities.options_window import OptionsWindow
from entities.zen_garden import ZenGarden
from entities.world_select import WorldSelectMenu
from world_data import WORLDS
from Crafting import CraftingScreen


pygame.init()
pygame.mixer.init()

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("PvZ-Edgewalk")


MUSIC_DIR = os.path.join(BASE_DIR, "assets", "original ost")
_current_music = None


def find_music(name_part):
    if not os.path.isdir(MUSIC_DIR):
        return None
    for root, _, files in os.walk(MUSIC_DIR):
        for f in files:
            if name_part.lower() in f.lower() and f.lower().endswith((".mp3", ".ogg", ".wav")):
                return os.path.join(root, f)
    return None


def play_music(name_part, loops=-1, volume=None):
    global _current_music
    if _current_music == name_part and pygame.mixer.music.get_busy():
        return
    if volume is None:
        from entities.options_window import load_save as _load_opt
        volume = float(_load_opt().get("music_volume", 0.4))
    path = find_music(name_part)
    if path is None:
        print(f"[!] Музыка '{name_part}' не найдена")
        pygame.mixer.music.stop()
        _current_music = None
        return
    try:
        pygame.mixer.music.load(path)
        pygame.mixer.music.set_volume(volume)
        pygame.mixer.music.play(loops)
        _current_music = name_part
        print(f"[i] Играет музыка: {os.path.basename(path)}")
    except Exception as e:
        print(f"[!] Ошибка музыки: {e}")


def open_almanac():
    java_dir = os.path.join(BASE_DIR, "almanac_java")
    if not os.path.isdir(java_dir):
        print("[!] Папка almanac_java не найдена")
        return
    try:
        if sys.platform == "win32":
            script = os.path.join(java_dir, "run.bat")
            if not os.path.exists(script):
                print(f"[!] Не найден {script}")
                return
            subprocess.Popen(["cmd", "/c", script], cwd=java_dir,
                             creationflags=subprocess.CREATE_NEW_CONSOLE)
        else:
            script = os.path.join(java_dir, "run.sh")
            if not os.path.exists(script):
                print(f"[!] Не найден {script}")
                return
            subprocess.Popen(["bash", script], cwd=java_dir)
        print("[i] Альманах запущен (Java)")
    except Exception as e:
        print(f"[!] Ошибка: {e}")


try:
    if os.path.exists(ICON_PATH):
        icon = pygame.image.load(ICON_PATH).convert_alpha()
        icon = pygame.transform.smoothscale(icon, (64, 64))
        pygame.display.set_icon(icon)
except Exception as e:
    print(f"[!] Иконка: {e}")


clock = pygame.time.Clock()
font = pygame.font.SysFont("Arial", 22, bold=True)
big_font = pygame.font.SysFont("Arial", 56, bold=True)


def main():
    state = "loading"
    loading = LoadingScreen()
    game = Game()
    chooser = None
    crafting = None
    console = Console()
    docs = Docs()
    help_window = HelpWindow()
    options_window = OptionsWindow()

    selected_world = None

    inventory = {
        "wax": 5, "mercury": 5, "sulfur": 5, "salt": 5,
        "herb": 5, "oil": 3, "gunpowder": 2, "acid": 2,
    }

    def music_menu():
        play_music("Crazy Dave (Intro Theme)", loops=-1)

    def music_seed():
        play_music("Choose Your Seeds", loops=-1)

    def music_game():
        play_music("Grasswalk", loops=-1)

    def music_zen():
        play_music("ZenGarden", loops=-1)

    def restore_music():
        if state in ("menu", "world_select"):
            music_menu()
        elif state == "seed_chooser":
            music_seed()
        elif state == "game":
            music_game()

    zen_garden = ZenGarden(on_open=music_zen, on_close=restore_music)

    def to_menu():
        nonlocal state, crafting, chooser
        state = "menu"
        crafting = None
        chooser = None
        music_menu()

    def to_world_select():
        nonlocal state
        state = "world_select"
        music_menu()

    def on_world_selected(world_id):
        nonlocal selected_world
        selected_world = world_id
        data = next((w for w in WORLDS if w["id"] == world_id), None)
        if data is None:
            print(f"[!] Неизвестный мир: {world_id}")
            return
        print(f"[i] Выбран мир: {data['name']} ({world_id})")
        to_seed_chooser()

    def to_seed_chooser():
        nonlocal state, chooser
        chooser = SeedChooser(
            plant_names=ALL_PLANTS,
            on_start=start_game,
            on_back=to_world_select,
            max_select=8,
        )
        state = "seed_chooser"
        music_seed()

    def start_game(selected_plants):
        nonlocal state, game, crafting
        game = Game(selected_cards=selected_plants, world_id=selected_world)
        crafting = None
        state = "game"
        music_game()

    def open_zen():
        zen_garden.toggle()

    menu = MainMenu(
        on_start=to_world_select,
        on_almanac=open_almanac,
        on_help=help_window.toggle,
        on_options=options_window.toggle,
        on_zen=open_zen,
    )

    world_menu = WorldSelectMenu(
        on_world_selected=on_world_selected,
        on_back=to_menu,
    )

    running = True
    while running:
        dt = clock.tick(FPS) / 1000.0
        dt = min(dt, 0.05)
        mouse_pos = pygame.mouse.get_pos()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                continue

            if state == "loading":
                if event.type == pygame.KEYDOWN and event.key in (pygame.K_SPACE, pygame.K_RETURN):
                    loading.phase = loading.PHASE_DONE
                continue

            if zen_garden.visible:
                zen_garden.handle(event)
                continue

            if options_window.visible:
                options_window.handle(event)
                continue

            if help_window.visible:
                help_window.handle(event)
                continue

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_CAPSLOCK:
                    console.toggle()
                    continue
                if event.key == pygame.K_w and not console.visible:
                    docs.toggle()
                    continue
                if event.key == pygame.K_a and not console.visible and not docs.visible:
                    open_almanac()
                    continue

            if docs.visible:
                docs.handle(event)
                continue

            if console.visible:
                console.handle_key(event, game)
                continue

            if crafting is not None:
                if event.type == pygame.KEYDOWN and event.key == pygame.K_q:
                    crafting = None
                    continue
                crafting.handle(event)
                continue

            if state == "menu":
                menu.update(mouse_pos)
                menu.handle(event)

            elif state == "world_select":
                world_menu.update(dt)
                world_menu.handle(event)

            elif state == "seed_chooser" and chooser is not None:
                chooser.update(mouse_pos)
                chooser.handle(event)
                if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                    to_world_select()

            elif state == "game":
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_r and (game.game_over or game.win):
                        game.reset()
                    elif event.key == pygame.K_ESCAPE:
                        to_world_select()
                    elif event.key == pygame.K_m:
                        if pygame.mixer.music.get_busy():
                            pygame.mixer.music.pause()
                        else:
                            pygame.mixer.music.unpause()
                    elif event.key == pygame.K_q:
                        crafting = CraftingScreen(inventory=inventory)
                elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                    game.handle_click(*event.pos)

        if state == "loading":
            loading.update(dt)
            if loading.is_done():
                state = "menu"
                music_menu()
            loading.draw(screen)
            pygame.display.flip()
            continue

        if crafting is not None:
            crafting.update(dt)
        console.update(dt)
        help_window.update(mouse_pos)
        options_window.update(mouse_pos)
        zen_garden.update(dt)

        if state == "menu":
            menu.draw(screen, font, big_font)
        elif state == "world_select":
            world_menu.update(dt)
            world_menu.draw(screen)
        elif state == "seed_chooser" and chooser is not None:
            chooser.draw(screen)
        else:
            game.update(dt)
            game.draw(screen)

        if crafting is not None:
            crafting.draw(screen)
        console.draw(screen)
        docs.draw(screen)
        help_window.draw(screen)
        options_window.draw(screen)
        zen_garden.draw(screen)

        pygame.display.flip()

    pygame.quit()
    sys.exit()


if __name__ == "__main__":
    main()
module physics
    use iso_c_binding
    implicit none
contains

    subroutine update_gravity(y, vy, dt, gravity) bind(C, name="update_gravity")
        real(c_double), intent(inout) :: y, vy
        real(c_double), intent(in), value :: dt, gravity
        vy = vy + gravity * dt
        y  = y + vy * dt
    end subroutine update_gravity

    function rects_collide(ax, ay, aw, ah, bx, by, bw, bh) &
            bind(C, name="rects_collide") result(hit)
        real(c_double), intent(in), value :: ax, ay, aw, ah, bx, by, bw, bh
        integer(c_int) :: hit
        if (ax < bx + bw .and. ax + aw > bx .and. &
            ay < by + bh .and. ay + ah > by) then
            hit = 1
        else
            hit = 0
        end if
    end function rects_collide

    function distance(x1, y1, x2, y2) bind(C, name="distance") result(d)
        real(c_double), intent(in), value :: x1, y1, x2, y2
        real(c_double) :: d
        d = sqrt((x2 - x1)**2 + (y2 - y1)**2)
    end function distance

    function lerp(a, b, t) bind(C, name="lerp") result(r)
        real(c_double), intent(in), value :: a, b, t
        real(c_double) :: r
        r = a + (b - a) * t
    end function lerp

    function clamp(v, lo, hi) bind(C, name="clamp") result(r)
        real(c_double), intent(in), value :: v, lo, hi
        real(c_double) :: r
        r = max(lo, min(hi, v))
    end function clamp

end module physics
