# Plano oficial de execução — 11/09/2026

Fonte: instrução direta do Rick anexada à tarefa. Este documento resume a ordem e os portões; em caso de dúvida sobre detalhes, consultar a solicitação original. **Não avançar automaticamente entre fases grandes.**

| Fase | Entrega | Portão |
|---|---|---|
| 1 | Redesenhar aproximação e primeira decisão do labirinto | Testar entrada, 2–3 escolhas em até 20 s, retorno mascarado, morte/respawn; registrar e aguardar Rick |
| 2 | Qualidade de largura, paredes, vegetação e identidade S1/S2/S3 | Walkthrough, cápsula de perseguição, métricas, FPS, capturas; registrar e aguardar Rick |
| 3 | Graybox da cabana no S3 | Interior simples, janela para futura aparição, circulação multiplayer, placeholder de objetivo; registrar e aguardar Rick |
| 4 | Chave + código + portão funcional | Sorteio somente em 6+6 candidatos S2/S3, posições distintas, teste com 2+ clientes |
| 5 | Poucos landmarks e 4–6 esconderijos úteis | Cada um justificado por exploração/objetivo/ameaça |
| 6 | Homem Lua como presença: Watch | Modelo/rig do Rick, pontos compostos e teste em primeira pessoa |
| 7 | Stalk / Approach | Aproximações calibradas, sem chase constante |
| 8 | Chase / Search / Capture | Grafo do labirinto para navegação macro, critérios de captura/escape |

## Fase 1 — direção aprovada; implementação pendente de checkpoint

- Antes de Terrain: Studio em **Edit**; Rick faz `Ctrl+S` e salva `.rbxl` atual em `backups/`; confirmar backups anteriores; snapshot interno `ServerStorage/_Backup_*` das áreas afetadas + `Terrain:CopyRegion`; checkpoint Git. Não apagar backups.
- Aumentar em **40–60 studs** a aproximação entre o acampamento e o ponto real de não retorno. A mudança deve ser psicológica e espacial: trilha curva, rocha/mata começando aos poucos, camp distante, neblina e som de folhas; sem corredor reto.
- Primeira decisão: **2–3 rotas reais em 10–20 s**, sem Y simétrico. Uma pequena área de leitura com linhas de visão interrompidas; preparar lugares de silhueta sem colocar o Homem Lua.
- Barreira por jogador deve ficar mascarada por curva, rocha, vegetação e fog. Preservar `InMaze`, efeitos locais, áudio e respawn dentro após a primeira entrada; reposicionar `MazeRespawn` somente se o novo terreno exigir.
- Proposta técnica mínima para testar: levar o gatilho atual de `z=-62` para cerca de `z=-110` (ajustar à curva final), ampliar a leitura da célula de entrada `(4,0)` e abrir duas ligações laterais já adjacentes à rede `(3,0)` e `(5,0)`, mantendo a saída atual para `(4,1)`. Confirmar o grafo real no place antes de escavar. Largura-alvo 18–24 studs e núcleo transitável 10–12. A barreira local não deve ficar atravessada numa curva perceptível.
- Após implementar: testar acampamento→entrada, tempo até escolha, tentativa de retorno, morte/respawn, caminhada/sprint no S1; capturas de Edit com luz de revisão e noite restaurada; console e FPS. **Parar para avaliação.**

## Fase 2 — escopo posterior

Não reconstruir o mapa. Selecionar trechos repetitivos de Terrain; variar altura/recuos/fendas/musgo e compor árvores, samambaias, arbustos e capim nas laterais, topo e clareiras, sem flutuação nem colisão decorativa. S1 mais aberto; S2 mais fechado/curvo; S3 mais alto/antigo/silencioso. Metas: principais 18–24, secundários 15–20, apertos ≥13–14, núcleo limpo 10–12. Medir os 3 setores, todos os links críticos e cápsula de 3,5–4 m; parar para avaliação.

## Fase 3 — graybox posterior

Cabana pequena de vigilância no S3, célula `(8,10)`, próximo a `(120,-560)`, cerca de **18×22 studs** (esta medida substitui a proposta preliminar 30×18). Entrada, sala principal, cômodo menor, mesa/armário placeholders e janela orientada para um ponto interessante da floresta. Sem chave/código funcionais, IA ou esconderijo funcional nesta fase. Testar R6, multiplayer e circulação externa; parar para avaliação.

## Restrições contínuas

Preservar lanterna e áudio atuais salvo falha medida. Não colocar Homem Lua, chave, código, portão funcional, observatório, torre nem casa final durante as fases 1–3. Ao terminar cada fase, atualizar mapa técnico e relatório com distâncias/tempo, escolhas, larguras, vegetação, BaseParts/MeshParts, respawn, FPS por setor, bugs, rotas problemáticas, possíveis WatchPoints, capturas e notas críticas 0–10. Nunca salvar/publicar o place por automação; o Rick faz os saves.
