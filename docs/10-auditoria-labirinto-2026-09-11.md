# Auditoria de jogabilidade do labirinto — 11/09/2026

Estado observado no place em Edit/Play. Esta auditoria distingue mudanças já aplicadas de propostas que precisam da avaliação visual do Rick. A cabana **não está construída**.

## Mapa atual

Grade de 11 colunas × 12 linhas, célula de 40 studs; entrada em cima, saída embaixo (orientação esquemática, não bússola). `o` = célula, `--` = passagem entre colunas, `|` = passagem entre linhas. `E` = entrada (4,0); `O` = clareira reservada ao observatório (5,5); `C` = clareira reservada à cabana (8,10); `G` = saída/portão futuro (7,11). As letras **não significam estrutura construída**.

```text
o--o--o--o  E  o--o--o--o--o--o
|           |  |        |     |
o--o--o--o--o  o--o  o--o--o--o
|     |           |     |  |
o--o--o--o--o--o  o  o--o  o  o
   |  |     |  |  |  |     |  |
o--o--o--o--o  o--o  o--o--o--o
            |     |
o--o--o  o--o--o  o--o--o  o--o
   |  |  |  |  |  |     |     |
o--o--o--o  o--O--o--o--o  o--o
|     |        |           |
o--o--o  o--o  o--o  o--o  o--o
|  |     |  |  |  |  |  |     |
o--o--o--o  o--o  o--o  o--o--o
   |                          |
o--o--o--o--o--o  o--o--o--o--o
|                 |  |  |  |  |
o--o--o--o--o  o--o--o--o  o  o
            |     |  |  |  |  |
o--o  o--o  o  o--o  o--C--o  o
|  |  |  |  |  |  |     |     |
o--o--o--o--o--o  o--G--o  o--o
```

Fórmula de posição: `x=-200+40*c`, `z=-160-40*r`. A cabana proposta está na clareira da célula `(8,10)`, centro `(120,2,-560)`; observatório `(5,5)`; portão futuro próximo de `(80,-670)`. O mapa completo é a lista `Map/Maze/Layout.OpenWalls` no Studio; o desenho acima representa essa lista, não uma rota obrigatória.

## Diagnóstico

- **Conectividade boa, início fraco:** 132/132 células alcançáveis e 151 ligações; 10 becos sem saída, 83 células de grau 2, 30 de grau 3, 9 de grau 4. A célula de entrada `(4,0)` tem **uma única saída** para `(4,1)`. A primeira bifurcação vem após dois links, mas a visão inicial passa por um corredor vazio e reto; a sensação é de introdução protegida, não de decisão sob ameaça.
- **Escala física suficiente, ritmo ainda vazio:** 440×480 studs e 3 setores; 24 links até a clareira da cabana e 26 até a saída a partir da entrada. A distância camp→gatilho é cerca de 92 studs e gatilho→primeira célula cerca de 105 studs. O problema percebido é sobretudo composição/visibilidade e a entrada marcada como transição, embora afastá-la mais possa ajudar.
- **Corredores transitáveis, paredes repetitivas:** larguras mínimas medidas ≥20 studs e núcleo central livre de 13. Em luz de revisão, a rocha aparece em grandes massas facetadas quase iguais, com transições abruptas e trechos de piso/sub-bosque visualmente secos. O terreno já corrigiu o calombo central; não convém reesculpir tudo.
- **Vegetação concentrada fora da leitura próxima:** antes desta passada, 920 pinheiros, mas só 48 árvores pequenas internas e 275 samambaias em 132 células (≈2,1 por célula). Foram adicionados 15 pinheiros jovens e 80 samambaias baixas, sem colisão. Ainda falta camada baixa de outra silhueta — tufos de capim/arbustos — e composição por trecho. Colocar árvores no núcleo novamente prejudicaria jogador/IA.
- **Sem loop de jogo ainda:** há 6 candidatos de objetivo no S2 e 6 no S3, mas nenhum sorteio, chave/código, portão funcional, esconderijo, watch point, IA integrada ou objetivo comunicável. Hoje o labirinto é explorável; ainda não há motivo mecânico para revisitar, se orientar e sobreviver.
- **Cabana:** apenas marcador invisível e proposta em `estruturas/cabana-abandonada.md`. Não há geometria no place. Ela precisa de aprovação do graybox antes da construção, conforme `AGENTS.md`.
- **Efeito/áudio:** o tratamento anterior era muito discreto; nesta passada blur/grão e sons de folhas foram aumentados e respawn persistente validado tecnicamente. O teste via MCP não permite julgar imagem e audição reais em Play; Rick deve validar se a intensidade está confortável.

