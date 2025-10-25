https://github.com/CppCXY/EmmyLuaAnalyzer/blob/master/README.md


1099636271, 3414663697, 2332684940, 1132771326, 2073756005, 2370681063, 2921913448, 2192264361

# Mapping
To edit/create maps for this mod, copy the file `editor_setup.xml` to `C:\Program Files (x86)\Steam\steamapps\common\Natural Selection 2\ns2` replacing the original (make a backup copy first).

# Changelog
# October 2025
- improved commander tunnel placement validation
- increase jetpack fuel
- add healing field
- add drifter fix
- add compatibility for siege maps using frontdoor, sidedoor and siegedoor entities

- doubled flashlight distance
- 

# TODO
## Elrond — 2/2/2025 12:54 PM
can you make an ingame player vote to give the option to reduce door timer to 1min? standing 5min before the door doing nothing is boring

## DONE
### alnair — 5/22/2025 8:19 PM
Some suggestions for siege
- Give marines med circles like we have it in vanilla
- Increase JP fuel (x2?)

## Won't Do
### alnair — 5/22/2025 8:19 PM
Some suggestions for siege
- Increase marine default IPs, maybe put to 5 as default


# Broken Maps
## sg_descent
You can use a vent to circumvent the front door entirely. Was able to set up a gorge tunnel just outside marine main before the door was open.

## sg_eclipse
There’s a vent that leads to outside the map. Marines couldn’t get in the comm chair and the hive disappeared on aliens.

# Siege++

## Auto FuncMaid via per-map location config

Some maps don't include the `ns2siege_funcmaid` entity for the Siege room. To prevent early exploitation, the mod can auto-spawn a FuncMaid that matches a Location volume you specify per map.

- Create a config file at: `config://siege/<mapname>.json`
  - On Windows servers this typically maps to: `.../Natural Selection 2/config/siege/<mapname>.json`
- Minimal content (both styles accepted):
  - JSON: `{ "siege_location": "Siege Heaven" }`
  - Loose JSON: `{siege_location:"Siege Heaven"}`

On server start/map load, if no Siege-type FuncMaid exists, the mod:
- Finds all `Location` entities with that name.
- Spawns a `ns2siege_funcmaid` trigger copied to each matching Location's transform and extents.
- Sets it to siege stage (type = 1) so it activates at the Siege time.

Notes:
- If a FuncMaid already exists in the map, the auto-spawner does nothing.
- You can alternatively provide `lua/siege/<mapname>.lua` with `SiegeMapConfig = { siege_location = "..." }`.
- Use the in-game location overlay or spectate to confirm the exact location name.
