# 03 · Arquitetura do place

## Workspace

```
Workspace
  Terrain                       (LeafyGrass base; rochas da entrada em Rock; trilhas Ground/Sand/Mud)
  TheThirdLight
    Map
      Camp
        Forest        (~1.259 pinheiros: anel da clareira, laterais/sul densos, corredor da entrada)
        Props         (barracas, cadeiras, mesa, rádio, folhas, lenha, caixas, tocos, postes, varal, lampiões estáticos)
        Campfire      (Campfire asset + FireLight (luzes Core/Halo + som Crackle))
        Entrance      (cerca velha, corrente, placa)
        Mist          (emissores de névoa rasteira)
        Boundary      (4 paredes invisíveis: z+58, x±62, z−126)
      Maze            (vazio — Setor 1 começa em z < −126)
      FinalArea       (vazio)
    Gameplay
      SpawnPoints/CampSpawn         (SpawnLocation em (0, 3.5, 30) virado para −Z)
      Interactions/ItemSpawns       (parts invisíveis com atributo ItemName → InventoryServer spawna o pickup)
      Interactions/Triggers         (parts com atributo LineId → TriggerServer → fala)
      FutureObjectiveSpawns/Sector2KeyCodeSpawns, Sector3KeyCodeSpawns  (vazios; regra no atributo Rule)
      HidingSpots, MoonWatchPoints  (vazios — a preencher por setor)
      Items                          (pickups vivos no mundo)
      SoundEmitters                  (emissores temporários dos sons de floresta)
    Entities/MoonMan                 (vazio)
```

Convenção: norte = **−Z**. O acampamento está centrado em (0, 0); a entrada do labirinto em z ≈ −42…−84.

## ReplicatedStorage/Shared

| Instância | Tipo | Papel |
|---|---|---|
| `MovementConfig` | Module | walk/sprint/pulo, stamina, FOV, bob, sway, look base, fadiga (blur/vignette/tremor), áudio corporal, tecla M |
| `InventoryConfig` | Module | 3 slots, teclas, alcance de pickup, fades da UI |
| `SoundConfig` | Module | passos (material→grupo, volumes), sons de floresta (intervalos/distâncias/pesos), luzes (lampião/lanterna) |
| `DialogueConfig` | Module | falas do personagem: Text, VoiceId, Duration, Once |
| `SoundLibrary/` | Folder | `Footsteps/{Grass,Dirt,Wood}` (6 cada), `Forest/{BranchSnap 7, Foliage 4, Owl 3}` |
| `MovementSounds/` | Folder | Heartbeat, Breathing, Ringing |
| `SprintState` | RemoteEvent | cliente → servidor (bool) |
| `InventoryRemotes/DropItem, InventoryMessage` | RemoteEvents | largar item; mensagem "cheio" |
| `SoundRemotes/Footstep, ToggleLight` | RemoteEvents | passos replicados; ligar/desligar luz portátil |
| `DialogueRemotes/ShowLine` | RemoteEvent | servidor → cliente (lineId) |

## ServerScriptService

| Script | Responsabilidade |
|---|---|
| `MovementServer` | aplica WalkSpeed/JumpPower no spawn; espelha sprint (só 2 valores); avisa se o rig não for R6 |
| `InventoryServer` | pickups (Model com prompt custom, `PickupRotation`/`PickupScale`), limite de 3, slot estável, drop, spawn nos marcadores de `ItemSpawns` |
| `SoundServer` | relay de passos (rate-limit), sons pontuais de floresta ao redor dos jogadores, toggle de luzes portáteis (Lit, LitPart) |
| `TriggerServer` | zonas com `LineId` → `ShowLine` (Once por jogador; anti-repique 8 s) |

## StarterPlayer/StarterPlayerScripts

| Script | Responsabilidade |
|---|---|
| `MovementController` (Local) | input (Shift, M), stamina/exaustão, cooldown de pulo, barra de stamina, crosshair, modo de mouse, respawn |
| `CameraEffects` (Module) | dois passes em volta da câmera nativa (restaura CFrame → sem drift): FOV+kick, bob posicional via `CameraOffset`, roll/pitch/lean/tremor, aterrissagem, blur/vignette/cor de fadiga com piscada no batimento, callback de passo |
| `MovementAudio` (Module) | respiração, batimento (com fase para o visual), zumbido; modelo de esforço; silêncio acima de 90% |
| `InventoryController` (Local) | UI dos 3 slots, teclas 1/2/3 e G, mensagens |
| `FootstepController` (Local) | passos por material no callback do bob; mute dos sons padrão da Roblox; toca passos dos outros |
| `LightFlicker` (Local) | tremulação de luzes com tag `FlickerLight` (atributos BaseBrightness/Flicker/FlickerSpeed) |
| `InteractionPrompts` (Local) | visual próprio dos ProximityPrompts (Style Custom) |
| `CarriedLightController` (Local) | feixe da lanterna preso à câmera (com lag) para quem segura; mantém ferramenta + braço visíveis em 1ª pessoa |
| `DialogueController` (Local) | legenda das falas + voz (se `VoiceId`) |
| `MazeEntryController` (Local) | ao receber `MazeEntrance`: parede local, cortina de névoa, pulso de blur |

`StarterPlayer/StarterCharacter` = rig R6 neutro. `StarterGui`: `MovementGui` (stamina, crosshair, vignette), `InventoryGui`, `DialogueGui`.

## ServerStorage

- `Assets/TreeTemplates` (12 pinheiros Ponderosa, pivot na base, colisão só no tronco)
- `Assets/Props` (ExpeditionTent, CratesBarrel, Campfire, CampChair, FirewoodPile, FlashlightSource, OldRadio, PicnicTable, TreeStump)
- `Items` (Tools: Lanterna, Lampião, Chave Inglesa, Bateria, Fusível)
- `_Backup_2026-09-11_preGraybox`, `_Archive_2026-09-11_grayboxV1_POIs`

## Lighting / SoundService

Noite (`ClockTime 22.6`, lua 16°, sol 0°), `Brightness 1.4`, `Expo −0.15`, ambientes azul-escuros, `Atmosphere` densa clara (0.68 / haze 9.5 / offset 0.4), Bloom baixo, DoF suave, SunRays 0.
`SoundService.AmbientReverb = NoReverb`; `Ambience/` (NightCrickets 0.16, WindInTrees 0.26).

## Tags / atributos usados

- Tag `FlickerLight` em luzes: `BaseBrightness`, `Flicker`, `FlickerSpeed`.
- Tools: `LightMode` (Flashlight/Lantern), `Lit`, `Slot`, `PickupRotation` (Vector3 graus), `PickupScale`.
- Parts: `LitPart` (+ `LitColor`/`UnlitColor`) para pavios; `ItemName` em spawns/pickups; `LineId` em gatilhos; `Description`/`LookAt` em MoonWatchPoints (quando existirem).
