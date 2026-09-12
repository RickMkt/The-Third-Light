# Áudio

Fonte: `SoundConfig`, `AmbienceConfig`, `SoundLibrary`, `SoundServer`, `FootstepController`, `MovementAudio`, `MazeAmbienceController`, `SoundService/Ambience`.

## Camadas
1. **Ambiência 2D em três famílias**: `WindBase` 0,12 (asset 9112777914, 0,9×), `CanopyRustle` 0,20 (9116258071) e `ForestBed` 0,11 (9112764023, 0,88×). Grupos `MazeWind`, `MazeCanopy`, `MazeBed`.
2. **Mixer local por área × estado** (`MazeAmbienceController`): atualização de alvo a cada 0,25 s, fade exponencial 1,4 (área) e 0,6 (estado). Volume final de cada camada = `Area[camada] × State[camada] × (1 − ForestSilence)`.
   - Áreas (Wind/Canopy/Bed/Spatial): Camp 0,55/0,80/1,00/0,70 · **S1** 0,70/0,90/0,80/0,85 (floresta viva, insetos) · **S2** 0,80/0,90/0,55/1,00 (menos insetos, mais eventos) · **S3** 0,90/0,70/0,25/0,80 (vazio, vento profundo). É o mesmo lugar ficando errado, não três trilhas.
   - **Estados** (`Player.AmbientState`, servidor/Director; fundação 12/09, nenhuma IA ainda): `Normal` 1/1/1/1 · `Uneasy` 0,9/0,8/0,6/1,1 · `Silent` 0,25/0,1/0/0,5 · `MoonNear` 0,6/0,45/0,15/0,9 · `Chase` 1/0,9/0,3/1. Cada estado tem também `Events` (multiplicador da frequência dos pontuais: Normal 1, Uneasy 0,8, Silent 0, MoonNear 0,35, Chase 0,2). Testado: `Silent` no S1 leva o mix a 0,18/0,09/0,00/0,43 em ~7 s.
   - `Player.ForestSilence` (0–1) continua como escalar de supressão total.
3. **Pontuais de floresta** (servidor, um agendador global): a cada tick escolhe um jogador e usa o ritmo/mix do setor dele, dividido pelo `Events` do estado (0 = pula). Camp 8–16 s (galho 3 / folhagem 6 / coruja 2) · S1 8–16 s (4/6/1,5) · S2 12–24 s (5/4/0,6) · S3 18–34 s (5/2/0,25). Direção aleatória, 18–60 studs, coruja a +14 studs. Emissor invisível no grupo `MazeSpatial`, destruído ao terminar. Rolloff InverseTapered (galho 12–120, folhagem 10–100, coruja 20–220).
4. **Passos**: `Humanoid.FloorMaterial` → Grass/Dirt/Wood (default Dirt). Disparo no ponto baixo do bob. Volume 0,35 andando, 0,6 correndo, 0,7 aterrissando, pitch ±6%, sem repetir a mesma variação. Local imediato + remote `Footstep` → outros clientes tocam no `HumanoidRootPart` de quem anda. Os sons padrão da Roblox (`Running`, `Jumping`, `Landing`…) são silenciados no cliente (a Roblox os cria por CoreScript; override por nome não funciona mais).
5. **Corpo** (só local): respiração, batimento, zumbido — ver `movimento-camera-fadiga.md`. Futuro: replicar para os outros ouvirem.
6. **Fogueira**: `Crackle` em loop posicional (5–48 studs) no `FireLight`.
7. **Voz interior** (`VoiceReactionController`, 2D, só local): ver `voz-reacao-e-entrada.md`. Grupo `Voice` com EQ/reverb preparados e desligados.

## Prioridade de mixagem (regra)
1. ameaça imediata · 2. corpo do jogador · 3. interação · 4. ambiente próximo · 5. ambiente distante. Vento/insetos nunca cobrem gameplay. Silêncio é ferramenta: quando algo que deveria fazer barulho para, o cérebro percebe.

## Camadas-alvo (filosofia 12/09)
Forest bed (contínuo, baixo, nunca cansativo) · ambiente local posicional real ("isso veio da esquerda") · corpo do jogador (passos, respiração, cansaço, batimento, landing, sprint) · silêncio (insetos somem, vento some) · Homem Lua sem música de monstro constante — presença por alterações sutis do ambiente; às vezes nada.

## Regras
- `AmbientReverb = NoReverb` (mata aberta). Preferir gravações "dry".
- Não existe HRTF nativo no Roblox — o "8D" é panning + atenuação + posicionamento cuidadoso + silêncio.
- Assets de áudio: Pro Sound Effects / APM / DistrokidOfficial. Os passos atuais são uploads de comunidade (trocar antes de publicar).
