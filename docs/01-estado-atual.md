# 01 · Estado atual (11/09/2026)

> Atualize este arquivo a cada checkpoint. Ele é o ponto de entrada de qualquer agente.

## Onde estamos

Fase concluída: **fundação do jogador + acampamento + corpo do labirinto (3 setores, sem gameplay)**.
Fase em andamento: **passada de qualidade no labirinto** (larguras 18–24, vegetação autoral, escuridão legível, lanterna mais forte, camadas de áudio, 4 falas de entrada com legenda) — ver `09-backlog.md`.
Depois: **esconderijos, watch points, chave/código randomizados, portão** (ver `sistemas/labirinto.md`).

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
- `Lanterna` (mesh PBR tingida, feixe em 3 cones com inércia preso à câmera, **invisível na mão em 1ª pessoa**; os outros a veem na mão).
- `Lampião` (parts, luz quente curta com tremulação) — existe como Tool mas **não está no mapa**; usado como prop aceso.
- Itens placeholder antigos: Chave Inglesa, Bateria, Fusível (não usados no mapa atual).

### Som
- Passos por material (grama/terra/madeira, 6 variações) sincronizados ao head bob; replicados em 3D para outros jogadores; sons padrão da Roblox silenciados.
- Ambiência global: grilos + vento. Sons pontuais aleatórios de floresta (galho, folhagem, coruja) a 18–60 studs.
- Fogueira crepitando posicional. Sem reverb (área aberta).

### Ambiente — acampamento
- Clareira ~84×74 studs, spawn ao sul virado para fogueira → barracas → entrada. 60 fps no Studio.
- Fogueira (asset), 3 barracas de expedição, 3 cadeiras, mesa de piquenique com rádio antigo, mapa e **anotações de campo** (instruções in-world), lenha, caixas/tambor, tocos, 3 postes de madeira com lampiões, varal, cerca velha com corrente rompida e placa "TRILHA FECH DA".
- Entrada do labirinto: duas massas de rocha (terreno) ~25 e ~31 studs de altura, abertura 12–18 studs, trilha que some na névoa e dobra à esquerda, névoa rasteira densa.
- Paredes invisíveis: sul (z +58), lados (x ±62), norte (z −126). Mata densa e escura além delas; trilha de chegada some em névoa forte.
- Ao cruzar a entrada: fala *"Eu sinto calafrios na minha espinha..."*, blur na tela, cortina de névoa e **parede local** — não dá para voltar ao acampamento.

### Infra
- Backups: `ServerStorage/_Backup_2026-09-11_preGraybox` (com TerrainRegion), `ServerStorage/_Archive_2026-09-11_grayboxV1_POIs`, `backups/*.rbxl`, Git.
- Organização do Workspace: ver `03-arquitetura.md`.

### Labirinto (corpo)
- 11×12 células de 40 studs (440×480), 3 setores com 2 passagens entre cada, 5 clareiras, paredes de rocha 26+ studs com saliências/musgo, pinheiros nas cristas, mudas/samambaias/troncos/pedras/névoa nos corredores, cinturão de mata fechada sem paredes invisíveis. Layout em `Map/Maze/Layout` (atributos). Marcadores de setor e 6+6 candidatos a chave/código. Escurecimento local + parede ao entrar. 60 fps. Detalhes: `sistemas/labirinto.md`.

## O que NÃO existe ainda

Gameplay do labirinto (esconderijos, watch points, randomização de chave/código), portão, trilha final, casa, Homem Lua (modelo, rig, animações, IA), Homem Estrela (teaser), esconderijos funcionais, captura/jumpscare, carry item, narração gravada, HUD de objetivo, teste com 2+ clientes.

## Pendências / dívidas

- `Lighting.Technology` deve estar em **Future** (ação do Rick, no painel Properties do Lighting) — melhora muito sombras de spot/point lights.
- Passos são uploads da comunidade → trocar por gravações licenciadas antes de publicar.
- `PathfindingService` não cobre toda a extensão do labirinto (navmesh) — o Homem Lua deve usar o grafo do `Layout`.
- Sem stamina server-side (cliente modificado corre infinito) — aceitável por ora.
- Narração: `DialogueConfig.VoiceId` vazio; gravar falas (ElevenLabs/voz real) e subir no Creator Hub.
- Grass 3D do Terrain não disponível nesta versão do Studio; sub-bosque virá de assets.
- `.rbxl` local está desatualizado (05:24); atualizar via *Arquivo → Salvar em arquivo como…*.
