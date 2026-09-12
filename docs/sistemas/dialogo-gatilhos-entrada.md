# Diálogo, gatilhos e entrada do labirinto

Fonte: `DialogueConfig`, `TriggerServer`, `DialogueController`, `MazeEntryController`.

- Zonas em `Gameplay/Interactions/Triggers` (parts invisíveis, `CanTouch` true) com atributo `LineId`. `Touched` → servidor resolve o jogador → `ShowLine` (Once por jogador por rodada; anti-repique de 8 s). Para `MazeEntrance`, o servidor escolhe `MazeEntrance1..4` por `(abs(UserId) % 4) + 1`, mas registra a entrada-base como consumida para não repetir.
- `DialogueConfig[LineId] = { Text, VoiceId, Duration, Once }`. A legenda aparece entre aspas, tom osso, 96 px do rodapé, fade 0,6 s de entrada / 1,2 s de saída. Se `VoiceId` existir, toca e a legenda dura até o áudio terminar.
- Linhas atuais: `MazeEntrance1` “I feel like something's watching me.” (3,4 s); `MazeEntrance2` “I've got a bad feeling about this place.” (3,6 s); `MazeEntrance3` “Something's moving between the trees.” (3,5 s); `MazeEntrance4` “I don't think we're alone in here.” (3,5 s). Todas `Once = true`, `VoiceId = ""`.
- `MazeEntryController` (cliente), ao receber `MazeEntrance1..4`: cria uma parede invisível **local** (filha da Camera) atrás da zona, uma cortina de névoa de partículas sobre a abertura, um `BlurEffect` que pulsa 14 → 1,5 em 3,5 s, grão procedural sutil (36 pontos + 2 linhas a cada 0,13 s) e o tween de Lighting em 6 s. O tratamento é removido no respawn. O efeito é por jogador; o servidor não fecha nada para os outros.
- Para adicionar uma fala: nova entrada no config + part com `LineId` em Triggers. Para narração: gravar voz humana autorizada, subir no Creator Hub e preencher `VoiceId`; não usar voz aleatória/TTS ruim só para preencher o hook.
