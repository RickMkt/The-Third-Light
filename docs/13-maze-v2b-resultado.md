# Maze V2-B — ampliação estrutural do Setor 2 (12/09/2026)

Estado executado **no place aberto em Edit**, testado em Play e devolvido a Edit. **Aguardando Ctrl+S e avaliação do Rick.** Nenhuma estrutura foi construída; Homem Lua, chave/código, portão funcional e lógica de objetivos não foram alterados. Mapa superior técnico: [mapa-labirinto-v2b.png](img/mapa-labirinto-v2b.png). O arquivo de origem do desenho é `tools/maze_v2b_layout.json`, extraído de `Map/Maze/Layout`.

## Checkpoints anteriores à escavação

- Studio em Edit; `ServerStorage/_Backup_2026-09-12_preMazeV2B` com `Complete=true`, contendo Map, Gameplay, Shared, scripts afetados, Lighting, SoundService e `Terrain_all:TerrainRegion`.
- `backups/TheThirdLight_2026-09-12_preMazeV2B.rbxl`: 2.434.366 bytes, cabeçalho `<roblox!`, SHA-256 `74F3CCCEE2DDE07AA81E6D8D7912B94064F3EFC9AD7B1E17D1817A0D280D70AA`. É a cópia **pré-V2-B**, não o place ampliado.
- Tag Git `checkpoint-before-maze-v2b-central` → `172a3eabab60715edf516761e9829ea5aaa76829`.

## Geometria e composição

| Medida | Antes (V2-A) | Agora (V2-B) |
| --- | ---: | ---: |
| Grade | 11×12, 132 nós | 11×13, 143 nós |
| Enlaces | 165 | 183 |
| Setor 1 | 4 linhas, 70.400 studs² | igual |
| Setor 2 | 4 linhas, 70.400 studs² | 5 linhas, **88.000 studs² (+25%)** |
| Setor 3 | 4 linhas, 70.400 studs² | 4 linhas, mesma área; transladado 40 studs ao sul |
| Participação nominal do S2 | 33,3% | 38,5% |

A nova linha 5 ocupa Z=−340…−380. Ela foi integrada aos corredores superiores e inferiores com curvas, junções e 18 enlaces adicionais líquidos no grafo. O portão futuro e todos os objetos da metade sul acompanharam o deslocamento. Cinco pontos inicialmente estreitos nessa linha foram reescavados: **largura mínima central medida 20,7 studs** nos 26 enlaces que a tocam. Terreno na faixa recebeu material `LeafyGrass` para integrar o piso; 50 pinheiros e 65 samambaias foram distribuídos nas margens em `Sector2/Forest/V2B_NewBand` e `Undergrowth/V2B_NewBand`. Todas as 115 bases ficaram 0,08 stud abaixo do piso amostrado, sem flutuação; peças novas ancoradas e sem colisão.

Estimativa de piso caminhável: malha de 4 studs, raycast com Y de 0 a 8 e normal ≥0,65. As quatro linhas preservadas do S2 somam ~43.824 studs² válidos nesta amostragem; a linha nova soma ~11.936 studs², total ~55.760 (**+27,2%** sobre as quatro linhas atuais). Isto **não é área exata do navmesh** e as clareiras reescavadas nas linhas antigas impedem comparação perfeita com um snapshot V2-A.

Reservas invisíveis, sem estruturas: Cabana `(-160,-480)` 40×46; Observatório `(0,-400)` 60×64; Posto `(120,-320)` 36×40; Área Técnica `(200,-440)` 40×45. Os núcleos de 28×28 foram liberados de árvores baixas. A Área Técnica mudou para a célula (10,7). S2 tem 17 ciclos no subgrafo de suas cinco linhas; todos os seis pares de landmarks têm pelo menos duas rotas distintas por aresta, e Observatório↔Posto tem três. Os seis pares de centros têm visão direta bloqueada por Terrain na altura dos olhos.

## Tempos entre as áreas

Medidos em Play com `PathfindingService`, agente de raio 4/altura 10, sem pulo, e convertidos pelo WalkSpeed real de 11 studs/s. São **tempos de percurso calculados**, sem atraso de jogador, exploração, susto ou combate. O percurso controlado atravessou os landmarks, mas foi acelerado pela ferramenta de navegação e não serve como cronômetro.

