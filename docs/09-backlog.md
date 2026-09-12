# 09 · Backlog priorizado

## Agora (acampamento — pequenos ajustes possíveis antes do Setor 1)
- [ ] Rick: `Lighting.Technology = Future`; `Ctrl+S`; *Salvar em arquivo como…* para atualizar `TheThirdLight.rbxl`.
- [ ] Gravar as falas (voz): entrada do labirinto (+ 2–3 futuras) → `DialogueConfig.VoiceId`.
- [ ] Opcional: folha de anotações abrindo grande na tela ao apertar E.
- [ ] Opcional: "geologia" nas rochas da entrada (estratos, fenda, raízes, pinheiros pequenos nas cristas).

## Concluído — PASSADA DE QUALIDADE no labirinto (aguardando aprovação do Rick)
Sem estruturas novas, sem Homem Lua, sem chave/código, sem portão. Backup antes (Edit → Ctrl+S → checkpoint → commit).
1. [x] Larguras: média 20,4; mínimo 14,0; principais média 22,9/mínimo 19,4; bifurcações até 28,7.
2. [x] Floresta presa entre rochas: grupos autorais, sub-bosque, caminhos gastos e manchas irregulares de vegetação nas paredes.
3. [x] Escuridão local legível: Exposure −0,58 e Atmosphere revisada.
4. [x] Lanterna: 3 cones revisados, inércia exponencial e sway por estado de movimento.
5. [x] Áudio: vento, copas, cama fria, eventos 3D e gancho de silêncio por setor.
6. [x] Quatro falas de entrada em inglês, uma por jogador, com legenda e `VoiceId` vazio.
7. [x] Identidade sutil: S1 mais aberto, S2 mais denso, S3 mais alto e com cama sonora reduzida.
8. [x] Performance/colisão: 928 árvores, 41 emissores, decoração sem colisão, 60 fps nos 3 setores.
9. [x] Walkthrough até a saída, cápsula 3,5–4 m, lanterna/áudio/legenda e relatório final. **Parar e aguardar aprovação.**

## Próxima fase — LABIRINTO (após aprovação da passada de qualidade)
1. Rick avalia o resultado (escuridão, largura, paredes, vegetação, lanterna, áudio).
2. Criar landmarks internos que reforcem as identidades já preparadas (posto de vigia/torre arruinada no S2 etc.).
3. Esconderijos (armários/ruínas) e MoonWatchPoints compostos por setor.
4. Randomização de chave/código nos candidatos (`FutureObjectiveSpawns`), portão final no `FutureGateMarker`.
5. Sons pontuais reativos no labirinto (galho atrás de quem fica parado; folhagem se aproximando).

## Depois
- Setor 2 e 3 (chave/código randomizados; spawn points; esconderijos de armário) → portão → trilha final → casa (hall + 1–2 cômodos + porta de porão; teaser Homem Estrela).
- Homem Lua: modelo/rig/animações (Rick) → Watch → Stalk → Approach → Chase → Hiding/Search → Capture → final.
- CarryItem (componentes grandes presos ao personagem).
- Replicar respiração/batimento para os outros jogadores; bateria da lanterna (consumo + luz enfraquecendo).
- Teste com 2+ clientes (Test → Clients and Servers). Passos com gravações licenciadas. Objetivo discreto na UI ("Entre na floresta").
