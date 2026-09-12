# 07 · Registro de assets

Todos inspecionados antes do uso (scripts/remotes removidos, parts ancoradas). Onde ficam: `ServerStorage/Assets/...` (templates) e `ReplicatedStorage/Shared/SoundLibrary`, `MovementSounds`, `SoundService/Ambience` (áudio).

## Modelos (Creator Store)

| Uso | Asset ID | Criador | Observações |
|---|---|---|---|
| Pinheiros (12 variações) `Assets/TreeTemplates` | 130515502281374 | Letaij | "Ponderosa Pine Tree Pack", MeshPart + SurfaceAppearance, 3–8k tris; vinham com eixo Z para cima (corrigido); colisão só no tronco (`.001`) |
| Barraca de expedição `Assets/Props/ExpeditionTent` | 129696319680831 | DevCrispy | 1 MeshPart, lona com estais, 15×8×17 studs |
| Caixas e tambor `Assets/Props/CratesBarrel` | 12499666054 | Infinite Vision | "Medieval Market Pack": usados só BoxA/BoxC/Barrel (PBR 2048); barracas medievais não usadas |
| Fogueira `Assets/Props/Campfire` | 14949760399 | Synoou | "Realistic Campfire"; 2 scripts de flicker removidos; luz original removida (estava enterrada) → `FireLight` próprio; afundar 0,6 no chão |
| Cadeira de camping `Assets/Props/CampChair` | 106353298333629 | Evidasz | 1 MeshPart; 3 scripts de "config" removidos; Seat mantido |
| Pilha de lenha `Assets/Props/FirewoodPile` | 14725885274 | goodentity4568 | 2 MeshParts, limpo |
| Lanterna (mesh) `Assets/Props/FlashlightSource` e Tool `Items/Lanterna` | 117648733552528 | TheRealDishings | só o MeshPart + SurfaceAppearance (tint (70,74,62)); scripts/luzes do autor removidos; cabeça no −Z local |
| Rádio antigo `Assets/Props/OldRadio` | 8690799691 | xavier2007 (mesh de Sketchfab) | 1 MeshPart texturizado — **conferir licença** antes de publicar |
| Mesa de piquenique `Assets/Props/PicnicTable` | 10503469726 | 7valkio | 4 Unions + 4 Seats (convertidos em parts); cor escurecida (112,92,66) |
| Toco realista `Assets/Props/TreeStump` | 9217497551 | omarllollo | MeshPart + SurfaceAppearance; veio com ~38 studs, escalar para 2,6–3,2 |
| Samambaia `Assets/Props/Fern` | 7979002756 | TheLegoGuy137 | 1 MeshPart + SurfaceAppearance; veio com 23 studs, usar escala 0,14–0,24; sem colisão |

Rejeitados após inspeção: barraca "Camping Community" (brinquedo), pack Fallout 4 (ripado), fogueiras B/C, mochilas (baixa qualidade), cercas de jardim/PBR picket, placa "Forest Sign" (cartoon), postes de rua modernos.

## Áudio

| Uso | Asset ID | Criador | Observações |
|---|---|---|---|
| Batimento | 9043365842 | APMOfficial | "HEARTBEAT 02 96BPM", 60 s, loop |
| Respiração pesada | 101395573137763 | CYGONLURD | 8 s, royalty-free (Pixabay-style); alternativas 88247479280853, 8258601662, 139784298444442 |
| Zumbido | 98392426611447 | DistrokidOfficial | "2172 Hz High Pitch Frequency", 61 s; tocado a 1,5× |
| Grilos noturnos | 9112764023 | ProSoundEffects | "Crickets Canyon 2", loop 46 s |
| Vento nas folhas | 9116258071 | ProSoundEffects | "Leaves Rustle Wind Blowing Through Trees 1", 76 s |
| Vento base do labirinto | 9112777914 | ProSoundEffects | "Farmland Presence 2 (SFX)", 36 s; vento distante com insetos leves, loop a 0,9×; inserido primeiro como `ServerStorage/Probe_ForestBed`, inspecionado sem scripts/remotes e promovido para `SoundService/Ambience/WindBase` |
| Galho quebrando ×7 | 9113581977, 9113581982, 9113581974, 9113582136, 9113582134, 9113582139, 9113582284 | ProSoundEffects | |
| Folhagem ×4 | 9114518077, 9114518245, 9114576499, 9114576507 | ProSoundEffects | |
| Coruja ×3 (dry) | 9117181035, 9117181543, 9117181321 | ProSoundEffects | |
| Passos grama ×6 | 93560406861628, 111728126261614, 85433080705056, 104414031461916, 134991114873269, 110916840535817 | stellibun | **comunidade — trocar antes do lançamento** |
| Passos terra ×6 | 73443255522221, 139504226298268, 133067975681895, 99076795338829, 80156166111333, 139990035476921 | stellibun | idem |
| Passos madeira ×6 | 86811703512472, 77401623197491, 85512840532357, 88303344454150, 75904665789232, 135602854864816 | stellibun | idem |
| Fogueira | 80452926297091 | DistrokidOfficial | "Lagerfeuer in der Natur", loop posicional |
| Interruptor da lanterna | `rbxasset://sounds/switch.wav` | Roblox | built-in |

## Texturas built-in usadas
`rbxasset://textures/particles/smoke_main.dds` (névoa, fumaça), `rbxasset://textures/particles/fire_main.dds` (chamas do placeholder antigo).