| Percurso | Distância do Pathfinding | Caminhada calculada |
| --- | ---: | ---: |
| Cabana ↔ Observatório | 260,1 studs | **23,6 s** |
| Observatório ↔ Posto | 197,3 studs | **17,9 s** |
| Observatório ↔ Área Técnica | 227,3 studs | **20,7 s** |
| Posto ↔ Área Técnica | 180,4 studs | **16,4 s** |
| Cabana ↔ Posto | 451,9 studs | 41,1 s |
| Cabana ↔ Área Técnica | 462,8 studs | 42,1 s |

Os quatro pares de landmarks mais próximos atendem ao alvo de 15–30 s de floresta. Posto↔Área Técnica deixou de ser uma passagem de ~11 s. Os dois pares longos são propositais e oferecem escala e múltiplas rotas.

## Walkthrough, segurança e desempenho

- `PathfindingService` teve **26/26 sucessos** nos enlaces ligados à linha nova para raio 4, sem desvios >65 studs para uma conexão nominal de 40. As seis rotas entre landmarks também tiveram sucesso para raios 3 e 4. As três rotas principais verificadas com waypoint spacing 4 não pediram pulo; maior variação vertical entre waypoints consecutivos: 1,1–1,9 studs.
- Navegação controlada chegou a Observatório → Posto → Área Técnica → Cabana (o trecho longo foi dividido em etapas após a ferramenta demorar em uma chamada única) → Observatório; o personagem permaneceu vivo. Também cruzou Cabana → Setor 3. Entrada→faixa nova, faixa nova→S3 e S3→portão futuro obtiveram `Pathfinding` válido de raio 4. Uma tentativa de navegação a partir de um ponto arbitrário da aproximação do acampamento retornou `Path Blocked`; o gatilho real da boca em (−32,−142) funcionou ao ser cruzado por teste controlado. Esse bloqueio de aproximação não foi alterado nesta etapa e pede revisão separada se ocorrer no jogo normal.
- Após o gatilho, `InMaze=true`, `RespawnLocation=MazeRespawn`; morte de teste reapareceu em (−40,−200) com `InMaze` mantido, `MazeAtmosphereBlur.Size=2` e `VhsOverlay` ativo.
- Workspace em Play: 5.919 BaseParts, 5.631 MeshParts, 63 emitters, 12 luzes. A contagem inclui personagem e outros elementos de Play; os 115 modelos vegetais novos acrescentaram aproximadamente 165–180 MeshParts em relação ao levantamento V2-A.
- `Stats.Workspace.FPS` marcou 60 para a simulação. `FrameRateManager.AverageFPS` marcou ~25,4–25,5, mas a janela do Studio ficou em segundo plano e medições anteriores no projeto já sofreram throttle uniforme nessa situação. **FPS de renderização inconclusivo**; Rick deve validar em Play com Studio em foco. Não declarar meta de 60 FPS aprovada com esta leitura.
- O console não ganhou erro específico do V2-B. Apareceram três avisos de `Infinite yield possible` para InventoryGui, MovementGui e DialogueGui durante a inicialização; os três GUIs estavam presentes depois. Há ainda um aviso interno do Assistant/RemoteServiceGate. Revisar os avisos de GUI em etapa própria se persistirem.

## Avaliação visual e limites

Foi gerada captura aérea parcial em luz temporária de revisão e mapa superior técnico completo. O mapa é esquemático do grafo; o Terrain orgânico pode diferir. A nova faixa tem vegetação lateral e passagem livre, mas o encontro entre piso de terra antigo e `LeafyGrass` novo ainda pode ser perceptível a olho nu. O *feeling* de escala, densidade de copa, declive e medo precisa de avaliação do Rick no Studio. A luz voltou a `ClockTime=22,6` e a câmera de Edit foi deixada em `Fixed`, para não travar a movimentação.

**Parada de escopo:** nenhuma Cabana, Observatório, Posto ou Área Técnica foi construída. Não avançar para estruturas/IA/objetivos sem avaliação do Rick. Após aprovação visual, Rick deve usar **Ctrl+S** para a versão na nuvem e, se quiser um backup local *pós*-V2-B, **Arquivo → Salvar em arquivo como…** com outro nome. O arquivo `preMazeV2B.rbxl` deve permanecer intacto para restauração.
