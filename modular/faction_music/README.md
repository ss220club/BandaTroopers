# Faction music

Faction tracks are discovered automatically at build time. Add an `.mp3`, `.ogg`, or `.wav` file anywhere below the matching folder and run the normal build command. Subdirectories are supported.

| Music key | Folder |
| --- | --- |
| `USCM` | `sound/factions music/USCM Marines/` |
| `ODST` | `sound/factions music/ODST/` |
| `UNSC` | `sound/factions music/UNSC/` |
| `UPP` | `sound/factions music/UPP/` |
| `WY` | `sound/factions music/WY Corporate/` |
| `COLONIAL_MILITIA` | `sound/factions music/Colonial Militia/` |
| `CLF` | `sound/factions music/CLF/` |
| `PMC` | `sound/factions music/PMC/` |

`tools/build/lib/faction_music.js` writes `generated/faction_music_tracks.dm` before `dm`, `dm-test`, and `autowiki` compilation. Do not edit the generated file manually. A faction with no tracks remains silent; tracks are never borrowed from another faction.

Filenames must not contain apostrophes or newlines because DreamMaker resource literals cannot represent those paths safely.
