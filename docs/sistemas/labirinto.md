# Labirinto — corpo (Setores 1–3)

Construído e submetido à passada de qualidade em 11/09/2026. Só o corpo: sem chave/código, sem portão, sem Homem Lua, sem landmarks ou esconderijos funcionais. Aguardando aprovação visual/sonora do Rick.

## Geometria
- Grade **11 colunas × 12 linhas**, célula de **40 studs**; `Layout` (Configuration em `Map/Maze`) guarda tudo em atributos: `Cols, Rows, Cell, X0=-200, Z0=-160, EntryCol=4, ExitCol=7, Passages12="4,6", Passages23="1,10", OpenWalls` (lista `c,r|c,r;…`), `Clearings` (`2,2;8,1;5,5;1,7;8,10`), `DeadEnds1..3`.
- Centro da célula: `x = -200 + c*40`, `z = -160 - r*40` (norte = −Z). Setor 1 = linhas 0–3, Setor 2 = 4–7, Setor 3 = 8–11.
- Geração: DFS aleatório **por setor** (seed 2027) + 9 laços extras; **2 passagens** entre S1→S2 (colunas 4 e 6) e S2→S3 (colunas 1 e 10); 5 clareiras circulares (raio 27) com todas as paredes abertas.
- Entrada: corredor do camping (−24,−110) → célula (4,0) em (−40,−160). Saída: célula (7,11) → corredor até o marcador `Gameplay/Interactions/FutureGateMarker` em (80, −670).
- Paredes: Terrain Rock reescavado sem alterar o grafo. `LinkWidths` define o ritmo de cada conexão; após o terceiro refinamento, a medição por raycast ficou em **todas média 24,9/min 20,0; principais média 28,8/min 22,3; secundárias média 23,0/min 20,0**. S3 foi elevado para reforçar profundidade; curvas e junções receberam folga adicional.
- Chão: faixa gasta de Ground nos caminhos principais, bolsões de Mud e 64 manchas irregulares de musgo/grama em Terrain. Na segunda passada, a faixa elevada central foi removida dos **151 links e 132 nós**; o núcleo transitável ficou plano em Y≈2. Detalhes de parede são rasos e esparsos; não invadem o núcleo de perseguição.
- Tamanho: 440 × 480 studs (mais entrada/saída). A rota principal validada passa por 27 links e chega ao marcador de saída.

## Vegetação e cenário (`Map/Maze/*`)
- `Forest`: **920 pinheiros**. As 41 árvores internas antigas foram substituídas por 48 árvores menores aterradas nas laterais (S1 14, S2 16, S3 18); 4 árvores sem apoio foram removidas e 7 das cristas foram assentadas. As novas usam colisão simples invisível apenas no tronco. **Sem paredes invisíveis internas**; contenção por rocha + mata.
- `Undergrowth`: **275 samambaias** refeitas sobre piso validado (S1 80, S2 90, S3 105), com a base 0,08 stud enterrada; todas sem colisão/touch/query.
- `Props`: **6** troncos decorativos, sem colisão e fora do núcleo. Os 2 `Boulder` esféricos artificiais foram removidos.
- `Mist`: **39 emissores**; Atmosphere faz o trabalho amplo.
- Árvores mantêm colisão simples só no tronco. Samambaias, props e emissores têm `CanCollide = false`.
- `VegetationAccent_20260911`: **80 samambaias baixas + 15 pinheiros jovens adicionais** (5 pinheiros por setor), em pasta separada para revisão. São clones de famílias já existentes, não assets novos. Seleção determinística por piso de Terrain quase plano em Y≈2, distância das samambaias existentes ≥5 studs e dos novos pontos ≥7; base enterrada 0,08 stud, sem colisão/touch/query. Assim o total visível é 935 pinheiros e 355 samambaias. Capim/arbusto de nova família ainda não foi escolhido.

## Marcadores (`Gameplay/`)
- `Sectors/Sector1..3`: zonas invisíveis (atributos `Sector`, `Rows`) para o director do Homem Lua e regras de chave/código.
- `FutureObjectiveSpawns/Sector2KeyCodeSpawns` (6) e `Sector3KeyCodeSpawns` (6): candidatos (becos sem saída primeiro), atributos `Cell`, `Sector`. **Randomização ainda não implementada.**
- `Interactions/FutureGateMarker`: onde o portão final vai ficar.
- `FutureStructureZones/RuinedObservatoryZone` (S2, 64×44) e `AbandonedCabinZone` (S3, 54×38): reservas invisíveis e planas. Não contêm estrutura ainda.