## Mudanças feitas nesta passada

1. `MazeRespawn` em `(-40,2,5,-200)`; servidor grava `InMaze` e `RespawnLocation` na travessia. Morte real em Play recolocou o jogador dentro e manteve parede, neblina, escurecimento, blur e ruído.
2. Blur persistente `1,5→2,4`, pontos de ruído `36→256`, opacidade de pontos maior, 5 scanlines; teste técnico a 60 fps/console limpo.
3. Copas em loop `0,20→0,28`; eventos florestais `12–30→8–16 s`, folhagem com peso 6/11; teste de estado do som em Play.
4. `VegetationAccent_20260911` separado no Studio: 80 samambaias baixas + 15 pinheiros jovens, todos assentados com 0,08 stud de enterramento, 0 colisão/toque/query. Teste em Play no começo do labirinto estabilizou em 60 fps após carregamento; console limpo. Não substitui uma passada artística com capim/arbusto aprovado.

## Proposta em ordem de impacto

1. **Entrada/primeiro minuto (graybox para aprovação):** alongar a aproximação a partir do camping em ~40–60 studs com curva e linha de visão quebrada; transformar `(4,0)` em junção de pelo menos 3 escolhas sem visão completa das saídas; primeiro retorno curto e um desvio recompensador, não um corredor tutorial. A proximidade do monstro deve vir de som/silhueta/oclusão antes de qualquer perseguição real, cujo comportamento ainda depende de aprovação. Reavaliar gatilho, fechamento local, colisão, fog e respawn juntos. Isso altera a floresta/terreno da borda norte do camp e pede checkpoint anterior.
2. **Vegetação:** compor 2–3 famílias visuais no total: pinheiro existente (adulto e jovem), samambaia existente e novo kit de capim/arbusto baixo aprovado. Distribuir em *clusters* irregulares nas laterais e clareiras, usando raycast no piso, verificação de inclinação/sobreposição, leve enterramento de base e 13 studs centrais livres; somente troncos essenciais com colisão simples. Amostrar cada setor em Play e testar a cápsula de perseguição.
3. **Paredes e piso:** manter o grafo/largura, mas quebrar repetição com saliências rasas, fendas, duas escalas de rocha, raízes/musgo e variação de cor/material. Priorizar 10–15 trechos de maior visibilidade em vez de detalhar 151 links por igual. Evitar boulders esféricos, rocha flutuante e volumes que criem enganches ou coberturas falsas.
4. **Objetivo mínimo:** chave física no S2 e pista/código no S3 sorteados entre marcadores já existentes; portão de saída comunica necessidade organicamente; reentrada após morte preserva progresso de modo definido. Primeiro validar uma partida completa, depois inserir pressão do Homem Lua.
5. **Landmarks:** aprovar e construir graybox da cabana (S3) e, depois, observatório (S2), ambos sem zona segura; testar circulação nas quatro aproximações. Eles orientam sem transformar o lugar em parque temático.
6. **Ameaça e legibilidade:** após a aprovação do modelo/comportamento, usar grafo para Watch/Chase; pontos de observação e esconderijos reais só onde as rotas de fuga forem testadas. Sinais visuais/sonoros de ameaça devem permitir decisão, não antecipar jumpscare constante.

## Critérios para a próxima validação

- Rick consegue sair do camp e escolher entre ≥3 rotas em até ~10 s após cruzar a entrada, sem ler UI explicativa.
- Uma volta curta pode devolver a uma referência reconhecível; nenhuma rota crítica fica bloqueada por vegetação ou decoração.
- Jogador e cápsula do Homem Lua atravessam os corredores; 0 vegetação/rocha sem apoio e 0 enganche; console limpo e alvo de 60 fps.
- O efeito é perceptível em Play sem encobrir pistas/lanterna; som de folhas presente e não repetitivo. Ajuste final depende do *feeling* do Rick.
- Partida tem objetivo testável do início ao portão, mesmo sem IA, antes de receber perseguição.
