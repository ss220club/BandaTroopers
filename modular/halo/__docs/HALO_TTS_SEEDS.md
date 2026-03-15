# HALO TTS Seeds

Canonical HALO shortlist data for Covenant race defaults that use `Silero` seeds from the shared TTS module.

## Defaults
- `Sangheili -> Alarak`
- `Unggoy -> Dobby`

## Canonical packs
### Sangheili
- `Pack A (Recommended)`: `Alarak`, `Arthas`, `Malganis`
- `Pack B`: `Arthas`, `Alarak`, `Sion`

### Unggoy
- `Pack A (Recommended)`: `Dobby`, `Ziggs`, `Twitch`
- `Pack B`: `Ziggs`, `Twitch`, `Gazlowe`
- `Pack C`: `Dobby`, `Gazlowe`, `Cicero`

## Integration rule
- Halo race defaults apply automatically for `Sangheili` and `Unggoy`.
- Explicit player `prefs.tts_seed` wins over the Halo race default and is preserved.
- The default is reapplied after Halo equipment presets finish loading so randomized preset flows do not drift away from the species mapping.

## Audit status
- Audited against repo state on `2026-03-13`.
- Runtime mapping lives in `modular/halo/code/mixed/compat/halo_tts.dm`.
- The default-apply path is called from both HALO species spawn handlers and HALO equipment preset loading.
- `modular/text_to_speech/code/seeds/silero.dm` currently defines `848` `/datum/tts_seed/silero` entries.
- Approved shortlist registry buckets at audit time:
  - `Alarak`, `Arthas`, `Malganis`, `Sion`, `Dobby`, `Ziggs`, `Twitch`, `Gazlowe`: `male`
  - `Cicero`: `any`

## Manual audio verification
- Audio audition is an external manual step, not something that can be validated from repo state alone.
- Recommended Russian check lines:
  - `Sangheili`: `Во имя Священного Круга!`, `Очистите их!`, `Клинки к бою!`
  - `Unggoy`: `Ой-ой, враг!`, `Начальник, помоги!`, `Не бросайте меня.`
- Acceptance targets:
  - `Sangheili`: low, clear, authoritative, not comedic
  - `Unggoy`: high, fast, nervous, slightly frantic, not child-cartoon

## Rejected defaults
- `Grunt` for `Unggoy`: too low and brutish for the repo-local `тараторит/пищит/визжит` speech profile.
- `Diablo`, `Cho`, `Darth_Vader`, `Davy_Jones` for `Sangheili`: too monstrous or too recognizable for disciplined Covenant elites.
- `Donkey` for `Unggoy`: too human-comedic.

## References
- Halo speech cues in repo:
  - `modular/halo/code/mixed/language/halo_languages.dm`
  - `modular/localization/code/modules/mob/living/carbon/human/ai/brain/human_ai_localization_halo.dm`
- External voice and lore references:
  - https://www.halopedia.org/Unggoy
  - https://www.halopedia.org/Unggoy/Quotes
  - https://www.halopedia.org/Sangheili/Quotes
  - https://dedalvs.com/work/halo/miscellaneous/sangheili_pronunciation_v2.pdf
  - https://files.lyberry.com/books/Halo%20Collection%20All%20Books/Halo%20Book%205%20-%20Contact%20Harvest.pdf
  - https://heroesofthestorm.fandom.com/wiki/Alarak/Quotes
  - https://heroesofthestorm.fandom.com/wiki/Arthas/Quotes
  - https://heroesofthestorm.fandom.com/wiki/Mal%27Ganis/Quotes
  - https://leagueoflegends.fandom.com/wiki/Sion/LoL/Audio
  - https://leagueoflegends.fandom.com/wiki/Ziggs/LoL/Audio
  - https://leagueoflegends.fandom.com/wiki/Twitch/LoL/Audio
  - https://harrypotter.fandom.com/wiki/Dobby
  - https://elderscrolls.fandom.com/wiki/Cicero
  - https://news.blizzard.com/en-us/article/14355504/building-the-nexus-the-voice-of-gazlowe
