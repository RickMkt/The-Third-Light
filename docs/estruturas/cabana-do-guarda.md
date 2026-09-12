# Cabana do Guarda (Ranger Cabin) — graybox V2-B1

> Estado: **graybox construído em 12/09/2026, aguardando avaliação do Rick.** Sem art pass, sem decoração, sem lore, sem porta física, sem vidro. Place: `Workspace/TheThirdLight/Map/Maze/Sector2/Structures/RangerCabin` (48 peças, todas ancoradas). Checkpoint antes: `ServerStorage/_Backup_2026-09-12_preV2B1_cabinArea` (clones da vegetação da zona + Moon Point original) e tag Git `checkpoint-before-v2b1-cabin`.
> A cabana antiga do S3 (`_Archive_2026-09-12_CabinS3_forV2B`, 34×42, 90 peças) foi usada **só como referência** (alpendre, empenas em cunha); é grande demais e foi desenhada para outra clareira. Não foi restaurada.

## Avaliação da clareira (célula 1,8 · reserva `FutureStructures/RangerCabin` 40×46 em (−160, −480))
- Na prática a área livre é um **gramado de ~27×14 studs** (x −173…−146, z −466…−452) entre um **pedregulho natural** a oeste (x < −176, 10–27 studs de altura) e a **parede de rocha** a leste (x > −146), mais os corredores: linha 7 ao norte (z −440), linha 8 ao sul (z −480), coluna 0 a oeste (x −200) e a **passagem S2→S3** ao sul (x −175…−148, z −492…−508).
- Chão plano (y 2,0–2,45) em toda a pegada. Nenhum corredor foi estreitado; nenhum núcleo de 13 studs tocado.

## Implantação
- **20 × 18 studs** (x −168…−148, z −470…−452), centro (−158, −461). Costas (parede leste, cega) encostadas na rocha. Paredes 0,7; piso a y 3,2 (0,8 sobre fundação de pedra); pé-direito 8,4; telhado de duas águas com cumeeira a y 15,8 e empenas em cunha; beiral 1 stud.
- **Porta ao norte** (x −166…−162, 4×7), alpendre 8×3,2 com dois postes, cobertura inclinada 12° e rampa de 2,6 studs (25°). Voltada para o corredor da linha 7 — quem chega pelo S2 vê a frente.
- **Janela da Lua ao sul** (x −165,5…−161,5; sill y 5,8, verga y 9,6) — alinhada com a porta: quem entra e olha em frente enxerga através dela a **boca da passagem S2→S3**. `FutureMoonPoints/S2_Stalk_CabinWindowView` movido de (−186, 3, −506) (estava dentro da rocha) para **(−162, 3, −499)**, no chão da passagem, a 29 studs da janela, com linha de visão limpa. Testado com placeholder de 11,5 studs (`ServerStorage/_Dev_MoonManPlaceholder`): da porta (17 studs) a figura preenche a janela com a cabeça encostando na verga; de dia lê inteira; **de noite só a cabeça pálida aparece flutuando no vão** — composição funciona, precisará de luar/rim light na passagem no art pass.
- **Janela oeste** pequena (z −463,5…−460,5) para a brecha do pedregulho; **janela norte** pequena (x −154,5…−151,5) ao lado do alpendre.
- Interior: **sala principal 13×16** + **quarto dos fundos 6×8** no canto sudeste (x −154…−148, z −470…−462) com uma única passagem de 3×6,6 no lado norte — futuro esconderijo (`HidingSpots/S2_CabinBackRoom`). Candidato de objetivo `ObjectiveCandidates/Sector2/S2Spawn07_CabinTable` movido para dentro (−165, 4, −464,5), ao lado da janela.

## Circulação
- Uma entrada (norte). Segunda saída **não** foi adicionada: arquitetonicamente não há motivo, e o exterior contorna fácil: linha 7 → coluna 0 → linha 8 → brecha entre o pedregulho e a parede oeste da cabana (5 studs, só jogador; o Homem Lua de 4 studs não passa — teste de Blockcast 4×10 bate na rocha em z −459) → volta à linha 7. Loop de perseguição em torno do bloco pedregulho+cabana.
- Teste em Play: 3 rigs R6 parados dentro + jogador: alpendre → porta → janela → quarto → sala → fora, e a volta completa pelo loop a 17 studs/s, tudo `MoveToFinished = true` (os únicos timeouts foram alvos a 1 stud da rampa; refeitos com alvo mais longe, ok). Lanterna equipada dentro: 4 cones ativos. Console limpo.
- Ainda parece pequena com 4 dentro: sala de 13×16 comporta quatro R6 em pé sem sobreposição, mas não dá para correr em círculo.

## Vegetação
- Preservados 20 dos 24 modelos da zona. Movidos (e re-aterrados por raycast): 2 samambaias que estavam na linha das paredes → (−172, −466) e (−146, −472); 2 pinheiros cujas caixas de colisão fechavam a boca norte da brecha (5×5 e 8×8 studs) → um para o **topo do pedregulho** (−183, 28, −460), outro para o canto nordeste junto à rocha (−143,5, 2, −452,5). A cabana continua com pinheiros no canto NE e no alto do pedregulho; a rocha a envolve por leste e sul.

## Não feito nesta fase (por regra)
Textura final, decoração, lore/documentos, sangue, corpos, jumpscare, Homem Lua funcional, Key/Code reais, hiding system, porta com dobradiça, vidro, luz interna, chaminé. Capturas: `Cabin_NW`, `Cabin_Front_Row7`, `Cabin_South_FromPassage`, `Cabin_MoonWindow_FromDoor2`, `Cabin_MoonWindow_Night_Flashlight` (tomadas via MCP em 12/09).
