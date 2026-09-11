# Labirinto — corpo (Setores 1–3)

Construído em 11/09/2026. Só o corpo: sem chave/código, sem portão, sem Homem Lua, sem esconderijos funcionais.

## Geometria
- Grade **11 colunas × 12 linhas**, célula de **40 studs**; `Layout` (Configuration em `Map/Maze`) guarda tudo em atributos: `Cols, Rows, Cell, X0=-200, Z0=-160, EntryCol=4, ExitCol=7, Passages12="4,6", Passages23="1,10", OpenWalls` (lista `c,r|c,r;…`), `Clearings` (`2,2;8,1;5,5;1,7;8,10`), `DeadEnds1..3`.
- Centro da célula: `x = -200 + c*40`, `z = -160 - r*40` (norte = −Z). Setor 1 = linhas 0–3, Setor 2 = 4–7, Setor 3 = 8–11.
- Geração: DFS aleatório **por setor** (seed 2027) + 9 laços extras; **2 passagens** entre S1→S2 (colunas 4 e 6) e S2→S3 (colunas 1 e 10); 5 clareiras circulares (raio 27) com todas as paredes abertas.
- Entrada: corredor do camping (−24,−110) → célula (4,0) em (−40,−160). Saída: célula (7,11) → corredor até o marcador `Gameplay/Interactions/FutureGateMarker` em (80, −670).
- Paredes: bloco de **Rock** 500×28×520 (y −2…26) escavado com Air; **núcleo garantido** de 12 studs de largura × 20 de altura em todos os corredores/células (14 nos trechos que ficaram apertados); 859 saliências (`FillBall` r 3–6,5 a 2–21 de altura), 314 calotas de musgo, 304 pedras/lama na base, topo irregular. Chão: LeafyGrass com faixa central Ground; lama nas clareiras.
- Tamanho: 440 × 480 studs (mais entrada/saída). Tempos (andando 11 studs/s): entrada → fim do S1 ≈ 43 s; → meio do S2 ≈ 60 s; → meio do S3 ≈ 109 s; correndo ~65%.

## Vegetação e cenário (`Map/Maze/*`)
- `Forest`: ~540 pinheiros nos topos das paredes, ~120 mudas (0,45–0,8) nas bordas dos corredores, 20 nas clareiras, ~1.740 no cinturão de contenção (x além de ±238 e z < −655, espaçamento 10, escala 1,1–1,6) — **sem paredes invisíveis no labirinto**; a contenção é rocha + mata fechada.
- `Undergrowth`: ~370 samambaias (asset `7979002756`, escala 0,14–0,24) nas bordas e clareiras.
- `Props`: ~48 troncos caídos (orientados ao longo do corredor, nunca atravessados) e ~39 pedras.
- `Mist`: 71 emissores (uma célula sim, outra não + clareiras).
- Tudo o que caía dentro do núcleo de 12 studs foi removido (2 passes, 552 objetos).

## Marcadores (`Gameplay/`)
- `Sectors/Sector1..3`: zonas invisíveis (atributos `Sector`, `Rows`) para o director do Homem Lua e regras de chave/código.
- `FutureObjectiveSpawns/Sector2KeyCodeSpawns` (6) e `Sector3KeyCodeSpawns` (6): candidatos (becos sem saída primeiro), atributos `Cell`, `Sector`. **Randomização ainda não implementada.**
- `Interactions/FutureGateMarker`: onde o portão final vai ficar.

## Escuridão e entrada
- Ao cruzar `MazeEntrance`: `MazeEntryController` (cliente) fecha a volta (parede local + cortina de névoa + blur) **e** escurece a Lighting local em 6 s: `Brightness 0.55`, `Expo −0.95`, `Ambient (6,7,11)`, `OutdoorAmbient (14,17,27)`, Atmosphere densidade 0,78 / haze 11 / offset 0,55 / cor (58,64,82). Quem fica no acampamento mantém a luz do acampamento. Respawn restaura.
- A lanterna vira essencial: invisível na mão em 1ª pessoa; feixe em 3 cones (18°/2,2 com sombras, 36°/0,9, 74°/0,35), origem no olho, **rotação com inércia** (`RotationLag 7`) e deriva de mão (`SwayAmount 0,35°`).

## Testes feitos
- Todos os 151 links do layout foram caminhados/testados: geometria 100% passável (MoveTo). O `PathfindingService` falha em 4 links da coluna 10 e no corredor de saída por limite do navmesh, **não** por bloqueio — o Homem Lua deve navegar pelo **grafo do Layout**, não pelo PathfindingService.
- 60 fps no Setor 2 com lanterna e sombras depois de o Studio estabilizar (logo após gerar terreno o Studio fica 10–20 s a 15 fps — não é o jogo).
- Parede local funciona (entra, não volta); escurecimento aplicado; lanterna oculta (LTM 1), feixe alinhado.

## Próximos passos do labirinto
Estilo aprovado? → esconderijos (ruínas/armários) por setor, MoonWatchPoints (12–16 por setor, compostos), sons pontuais reativos, randomização de chave/código, portão final, marcos visuais por setor (posto de vigia em ruínas no S2), pequenas variações de largura/altura por setor (S3 mais fechado e mais alto).
