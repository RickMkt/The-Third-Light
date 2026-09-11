# 08 · Registro de decisões (ADR curto)

Formato: data · decisão · motivo · consequência.

- **11/09 · Rig R6 via `StarterCharacter`** — o Game Settings não é acessível por script e o Rick não achou a opção; um rig R6 em `StarterPlayer` força R6 para todos. Consequência: todos com o mesmo corpo neutro (coerente com "personagens fixos"); para voltar a avatares, apagar o StarterCharacter e usar Game Settings → Avatar → R6.
- **11/09 · Walk 11 / Sprint 17** (de 10/15) — pedido do Rick por mais velocidade mantendo sensação humana.
- **11/09 · Lanterna (feixe) em vez de lampião como luz principal** — o Rick prefere a estética do lampião (luz só ao redor), mas escolheu a lanterna para o item do jogador; o lampião fica como prop aceso nos postes. Ambos existem como Tools.
- **11/09 · Feixe da lanterna preso à câmera para quem segura** — a luz presa à mão balançava com a animação do braço; para os outros continua na mão.
- **11/09 · Sem reverb** — Forest reverb soava como eco em área aberta.
- **11/09 · Passos sincronizados ao head bob** — coerência som/imagem; a Roblox cria os sons padrão por CoreScript, por isso são silenciados no cliente em vez de sobrescritos.
- **11/09 · Direção do mapa mudou para linear em setores** (acampamento → labirinto em 3 setores → portão → casa) — o mapa de POIs espalhados foi abandonado após o graybox; arquivado. Motivo: foco, controle de progressão do Homem Lua, validação por partes.
- **11/09 · Chave e código randomizados por rodada** — evitar memorização; só nos Setores 2/3; nunca no mesmo ponto.
- **11/09 · Área jogável começa pequena (650² no graybox anterior; acampamento ~84×74 agora)** — validar gameplay antes de floresta enorme; distância se faz com neblina, curvas, elevação, som, Homem Lua e stamina.
- **11/09 · Backups em três camadas** (snapshot interno + `.rbxl` + Git) antes de qualquer destruição — regra permanente.
- **11/09 · Acampamento como "relativamente seguro", nunca confirmado** — `CampBoundary`/limites existem só na lógica; sem UI.
- **11/09 · Entrada do labirinto fecha atrás do jogador (parede local + névoa)** — reforça o "não dá para voltar"; por jogador para não prender quem ficou no acampamento.
- **11/09 · Placeholders em parts são aceitáveis só quando não existe asset bonito** — o Rick pediu preferência a assets do Creator Store; buscas feitas para mesa, rádio, cerca, placa, mochila, poste, toco; mantidos em parts: cerca rústica, placa, postes de madeira, varal.
- **11/09 · Lighting.Technology = Future é decisão do Rick** (não acessível por script) — recomendado.
- **11/09 · Labirinto gerado por grade + DFS por setor, escavado em Terrain Rock** — permite um corpo grande (440×480) com controle de progressão (2 passagens entre setores) e paredes orgânicas; o `Layout` fica em atributos para o Homem Lua navegar pelo grafo (o navmesh do PathfindingService não cobre tudo).
- **11/09 · Escuridão do labirinto é local (cliente)** — ao entrar, a Lighting do jogador é escurecida em 6 s; o acampamento continua iluminado para quem ficou. Lanterna invisível na mão em 1ª pessoa, feixe com inércia e 3 cones.
- **11/09 · Sem paredes invisíveis no labirinto** — contenção por rocha e cinturão de mata; paredes invisíveis só no acampamento (sul e lados).
