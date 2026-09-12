# 01 · Estado atual (11/09/2026)

> Atualize este arquivo a cada checkpoint. Ele é o ponto de entrada de qualquer agente.

## Onde estamos

Fase concluída: **fundação do jogador + acampamento + corpo do labirinto + passada de qualidade**.
Plano oficial de execução: `11-plano-oficial-execucao.md`. **MAZE V2-A (corpo definitivo) executado em 12/09 — aguardando avaliação do Rick.** Cabana do S3 arquivada para V2-B (cabana do guarda no S2). Backups `_Backup_2026-09-11_prePhase1_entrada`, `_Backup_2026-09-12_preMazeV2A` (tag Git `checkpoint-before-maze-v2a`). Detalhes em `sistemas/labirinto.md` (seções Fase 1/2/3). Não avançar para chave/código/portão/Homem Lua sem aprovação.
Trilha 3D paralela: **Homem Lua M1 aprovado; corpo M2 concluído e aguardando aprovação**. Ainda não há rosto M3, rig, animações nem integração no place; ver `3d/moon_man/M2_REPORT.md`.

Place: publicado no grupo Necrovale como "A Terceira Luz" (`PlaceId 86901786058243`).
Rig: R6 forçado por `StarterPlayer/StarterCharacter` (corpo neutro, sem avatar do jogador).

## O que está funcionando e testado

### Jogador (fundação)
- Primeira pessoa travada, crosshair dot, **M** solta o mouse (sem abrir menu).
- Walk 11 / Sprint 17 (Shift), pulo 35 com cooldown 0,6 s. Stamina 100, dreno 18/s, regen 14/s após 1,25 s, exaustão até 20.
- Câmera: head bob posicional + roll/pitch por passo, lean em strafe/curva, impacto de aterrissagem, FOV 72→80 com kick, tremor de fadiga. Sem drift.
- Feedback corporal: coração (96→130 bpm), respiração, zumbido, blur/vignette/dessaturação sincronizados ao batimento; silêncio acima de 90% de stamina. Look base: blur 1 px, cor fria.
- Servidor aplica velocidades e espelha o sprint (cliente só escolhe entre 2 valores).

### Inventário (3 slots)
- Itens são `Tool`s. Pickups no mundo = `Model` com prompt custom (E segura → badge preenche). 1/2/3 equipa, G larga. Limite no servidor. Hotbar da Roblox desligada.
- `Lanterna` (mesh PBR tingida, feixe em 3 cones com inércia preso à câmera + cone frontal largo para chão/paredes próximos, **invisível na mão em 1ª pessoa**; os outros a veem na mão). Não há luz 360° no jogador.
- `Lampião` (parts, luz quente curta com tremulação) — existe como Tool mas **não está no mapa**; usado como prop aceso.
- Itens placeholder antigos: Chave Inglesa, Bateria, Fusível (não usados no mapa atual).

### Som
- Passos por material (grama/terra/madeira, 6 variações) sincronizados ao head bob; replicados em 3D para outros jogadores; sons padrão da Roblox silenciados.
- Ambiência em mixer local por área: vento base, copas e cama fria da floresta; intensidades mudam do acampamento ao S3. Gancho `ForestSilence` pronto para o futuro Director.
- Copas em loop a volume 0,28; sons pontuais aleatórios de floresta (galho, folhagem, coruja) a 18–60 studs, a cada 8–16 s, com folhagem predominante, no grupo espacial. Ainda requer validação auditiva do Rick.
- Fogueira crepitando posicional. Sem reverb (área aberta).

### Ambiente — acampamento
- Clareira ~84×74 studs, spawn ao sul virado para fogueira → barracas → entrada. 60 fps no Studio.
- Fogueira (asset), 3 barracas de expedição, 3 cadeiras, mesa de piquenique com rádio antigo, mapa e **anotações de campo** (instruções in-world), lenha, caixas/tambor, tocos, 3 postes de madeira com lampiões, varal, cerca velha com corrente rompida e placa "TRILHA FECH DA".
- Entrada do labirinto: duas massas de rocha (terreno) ~25 e ~31 studs de altura, abertura 12–18 studs, trilha que some na névoa e dobra à esquerda, névoa rasteira densa.
- Paredes invisíveis: sul (z +58), lados (x ±62), norte (z −126). Mata densa e escura além delas; trilha de chegada some em névoa forte.
- Entrada redesenhada: portão de rocha (z −86) → aproximação sinuosa de ~60 studs entre rochas crescentes → boca em (−32,−146) → área de leitura (4,0) com 3 rotas. Ao cruzar a boca (gatilho em z −142): uma de 4 falas curtas em inglês (`UserId % 4`), pulso de blur que assenta em 2,0, VHS suave global (scanlines/tracking/wash) desde o acampamento, cortina de névoa e **parede local em z −135** (mascarada por rocha + curva) — não dá para voltar ao acampamento. Vozes continuam sem asset; apenas legenda. Depois da primeira entrada, morte faz respawn invisível no corredor interno em `(-40, -200)` e mantém o tratamento visual.

