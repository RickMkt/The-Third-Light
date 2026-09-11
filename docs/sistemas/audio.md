# Áudio

Fonte: `SoundConfig`, `SoundLibrary`, `SoundServer`, `FootstepController`, `MovementAudio`, `SoundService/Ambience`.

## Camadas
1. **Ambiência 2D** (todos): grilos noturnos 0,16 + vento nas folhas 0,26.
2. **Pontuais de floresta** (servidor): a cada 9–26 s, um jogador aleatório, direção aleatória, 18–60 studs: galho (peso 5), folhagem (4), coruja (2, a +14 studs de altura). Emissor invisível que se destrói ao terminar. Rolloff InverseTapered (galho 12–120, folhagem 10–100, coruja 20–220).
3. **Passos**: `Humanoid.FloorMaterial` → Grass/Dirt/Wood (default Dirt). Disparo no ponto baixo do bob. Volume 0,35 andando, 0,6 correndo, 0,7 aterrissando, pitch ±6%, sem repetir a mesma variação. Local imediato + remote `Footstep` → outros clientes tocam no `HumanoidRootPart` de quem anda. Os sons padrão da Roblox (`Running`, `Jumping`, `Landing`…) são silenciados no cliente (a Roblox os cria por CoreScript; override por nome não funciona mais).
4. **Corpo** (só local): respiração, batimento, zumbido — ver `movimento-camera-fadiga.md`. Futuro: replicar para os outros ouvirem.
5. **Fogueira**: `Crackle` em loop posicional (5–48 studs) no `FireLight`.
6. **Falas**: `DialogueController` toca `VoiceId` se houver.

## Regras
- `AmbientReverb = NoReverb` (mata aberta). Preferir gravações "dry".
- Não existe HRTF nativo no Roblox — o "8D" é panning + atenuação + posicionamento cuidadoso + silêncio.
- Assets de áudio: Pro Sound Effects / APM / DistrokidOfficial. Os passos atuais são uploads de comunidade (trocar antes de publicar).
