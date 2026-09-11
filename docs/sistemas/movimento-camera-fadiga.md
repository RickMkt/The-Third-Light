# Movimento, câmera e fadiga

Fonte: `src/ReplicatedStorage/Shared/MovementConfig.lua`, `MovementController`, `MovementServer`, `CameraEffects`, `MovementAudio`.

## Valores atuais
- WalkSpeed 11 · SprintSpeed 17 · JumpPower 35 · JumpCooldown 0,6 s (bloqueia o estado Jumping após aterrissar)
- Stamina 100 · dreno 18/s · regen 14/s · delay 1,25 s · exaustão até 20
- FOV 72 → 80, kick +3 no início do sprint (decai a 3/s), lerp 6
- Bob: andar 1,7 passos/s (0,035 v / 0,02 h) · correr 2,3 (0,06 / 0,03) · via `Humanoid.CameraOffset`
- Sway: roll por passo 0,35°/0,7°, pitch 0,2°/0,4°, lean strafe 0,6°, lean de curva até 1,2°, aterrissagem −0,12 stud / 1,2°, respiração 0,35° a 0,45 Hz
- Look base: blur 1 px, saturação −0,2, contraste +0,06, brilho −0,03, tint frio
- Fadiga: blur começa em 30% de fadiga, máx 8 (+3 exausto), piscada no batimento 0,12 (suavizada 14), vignette 0,35, tremor 0,12°, saturação −0,3

## Como funciona
- Sprint só com Shift + movendo + stamina > 0 + não exausto + estado do humanoide permite. Shift parado não gasta.
- Servidor recebe apenas `true/false` por `SprintState` e aplica `SprintSpeed`/`WalkSpeed` da config (o cliente também aplica localmente para resposta imediata).
- `CameraEffects` roda dois `BindToRenderStep`: pré-câmera (restaura o CFrame do frame anterior — a câmera nativa lê o LookVector do CFrame, então sem restaurar haveria drift de pitch) e pós-câmera (aplica pitch/roll). O callback de passo dispara no ponto baixo do bob (`stepIndex`) e é usado pelos passos.
- Fadiga = intensidade da respiração (`MovementAudio`), que sobe rápido e desce devagar; alimenta blur/vignette/cor/tremor. A pulsação usa a fase real do loop do batimento (96 bpm).
- Corpo: respiração começa em 60% (piso 25% correndo), batimento em 70% (piso 30%, velocidade até 1,35x), zumbido de fundo abaixo de 30% e pico ao parar exausto; acima de 90% tudo silencia (fade 1,5).

## Testes que devem continuar passando
Correr até zerar (~5,5 s) → sprint corta → regen após 1,25 s → sprint volta só ao cruzar 20 → barra some ~1,5 s após 100%. Shift parado não gasta. Spam de Shift não trava. 3 Space em 0,9 s = 1 pulo. Respawn reinicia tudo. Câmera não deriva com o mouse parado.