## Escuridão e entrada
- Ao cruzar `MazeEntrance`: `MazeEntryController` (cliente) fecha a volta (parede local + cortina de névoa + blur) **e** escurece a Lighting local em 6 s: `Brightness 0,72`, `Expo −0,58`, `Ambient (10,12,19)`, `OutdoorAmbient (22,27,39)`, Atmosphere densidade 0,74 / haze 10,5 / offset 0,48 / cor (65,72,92) / decay (12,16,26). Quem fica no acampamento mantém a luz do acampamento. Após a primeira entrada, morte/respawn mantém o jogador e os efeitos no labirinto.
- `Gameplay/SpawnPoints/MazeRespawn`: spawn invisível na célula `(4,1)`, em `(-40, 2,5, -200)`; `InMaze` no Player e `RespawnLocation` são definidos no servidor ao cruzar o gatilho. O respawn foi validado por morte real em Play. O tratamento visual persistente agora usa blur 2,4, 256 partículas de ruído e 5 scanlines; percepção visual precisa de validação do Rick no cliente.
- A lanterna continua invisível na mão em 1ª pessoa; feixe em 3 cones: foco `68/18°/2,8` com sombras, médio `48/36°/1,15`, spill `30/74°/0,42`. O preenchimento próximo agora é outro `SpotLight` frontal sem sombras (`32/100°/1,8`), 4 studs à frente e 1 abaixo: ilumina o chão sem vazar para trás. Inércia exponencial `RotationLag 10`; sway base `0,26°`, multiplicador `0,25` parado e `1,55` correndo.
- `MazeAmbienceController` faz crossfade de vento/copas/cama/eventos por setor e aceita `Player.ForestSilence` (0–1) para o futuro Director.

## Testes feitos
- Largura auditada nos **151 links**; nenhum ficou abaixo do piso definido (principais ≥18, secundários ≥14). Os 7 gargalos residuais detectados na primeira medição foram reabertos.
- Walkthrough da rota principal: S1 andando a 11 (7/7 links, 26,6 s), S2 correndo a 17 (12/12, 30,4 s), S3 correndo a 17 (7/7, 17,7 s) e saída alcançada em 4,3 s; nenhum enganche.
- Cápsula temporária de 12×4×4 studs: 887 amostras em todos os links/nós, **0 falhas de Terrain e 0 de objetos**; placeholder removido.
- Performance: S1 60,2 fps (pior frame observado 31,8 ms), S2 60,2 (18,4 ms), S3 60,2 (18,5 ms). Workspace na auditoria: 4.505 BaseParts, 4.294 MeshParts, 52 emitters, 12 luzes.
- Segunda passada: 604 amostras no centro dos corredores, **0 falhas de chão**, máximo de calombo positivo ≈0,000004 stud e variação interna ≈0,000004 stud. As duas áreas futuras deram Y=2 constante em 25/25 amostras cada e foram atravessadas em Play sem bloqueio. A luz adicional manteve **60,0 fps** em 120 frames; console limpo.
- Terceira passada: largura mínima subiu de 14,2 para 20,0; 275/275 samambaias e 48/48 árvores laterais ficaram com contato exato e leve enterramento da base; núcleo central de 13 studs com **0 objetos colidíveis** e 0 falhas de chão. Um corredor de cada setor foi atravessado em Play; lanterna ligada a **60,0 fps**, console limpo.
- Entrada validada: parede/névoa locais, Lighting aplicada e uma legenda. As 4 variantes existem e a escolha determinística foi verificada; teste real com 4 clientes ainda falta.
- Lanterna: três cones ativos, ferramenta local oculta, atraso após giro de 90° caiu de 76,9° no primeiro frame para 28,5° em 0,1 s e 3,9° em 0,3 s. Mixer e `ForestSilence` também validados nos 3 setores.
- Passada 11/09 (respawn/efeito/áudio): entrada real definiu `InMaze=true` e `RespawnLocation=MazeRespawn`; após `Humanoid.Health=0`, novo personagem surgiu em `(-40, 6,5, -200)` e manteve blur 2,4, ruído/scanlines, escurecimento e parede/neblina da entrada. 60,0 fps em 120 frames, console limpo. `CanopyRustle` permanece em loop, volume 0,28; eventos florestais configurados para 8–16 s com folhagem predominante. O *feeling* do áudio e do ruído ainda não pôde ser ouvido/visto em Play via MCP.
- Vegetação adicional: 95/95 bases aterradas com erro máximo 0,08 stud; 0 parts com colisão, toque, query ou sem âncora. Amostragem em Play no começo do labirinto estabilizou em 60,0 fps após carregamento; console limpo. A composição visual ainda precisa ser julgada no Studio pelo Rick.

## Próximos passos do labirinto
**Portão de aprovação:** Rick avalia no Studio escuridão, lanterna, vegetação, áudio e identidade dos setores. Só depois: landmarks/estruturas, esconderijos, MoonWatchPoints compostos, sons reativos, randomização de chave/código e portão final.

Mapa ASCII atual e diagnóstico de jogabilidade: `../10-auditoria-labirinto-2026-09-11.md`.

