# 09 · Backlog priorizado

## Agora (acampamento — pequenos ajustes possíveis antes do Setor 1)
- [ ] Rick: `Lighting.Technology = Future`; `Ctrl+S`; *Salvar em arquivo como…* para atualizar `TheThirdLight.rbxl`.
- [ ] Gravar as falas (voz): entrada do labirinto (+ 2–3 futuras) → `DialogueConfig.VoiceId`.
- [ ] Opcional: folha de anotações abrindo grande na tela ao apertar E.
- [ ] Opcional: "geologia" nas rochas da entrada (estratos, fenda, raízes, pinheiros pequenos nas cristas).

## Em andamento — PASSADA DE QUALIDADE no labirinto (pedido de 11/09)
Sem estruturas novas, sem Homem Lua, sem chave/código, sem portão. Backup antes (Edit → Ctrl+S → checkpoint → commit).
1. Larguras: principais 18–24 (26–28 em bifurcações), secundárias 15–20, apertos ≥ 13–14, núcleo limpo 10–12; ritmo de larguras; nada atravessado nas rotas (criatura de 3,5–4 m).
2. Floresta presa entre rochas: árvores autorais (bordas, bolsões, clareiras, topos, reentrâncias, futuros watch points), sub-bosque (samambaia, grama, arbusto, raiz, musgo, pedra, lama), vegetação nas paredes irregular.
3. Escuridão legível: testar Exposure −0,45…−0,7 (em vez de −0,95), rever Brightness/Ambient/OutdoorAmbient/Atmosphere; manchas frias de luar onde a copa abre.
4. Lanterna: investigar por que não ilumina paredes (parent, sombras, Technology, ângulo, oclusão) antes de subir brilho; revelar paredes a 30–45, foco 50–60; feixe suave; inércia por deltaTime; sway andando/correndo; sem blur ao girar.
5. Áudio em camadas: vento base, copas, cama fria, eventos 3D aleatórios, ganchos de silêncio; volumes não cobrem passos/respiração.
6. Falas de entrada: 4 linhas em inglês (uma por jogador), legenda 2,5–4 s; sistema VoiceLine + `SoundId` placeholders documentados (melhor sem voz do que voz ruim).
7. Identidade sutil dos setores (S1 aberto, S2 denso, S3 antigo/alto/silencioso).
8. Performance (rever ~1.740 árvores do cinturão e 71 emissores) e auditoria de colisão (sem paredes invisíveis no labirinto).
9. Walkthrough, cápsula placeholder 3,5–4 m, testes de lanterna/áudio/legenda, relatório de 20 itens + notas 0–10 → **parar e aguardar aprovação**.

## Próxima fase — LABIRINTO (após aprovação da passada de qualidade)
1. Rick avalia o resultado (escuridão, largura, paredes, vegetação, lanterna, áudio).
2. Diferenciar setores visualmente (S1 mais aberto, S3 mais fechado/alto; posto de vigia em ruínas no S2).
3. Esconderijos (armários/ruínas) e MoonWatchPoints compostos por setor.
4. Randomização de chave/código nos candidatos (`FutureObjectiveSpawns`), portão final no `FutureGateMarker`.
5. Sons pontuais reativos no labirinto (galho atrás de quem fica parado; folhagem se aproximando).

## Depois
- Setor 2 e 3 (chave/código randomizados; spawn points; esconderijos de armário) → portão → trilha final → casa (hall + 1–2 cômodos + porta de porão; teaser Homem Estrela).
- Homem Lua: modelo/rig/animações (Rick) → Watch → Stalk → Approach → Chase → Hiding/Search → Capture → final.
- CarryItem (componentes grandes presos ao personagem).
- Replicar respiração/batimento para os outros jogadores; bateria da lanterna (consumo + luz enfraquecendo).
- Teste com 2+ clientes (Test → Clients and Servers). Passos com gravações licenciadas. Objetivo discreto na UI ("Entre na floresta").
