# EXE 1VS1 Duel

Plugin AMX Mod X para Counter-Strike 1.6.

## Concepto

Duelo simple 1vs1 entre dos jugadores elegidos por un admin, sobre el mapa actual (por ejemplo `fy_pool_day`).

- Mejor de 13 rondas: primero a 7 gana.
- Cambio de lado (T/CT) en la ronda 7.
- El resto de jugadores pasan a espectador automáticamente.
- Arma configurable por CVAR.

## Instalación

1. Compilar `exe_1vs1_tournament.sma` con AMX Mod X 1.10+.
2. Copiar el `.amxx` a:
   `cstrike/addons/amxmodx/plugins/`
3. Agregar en:
   `cstrike/addons/amxmodx/configs/plugins.ini`

   `exe_1vs1_tournament.amxx`

4. Copiar `exe_1vs1_tournament.cfg` a:
   `cstrike/cfg/`
5. Ejecutar:
   `exec exe_1vs1_tournament.cfg`

## Comandos

Admin:
- `1v1 <id1> <id2>`
- `1v1stop`
- `1v1status`

## CVARs

- `exe_duel_weapon`  arma del duelo (1=AK47, 2=M4A1, 3=AWP, 4=DEAGLE, 5=SCOUT, 6=KNIFE)
- `exe_duel_freeze`  freeze time de cada ronda
- `exe_duel_hud`     HUD del marcador (1/0)
