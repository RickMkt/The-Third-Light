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
      Maze
        Layout        (Configuration: grafo, larguras, clareiras, setores e métricas da quality pass)
        Forest        (920 pinheiros: cristas, laterais de corredor e cinturão externo)
        Undergrowth   (275 samambaias aterradas sem colisão)
        Props         (6 troncos decorativos sem colisão)
        Mist          (39 emissores locais sem colisão)
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
| `AmbienceConfig` | Module | grupos, volumes-alvo por área, fade e gancho `ForestSilence` do mixer local |
| `DialogueConfig` | Module | falas do personagem: Text, VoiceId, Duration, Once |
| `VisualConfig` | Module | blur persistente e grão procedural local após a entrada do labirinto |
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
| `CarriedLightController` (Local) | feixe da lanterna preso à câmera (com inércia) para quem segura; oculta a ferramenta localmente em 1ª pessoa |
| `DialogueController` (Local) | legenda das falas + voz (se `VoiceId`) |
| `MazeEntryController` (Local) | ao receber uma `MazeEntrance1..4`: parede local, cortina de névoa, pulso de blur → blur 1,5, grão procedural e escurecimento local |
| `MazeAmbienceController` (Local) | crossfade das 4 famílias de áudio por posição/setor; aplica o gancho de silêncio do futuro Director |

`StarterPlayer/StarterCharacter` = rig R6 neutro. `StarterGui`: `MovementGui` (stamina, crosshair, vignette), `InventoryGui`, `DialogueGui`.

## ServerStorage

- `Assets/TreeTemplates` (12 pinheiros Ponderosa, pivot na base, colisão só no tronco)
- `Assets/Props` (ExpeditionTent, CratesBarrel, Campfire, CampChair, FirewoodPile, FlashlightSource, OldRadio, PicnicTable, TreeStump)
- `Items` (Tools: Lanterna, Lampião, Chave Inglesa, Bateria, Fusível)
- `_Backup_2026-09-11_preGraybox`, `_Backup_2026-09-11_preQualityPass`, `_Archive_2026-09-11_grayboxV1_POIs`, `_Archive_2026-09-11_qualityPartialClaude`

## Lighting / SoundService

Configuração final noturna: `ClockTime 22.6`, lua 16°, sol 0°, `Brightness 1.4`, `Expo −0.15`, ambientes azul-escuros, `Atmosphere` densa clara (0.68 / haze 9.5 / offset 0.4), Bloom baixo, DoF suave, SunRays 0. Durante o projeto da cabana, o Edit está temporariamente em luz diurna; restauração guardada em `ServerStorage/_DevReview_CabinDesign_Lighting`.
`SoundService.AmbientReverb = NoReverb`; `Ambience/` contém `WindBase` (0,12), `CanopyRustle` (0,20) e `ForestBed` (0,11), todos em loop. `SoundGroup`s: `MazeWind`, `MazeCanopy`, `MazeBed`, `MazeSpatial`; volumes efetivos são controlados pelo cliente conforme a área.

## Tags / atributos usados

- Tag `FlickerLight` em luzes: `BaseBrightness`, `Flicker`, `FlickerSpeed`.
- Tools: `LightMode` (Flashlight/Lantern), `Lit`, `Slot`, `PickupRotation` (Vector3 graus), `PickupScale`.
- Parts: `LitPart` (+ `LitColor`/`UnlitColor`) para pavios; `ItemName` em spawns/pickups; `LineId` em gatilhos; `Description`/`LookAt` em MoonWatchPoints (quando existirem).


## Atualização MAZE V2-A (12/09)
- `Map/Maze/Sector1 | Sector2 | Sector3 | FinalGateArea`, cada um com `Forest`, `Undergrowth`, `Props`, `Mist`. `Map/Maze/Layout` (Configuration) continua a verdade do grafo (`OpenWalls`, `LinkWidths`, `MainLinks`, `Clearings`, `StructureAreas`, `DeadEnds1..3`, `Pockets`, `EntryMouth`).
- `Gameplay/ObjectiveCandidates/Sector2|Sector3` (antes `FutureObjectiveSpawns`), `Gameplay/FutureStructures/{RangerCabin,Observatory,WatchPost,TechnicalArea,AncientFoundation}`, `Gameplay/FutureMoonPoints`, `Gameplay/EasterEggAreas` — todos parts invisíveis com atributos (sem lógica).
- `ServerStorage/_Tools/MazePhase2` (ModuleScript de construção: paredes, vegetação, copas) — ferramenta de desenvolvimento, não roda em jogo.

## Atualização MAZE V2-B (12/09)
- `Map/Maze/Layout`: `Rows=13`, `Sector2Rows=4-8`, `Sector3Rows=9-12`, 183 `OpenWalls`, reservas futuras reindexadas. A linha 5 é a nova faixa central; as linhas antigas 5–11 foram transladadas 40 studs ao sul. S1 permaneceu no lugar.
- `Map/Maze/Sector2/Forest/V2B_NewBand` (50 árvores) e `Undergrowth/V2B_NewBand` (65 samambaias): peças decorativas ancoradas e sem colisão. `Gameplay/Sectors` e os marcadores de `FutureStructures` acompanham o novo traçado; nenhuma estrutura foi criada.
- `ReplicatedStorage/Shared/AmbienceConfig` guarda agora limites S2/S3 em Z = −300/−500; `StarterPlayerScripts/MazeAmbienceController` lê esses valores. A fonte em `src/` foi espelhada no place.
- Backup anterior em `ServerStorage/_Backup_2026-09-12_preMazeV2B` e `backups/TheThirdLight_2026-09-12_preMazeV2B.rbxl`; este último é **pré-V2-B**. Ver `13-maze-v2b-resultado.md`.
