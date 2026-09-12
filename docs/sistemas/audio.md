# Áudio

Fonte: `SoundConfig`, `AmbienceConfig`, `SoundLibrary`, `SoundServer`, `FootstepController`, `MovementAudio`, `MazeAmbienceController`, `SoundService/Ambience`.

## Camadas
1. **Ambiência 2D em três famílias**: `WindBase` 0,12 (asset 9112777914, 0,9×), `CanopyRustle` 0,20 (9116258071) e `ForestBed` 0,11 (9112764023, 0,88×). Grupos `MazeWind`, `MazeCanopy`, `MazeBed`.
2. **Mixer local por área** (`MazeAmbienceController`): atualização de alvo a cada 0,25 s e fade exponencial 1,4. Volumes dos grupos Wind/Canopy/Bed/Spatial: Camp 0,55/0,80/1,00/0,70; S1 0,70/0,90/0,75/0,85; S2 0,80/1,00/0,60/1,00; S3 0,85/0,85/0,30/0,75. `Player.ForestSilence` (0–1) reduz todas as famílias para o futuro Director.
3. **Pontuais de floresta** (servidor): a cada 12–30 s, um jogador aleatório, direção aleatória, 18–60 studs: galho (peso 5), folhagem (4), coruja (1, a +14 studs de altura). Emissor invisível no grupo `MazeSpatial`, destruído ao terminar. Rolloff InverseTapered (galho 12–120, folhagem 10–100, coruja 20–220).
4. **Passos**: `Humanoid.FloorMaterial` → Grass/Dirt/Wood (default Dirt). Disparo no ponto baixo do bob. Volume 0,35 andando, 0,6 correndo, 0,7 aterrissando, pitch ±6%, sem repetir a mesma variação. Local imediato + remote `Footstep` → outros clientes tocam no `HumanoidRootPart` de quem anda. Os sons padrão da Roblox (`Running`, `Jumping`, `Landing`…) são silenciados no cliente (a Roblox os cria por CoreScript; override por nome não funciona mais).
5. **Corpo** (só local): respiração, batimento, zumbido — ver `movimento-camera-fadiga.md`. Futuro: replicar para os outros ouvirem.
6. **Fogueira**: `Crackle` em loop posicional (5–48 studs) no `FireLight`.
7. **Falas**: `DialogueController` toca `VoiceId` se houver; as quatro falas atuais estão somente em legenda.

## Regras
- `AmbientReverb = NoReverb` (mata aberta). Preferir gravações "dry".
- Não existe HRTF nativo no Roblox — o "8D" é panning + atenuação + posicionamento cuidadoso + silêncio.
- Assets de áudio: Pro Sound Effects / APM / DistrokidOfficial. Os passos atuais são uploads de comunidade (trocar antes de publicar).
