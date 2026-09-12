# Voz interior (Voice Reaction), gatilhos e entrada do labirinto

Fonte: `VoiceConfig`, `VoiceReactionController`, `TriggerServer`, `MazeEntryController`, `VisualConfig.MazeEntry`.
Substituiu em 12/09 o sistema v1 (`DialogueConfig`/`DialogueController`/`DialogueGui`/`DialogueRemotes.ShowLine`), arquivado em `ServerStorage/_Archive_2026-09-12_DialogueV1`.

## O que é
Não é diálogo. É pensamento verbalizado: respiração, instinto, reação involuntária. **Só o próprio jogador ouve** (Sound 2D em `SoundService`, sem parte no mundo). Aparece também como legenda discreta. Personagem não fala a partida inteira — silêncio importa mais que fala.

## Fluxo
1. `Gameplay/Interactions/Triggers/MazeEntrance` (part invisível em `(−32, 10, −142)`, 26×16×6) tem atributo `EventId = "MazeEntry"`.
2. `TriggerServer` (servidor, dono do estado): no primeiro toque com `InMaze ≠ true` → escolhe a frase menos usada entre os jogadores presentes (`VoiceLine_MazeEntry = índice`, empate aleatório), `RespawnLocation = MazeRespawn`, `InMaze = true`. Também define no join: `RoundId = 1`, `AmbientState = "Normal"`, `InMaze = false`.
3. **Fronteira verdadeira = `Player.InMaze` virar `true`.** Tudo local reage a esse atributo:
   - `MazeEntryController`: parede local + cortina de névoa no mesmo instante (físico); tween de Lighting (6 s) começa em `LightingDelay 0,2 s`; pulso de blur (0 → 14 → 2,0) em `BlurDelay 0,45 s`.
   - `MazeAmbienceController`: o mix segue a posição (fade exponencial 1,4) — a transição sonora é contínua.
   - `VoiceReactionController`: `Delay {0,9; 1,9}` s aleatório por jogador → toca o som (se `SoundId` existir) + legenda.
   - Medido em Play (a partir do cruzamento): parede 0,0–0,1 s · exposição começa a cair ~0,2 s (perceptível a partir de ~0,6 s) · blur pico em 1,2 s, assenta em 2,0 aos 4,8 s · legenda 0,95 s com fade-in 0,55 s · hold 3 s · fade-out 1,1 s. Nada acontece no mesmo frame.
4. Respawn mantém `InMaze = true` → a frase **não repete**; parede/névoa/blur/Lighting são recriados instantaneamente (`closeEntrance(true)`).
5. Um futuro sistema de rodada incrementa `RoundId` → o cliente limpa as flags `Once`; o servidor só reatribui frases quando `InMaze` voltar a `false`.

## VoiceConfig
- `Events[eventId] = { Once, Cooldown, Delay = {min, max}, Lines = { {Text, SoundId, Volume, PlaybackSpeed, SubtitleDuration} } }`.
- `MazeEntry`: 8 frases (`Once = true`): "I feel like something's watching me." · "I've got a bad feeling about this place." · "Something's moving between the trees." · "I don't think we're alone in here." · "I've got chills running down my spine." · "I swear I saw something move." · "Why did it suddenly get so quiet?" · "Something feels wrong here." Todas com `SoundId = ""` (só legenda). Teste de balanceamento (mock 4 jogadores × 200 rodadas): 0 duplicatas.
- `Subtitle`: Gotham Medium 16 px, cor osso `(198,192,180)`, transparência mínima 0,10, stroke 1 px escuro, 74 px do rodapé, largura máx. 640, sobe 6 px no fade-in. Sem caixa, sem HUD. `VoiceGui` DisplayOrder 40 (abaixo do VHS 45).
- `Processing` (2D): `SoundGroup "Voice"` com `EqualizerSoundEffect` (−3/0/−2,5 dB) e `ReverbSoundEffect` (decay 0,55 s, wet −22 dB) **desligados** (`Enabled = false`) até existirem clipes reais. Regra: se piorar a naturalidade, voz limpa. Estéreo: centralizado (Roblox não tem HRTF; um clipe estéreo levemente aberto já dá amplitude).
- `DebugLog = true`: em Studio imprime `[VoiceReaction] MazeEntry: "..."`.
- Remote `Shared/VoiceRemotes/Trigger` (servidor → cliente, `eventId`) para momentos futuros: primeira visão do Homem Lua, entrada no S3, portão, casa. Adicionar = nova entrada em `Events` + `FireClient`. Não criar novo sistema.

## Direção da futura dublagem
Jovem/adulto com medo tentando manter controle. Baixo volume, praticamente para si mesmo, com pausa e hesitação. Não é narrador, trailer, demônio, locutor, herói. Tratamento: leve, etéreo, "dentro da cabeça", sem eco de igreja, sem efeito demoníaco. Gravar (ElevenLabs/voz real autorizada), subir no Creator Hub, preencher `SoundId`. Nunca TTS genérico ou voz de Toolbox.
