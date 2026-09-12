# 01 · Estado atual (12/09/2026)

> Atualize este arquivo a cada checkpoint. Ele é o ponto de entrada de qualquer agente.

## Onde estamos

Fase concluída: **fundação do jogador + acampamento + corpo do labirinto + passada de qualidade**.
Plano oficial de execução: `11-plano-oficial-execucao.md`. **12/09 (tarde): decisões congeladas — MaxPlayers 4 e regra 60/40 (psicológico/físico). V2-B0 Experience + Immersion Foundation executada e testada** (voz interior v2 local, sequência de entrada, estados de ambiência, ritmo de eventos por setor); ver `sistemas/voz-reacao-e-entrada.md` e `sistemas/audio.md`. V2-B1 = graybox da Cabana do Guarda (S2) em execução. **MAZE V2-B estrutural salvo na nuvem; V2-A.1 (polish estrutural) executado em 12/09 de manhã — aguardando avaliação do Rick.** V2-A aprovado conceitualmente; cabana do S3 permanece arquivada (S3 = AncientFoundation). O Setor 2 ganhou uma linha central de floresta (+25% de área nominal), quatro reservas futuras afastadas e novos trajetos. Nenhuma estrutura foi construída. Backup anterior: `ServerStorage/_Backup_2026-09-12_preMazeV2B`, arquivo `backups/TheThirdLight_2026-09-12_preMazeV2B.rbxl` e tag Git `checkpoint-before-maze-v2b-central`. Relatório: `13-maze-v2b-resultado.md`; mapa atualizado: `img/mapa-labirinto-v2b.png`. **As mudanças V2-B ainda são estado vivo do place até Rick confirmar Ctrl+S; o .rbxl citado é pré-V2-B.** Não avançar para chave/código/portão/Homem Lua sem aprovação.
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
- Entrada redesenhada: portão de rocha (z −86) → aproximação sinuosa de ~60 studs entre rochas crescentes → boca em (−32,−146) → área de leitura (4,0) com 3 rotas. Ao cruzar a boca (gatilho em z −142, `EventId = MazeEntry`): o servidor vira `InMaze` → parede local em z −135 + cortina de névoa (0 s) → Lighting cai (0,2 s, 6 s) → pulso de blur (0,45 s) que assenta em 2,0 → voz interior (0,9–1,9 s; uma de 8 frases, balanceada entre os jogadores, só legenda por enquanto, só o próprio ouve). VHS suave global (scanlines/wash, **sem faixa de tracking**) desde o acampamento. **Parede local** (mascarada por rocha + curva) — não dá para voltar ao acampamento. Vozes continuam sem asset; apenas legenda. Depois da primeira entrada, morte faz respawn invisível no corredor interno em `(-40, -200)` e mantém o tratamento visual.

### Infra
- Backups: `ServerStorage/_Backup_2026-09-11_preGraybox`, `_Backup_2026-09-11_preQualityPass`, `_Backup_2026-09-11_preMazeRefine2`, `_Backup_2026-09-11_preMazeRefine3`, `_Archive_2026-09-11_grayboxV1_POIs`, `_Archive_2026-09-11_qualityPartialClaude`, `backups/*.rbxl` e Git.
- Lighting em Edit foi encontrado noturno na auditoria (`ClockTime 22,6`, `Brightness 1,4`, `Exposure -0,2`, Atmosphere 0,22). A luz diurna usada só para inspecionar as paredes foi restaurada ao final. O marcador `ServerStorage/_DevReview_CabinDesign_Lighting` segue preservado.
- Organização do Workspace: ver `03-arquitetura.md`.

### Labirinto (corpo + qualidade)
- Layout atual: **11×13 células de 40 studs, 143 nós, 183 links**. S1 linhas 0–3 (70.400 studs²), S2 4–8 (88.000 studs²), S3 9–12 (70.400 studs²). A faixa inserida é a linha 5; S3/portão foram transladados 40 studs ao sul, sem ampliar S3. S1 foi preservado.
- Reservas vazias no S2: Cabana (−160,−480) 40×46, Observatório (0,−400) 60×64, Posto (120,−320) 36×40, Área Técnica (200,−440) 40×45. Clareiras do Observatório, Posto e Área Técnica foram refinadas; núcleos de 28×28 livres de árvores baixas. Nenhuma construção final.
- A faixa ganhou **50 pinheiros e 65 samambaias** nas bordas; 115/115 bases testadas sem flutuação ou enterramento e sem colisão nas peças novas. Cinco enlaces estreitos foram alargados para mínimo medido de 20,7 studs no meio da passagem. Os 26 enlaces ligados à linha nova passaram no Pathfinding com agente de raio 4, sem desvio longo.
- Walkthrough em Play passou por Observatório, Posto, Área Técnica e Cabana (trecho longo dividido em etapas) e cruzou S2→S3. As seis linhas de visão entre os quatro centros estão bloqueadas. Entrada e morte mantiveram `InMaze`, respawn no labirinto e blur/VHS. O FPS de renderização no Studio em segundo plano ficou inconclusivo; a simulação marcou 60 FPS. Valores e ressalvas: `13-maze-v2b-resultado.md`.

## O que NÃO existe ainda

Gameplay do labirinto (esconderijos, watch points, randomização de chave/código), portão, trilha final, casa, Homem Lua **integrado** (o corpo M2 existe apenas em Blender; faltam rosto, rig, animações e IA), Homem Estrela (teaser), esconderijos funcionais, captura/jumpscare, carry item, narração gravada, HUD de objetivo, teste com 2+ clientes.

## Pendências / dívidas

- `Lighting.Technology` deve estar em **Future** (ação do Rick, no painel Properties do Lighting) — melhora muito sombras de spot/point lights.
- Passos são uploads da comunidade → trocar por gravações licenciadas antes de publicar.
- `PathfindingService` não cobre toda a extensão do labirinto (navmesh) — o Homem Lua deve usar o grafo do `Layout`.
- Sem stamina server-side (cliente modificado corre infinito) — aceitável por ora.
- Voz interior: `VoiceConfig` com `SoundId` vazio (só legenda); gravar 8 frases (ElevenLabs/voz real) e subir no Creator Hub.
- `Players.MaxPlayers` ainda 60 no place: Rick precisa definir **4** em Game Settings (read-only por script).
- Grass 3D do Terrain não disponível nesta versão do Studio; sub-bosque virá de assets.
- `.rbxl` local está desatualizado (05:24); atualizar via *Arquivo → Salvar em arquivo como…*.