## Fase 1 — entrada e aproximação (12/09, madrugada)
- **Aproximação de ~60 studs** entre o portão de rocha do acampamento (z −86) e a boca real do labirinto (−32, −146): trilha de terra sinuosa (oeste, depois norte), 19–23 studs de largura, piso descendo de 3,6 para 2,0, ladeada por 7+7 massas de rocha crescendo de 5 para 21 studs e 14 morros que fecham os campos laterais; 22 pinheiros nas cristas, 5 emissores de névoa com taxa crescente (2→4,5). Fogueira audível até 110 studs (some ao longo da trilha).
- **Gatilho `MazeEntrance` movido** de (0,10,−62) para (−32,10,−142), 26×16×6. A parede local fica em z −135 (dentro da boca de rocha, atrás da curva) e a cortina de névoa em −136 — mascarada por rocha + curva + névoa. Spawn→boca: **18 s andando** (fence→boca ≈ 9–10 s).
- **Área de leitura** na célula (4,0): cilindro r 17; **três rotas em ≈1,5 s** a partir da boca: oeste (3,0)→(2,0) com lombada suave (+0,9 stud), norte (4,1) entre 3 pinheiros jovens, leste (5,0) com curva em S escondida atrás de um afloramento (−18,−173) + 2 pinheiros. Layout: `OpenWalls` +2 (153), `DeadEnds1` = 0,3;7,1;10,2, `LinkWidths` +2, `EntryMouth`.
- `MazeRespawn` mantido em (−40, 2,5, −200) — célula (4,1), raio 4 livre, antes do S2. Morte após entrar: respawn dentro, Expo −0,58, blur 2,4, grão e parede local preservados (testado).

## Fase 2 — passada de qualidade (mesma sessão)
- Ferramenta `ServerStorage/_Tools/MazePhase2` (ModuleScript): `walls(sector, seed)`, `vegetation(sector, seed, skip)`, `wallTops(sector, seed, keepP)`. Usa raycast contra o Terrain para achar a face real da parede; nada invade o núcleo de 13 studs.
- Paredes: S1 118 saliências / 36 musgo / 16 alcovas / 8 saliências-prateleira / 9 fendas altas; S2 98/60/9/5/10; S3 143 (30 % Slate)/140/12/6/10; ~350 pedras na base.
- Vegetação: +91 pinheiros jovens nas laterais e junções (S1 29, S2 29, S3 33; escala 0,55–1,0), +246 samambaias em grupos na base das paredes (S1 82, S2 106, S3 58; S2 maiores), +184 pinheiros nas cristas (S1 40, S2 47, S3 97) para fechar o céu. Totais: `Maze/Forest` 1.201 (S1 146 topo/34 dentro · S2 166/32 · S3 286/39 · cinturão 498), sub-bosque ≈ 600. 8 emissores de névoa localizada no S2 (47 no total).
- Larguras (raycast a y 5,5/9/13, 153 links): **média 21,7, mínima 13,0** (3,0|4,0 — lombada; voxels mostram 18), máxima 44,6; principais média 25,2. Histograma: 15–17: 15 · 18–20: 73 · 21–23: 23 · 24–26: 31 · 27+: 10. **0 objetos colidíveis** no núcleo; samambaias/props sem colisão; árvores só tronco.
- Não incluído: arbusto/capim de outra família (o único candidato verificado, `9953859659`, é um arbusto seco de baixa qualidade — rejeitado); raízes (sem asset).

## Fase 3 — graybox da cabana (mesma sessão)
- `Map/Structures/AbandonedCabin` (Model, atributo `Graybox`): 24 parts WoodPlanks, footprint **18 × 22** (x 121–139, z −574…−552), célula (8,10), piso a y 3, paredes 9 studs, telhado duas águas (cumeeira y 17), porta ao sul (4,5 × 8, deslocada), **janela oeste 6 × 4** (peitoril y 6) olhando para a clareira/rocha com um pinheiro a ~40 studs — ponto forte para futura aparição; canto NE desabado; divisória em z −566 com passagem (sala 14 × 18, quarto 8 × 18); mesa, armário (atributo `FutureHidingSpot`) e prateleira placeholders; degrau na porta.
- Candidatos adicionados em `Sector3KeyCodeSpawns`: `S3Spawn07_CabinTable` (mesa) e `S3Spawn08_CabinBack` (caixa atrás da cabana), atributos `Context`. Total S3 = 8.
- Circulação testada em Play: porta → janela → passagem → quarto, R6, sem enganche.

## Testes da sessão
- Walkthrough boca→S1→S2→S3→cabana→saída pelo grafo: 33 células, **77,7 s correndo a 17**, 0 engates; corredor de saída até o marcador ok.
- FPS: medição **inválida** nesta sessão — 15 fps uniformes até no acampamento (Studio em segundo plano/throttle). Antes da passada eram 60 em todos os setores; Rick deve confirmar com a janela em foco.
- Console limpo. Lighting noturno restaurado ao final (Density do acampamento continua 0,22, como encontrado).
