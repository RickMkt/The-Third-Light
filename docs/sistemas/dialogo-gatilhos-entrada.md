# Diálogo, gatilhos e entrada do labirinto

Fonte: `DialogueConfig`, `TriggerServer`, `DialogueController`, `MazeEntryController`.

- Zonas em `Gameplay/Interactions/Triggers` (parts invisíveis, `CanTouch` true) com atributo `LineId`. `Touched` → servidor resolve o jogador → `ShowLine` (Once por jogador por rodada; anti-repique de 8 s).
- `DialogueConfig[LineId] = { Text, VoiceId, Duration, Once }`. A legenda aparece entre aspas, tom osso, 96 px do rodapé, fade 0,6 s de entrada / 1,2 s de saída. Se `VoiceId` existir, toca e a legenda dura até o áudio terminar.
- Linha atual: `MazeEntrance` = "Eu sinto calafrios na minha espinha..." (4,5 s).
- `MazeEntryController` (cliente), ao receber `MazeEntrance`: cria uma parede invisível **local** (filha da Camera) atrás da zona, uma cortina de névoa de partículas sobre a abertura e um `BlurEffect` que pulsa 14 → 0 em 3,5 s. O efeito é por jogador; o servidor não fecha nada para os outros.
- Para adicionar uma fala: nova entrada no config + part com `LineId` em Triggers. Para narração: gravar (voz real ou ElevenLabs), subir no Creator Hub, preencher `VoiceId`.