### Infra
- Backups: `ServerStorage/_Backup_2026-09-11_preGraybox`, `_Backup_2026-09-11_preQualityPass`, `_Backup_2026-09-11_preMazeRefine2`, `_Backup_2026-09-11_preMazeRefine3`, `_Archive_2026-09-11_grayboxV1_POIs`, `_Archive_2026-09-11_qualityPartialClaude`, `backups/*.rbxl` e Git.
- Lighting em Edit foi encontrado noturno na auditoria (`ClockTime 22,6`, `Brightness 1,4`, `Exposure -0,2`, Atmosphere 0,22). A luz diurna usada só para inspecionar as paredes foi restaurada ao final. O marcador `ServerStorage/_DevReview_CabinDesign_Lighting` segue preservado.
- Organização do Workspace: ver `03-arquitetura.md`.

### Labirinto (corpo + qualidade)
- 11×12 células de 40 studs (440×480), 3 setores, 151 conexões, 5 clareiras e 2 passagens entre setores. Após o terceiro refinamento: largura média 24,9; mínima 20,0; principais média 28,8/mínima 22,3; secundárias média 23,0/mínima 20,0.
- Paredes de rocha e caminhos foram reescavados; S3 ficou mais alto. O calombo central foi removido dos 151 corredores e 132 nós: 604 amostras confirmaram núcleo plano, sem falhas de chão. Vegetação recomposta e aterrada: 920 árvores, 275 samambaias, 6 props sem colisão, 39 emissores de névoa e 64 manchas irregulares de musgo/grama em Terrain. Os 2 boulders esféricos artificiais foram removidos.
- Nesta passada, uma pasta de revisão `VegetationAccent_20260911` somou 15 pinheiros jovens e 80 samambaias baixas sem colisão (totais 935/355). O apoio dos 95 modelos foi verificado por raycast; capim/arbusto de outra família ainda não foi incluído.
- Duas clareiras existentes foram ampliadas e reservadas, sem estruturas: observatório em ruínas no S2 (64×44) e cabana abandonada no S3 (54×38), marcadas em `Gameplay/FutureStructureZones`.
- Layout em `Map/Maze/Layout` (atributos), marcadores de setor e 6+6 candidatos a chave/código preservados. Escurecimento local legível, lanterna revisada e mixer de áudio por setor. Walkthrough completo, cápsula temporária de 3,5–4 m e 60 fps validados. Detalhes: `sistemas/labirinto.md`.

## O que NÃO existe ainda

Gameplay do labirinto (esconderijos, watch points, randomização de chave/código), portão, trilha final, casa, Homem Lua **integrado** (o corpo M2 existe apenas em Blender; faltam rosto, rig, animações e IA), Homem Estrela (teaser), esconderijos funcionais, captura/jumpscare, carry item, narração gravada, HUD de objetivo, teste com 2+ clientes.

## Pendências / dívidas

- `Lighting.Technology` deve estar em **Future** (ação do Rick, no painel Properties do Lighting) — melhora muito sombras de spot/point lights.
- Passos são uploads da comunidade → trocar por gravações licenciadas antes de publicar.
- `PathfindingService` não cobre toda a extensão do labirinto (navmesh) — o Homem Lua deve usar o grafo do `Layout`.
- Sem stamina server-side (cliente modificado corre infinito) — aceitável por ora.
- Narração: `DialogueConfig.VoiceId` vazio; gravar falas (ElevenLabs/voz real) e subir no Creator Hub.
- Grass 3D do Terrain não disponível nesta versão do Studio; sub-bosque virá de assets.
- `.rbxl` local está desatualizado (05:24); atualizar via *Arquivo → Salvar em arquivo como…*.
