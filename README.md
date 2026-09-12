# THE THIRD LIGHT (A Terceira Luz)

Jogo de **terror psicológico multiplayer (1–4 jogadores, máximo 4)** para Roblox, em primeira pessoa.
Três entidades ligadas a corpos celestes — **Homem Lua**, **Homem Estrela**, **Homem Sol** — uma por temporada.
A Temporada 1 é a floresta e o Homem Lua.

Filosofia em uma frase: **fazer o básico extremamente bem** — atmosfera, som, luz, silhueta,
comportamento das entidades, câmera, timing, pacing. Nada de jumpscare de PNG, nada de
"AI slop", nada de sistema que não melhore exploração, suspense ou objetivo.

- Place publicado: **A Terceira Luz** — grupo Necrovale — `PlaceId 86901786058243`
- Engine: Roblox Studio + Luau (`--!strict`) · Rig: **R6** (via `StarterPlayer/StarterCharacter`)
- Ferramentas: Claude Code / Codex via **Roblox Studio MCP** (edição, testes e captura direto no Studio)
- Dono: Rick · Idioma do projeto: português (código em inglês)

---

## Como usar este repositório

| Pasta / arquivo | O que é |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Instruções para agentes (Codex/Claude): regras, fluxo de trabalho, o que nunca fazer |
| [`docs/00-visao.md`](docs/00-visao.md) | Conceito, filosofia, sensação-alvo |
| [`docs/01-estado-atual.md`](docs/01-estado-atual.md) | **Comece aqui.** O que existe, o que funciona, pendências |
| [`docs/02-regras-de-desenvolvimento.md`](docs/02-regras-de-desenvolvimento.md) | Processo, portões, backup, MCP, mapa, assets, código, performance, testes, relatório |
| [`docs/03-arquitetura.md`](docs/03-arquitetura.md) | Hierarquia do place, scripts, remotes, configs |
| [`docs/04-mecanicas-e-gameplay.md`](docs/04-mecanicas-e-gameplay.md) | **Como o jogo deve ser**: jogador, stamina, inventário, lanterna, rodada, setores, chave/código, Homem Lua, áudio, luz, multiplayer |
| [`docs/05-mapa-temporada-1.md`](docs/05-mapa-temporada-1.md) | Estrutura do mapa da Temporada 1 |
| [`docs/06-homem-lua.md`](docs/06-homem-lua.md) | Brief de design do Homem Lua (visual, rig, animações, camadas, director) |
| [`docs/07-assets.md`](docs/07-assets.md) | Registro de todo asset usado (ID, criador, licença, observações) |
| [`docs/08-decisoes.md`](docs/08-decisoes.md) | Registro de decisões (ADR curto) |
| [`docs/09-backlog.md`](docs/09-backlog.md) | Backlog priorizado |
| [`docs/sistemas/`](docs/sistemas) | Um doc por sistema implementado (movimento, inventário, áudio, diálogo, acampamento, labirinto) |
| [`lore/`](lore) | Universo, entidades e temporadas — o que está decidido e o que está em aberto |
| [`skills/`](skills) | Playbooks reutilizáveis (Studio via MCP, inspeção de assets, terreno/floresta, luz noturna, testes, checkpoint) |
| [`src/`](src) | **Código-fonte exportado do Studio** (Luau). A verdade viva está no place; este espelho é atualizado a cada checkpoint |
| `backups/` | Cópias `.rbxl` de checkpoints |
| `TheThirdLight.rbxl` | Último save em arquivo (o place na nuvem é o principal) |

Ordem de leitura para um agente novo: `AGENTS.md` → `docs/01-estado-atual.md` → `docs/02-regras-de-desenvolvimento.md` → `docs/04-mecanicas-e-gameplay.md` → `docs/09-backlog.md`.

---

## O jogo em 1 minuto

- Até 4 amigos acordam em um **acampamento** à noite. Fogueira, barracas, um rádio antigo, anotações na mesa dizendo para pegar a lanterna e seguir a trilha fechada.
- Ao cruzar a **entrada do labirinto** (formações de rocha), a névoa fecha atrás de cada jogador. Não dá para voltar.
- O labirinto é uma **floresta presa entre rochas**, em 3 setores. No **Setor 1** o Homem Lua só observa entre as árvores. No **Setor 2** ele começa a perseguir. O **Setor 3** é o mais antigo e perigoso.
- Em algum lugar dos setores 2 e 3 estão uma **chave** e um **código**, sorteados a cada rodada. O **portão final** precisa dos dois.
- Depois do portão: uma trilha, uma casa, e o teaser do **Homem Estrela**. Fim da Parte 1.
- Não existe HP, combate, minimapa ou marcador. Existe stamina, respiração, coração, visão embaçada, uma lanterna e os amigos.

## Estrutura da Temporada 1

```
ACAMPAMENTO (spawn, única zona relativamente segura)
   ↓ entrada do labirinto (fecha atrás do jogador)
SETOR 1  — Homem Lua só observa
SETOR 2  — Homem Lua começa a perseguir · chave/código podem aparecer
SETOR 3  — zona mais perigosa · chave/código podem aparecer
   ↓ PORTÃO FINAL (precisa de CHAVE + CÓDIGO, randomizados por rodada)
TRILHA FINAL → CASA → teaser do Homem Estrela → fim da Parte 1
```

**Estado (11/09/2026):** fundação do jogador, acampamento e corpo do labirinto (3 setores, vegetação,
escuridão local, lanterna) estão construídos e testados. Em andamento: passada de qualidade no
labirinto (larguras, vegetação autoral, escuridão legível, lanterna, camadas de áudio, falas de entrada).
Ainda não existem: chave/código, portão, casa, Homem Lua. Detalhes em `docs/01-estado-atual.md`.

---

## Regras gerais de desenvolvimento (resumo — completo em `docs/02`)

1. **Processo fixo:** entender → definir → versão mínima → testar no Studio → corrigir → polir → relatar e **parar**. Por camadas e parte por parte do mapa.
2. **Portões de aprovação** do Rick: graybox de área nova, passada de qualidade, loop de gameplay, modelo do Homem Lua, Watch, Chase, final.
3. **Backup antes de destruir:** Edit confirmado → Ctrl+S → snapshot `ServerStorage/_Backup_*` (com TerrainRegion) → `.rbxl` → commit. Nunca apagar backups.
4. **Edições em Play não persistem.** Confirmar `get_studio_state = Edit` antes de construir; após reconexão do Studio, re-verificar o que persistiu.
5. **Assets sempre inspecionados** (`Probe_*` em ServerStorage: scripts removidos, escala, colisão, licença) e registrados em `docs/07-assets.md`. Máximo 2–3 famílias visuais por área. Sem colagem, sem assets ripados, sem monstro pronto.
6. **Código:** `--!strict`; configs em `ReplicatedStorage/Shared/*Config`; cliente = visual/input, servidor = estado; um render loop por sistema; `deltaTime` sempre; sem prints/warnings; respawn sem leaks; `src/` espelhado a cada checkpoint.
7. **Mapa:** não é mundo aberto; sem paredes invisíveis no labirinto; sem texto meta ("safe zone", "season 2"); tudo orgânico; pensar no Homem Lua de 3,5–4 m (largura mínima 13–14 studs).
8. **Performance:** 60 fps no Studio com área completa; decoração sem colisão; poucas luzes com sombra.
9. **Não implementar o que não foi pedido.** Sugestões vão no relatório, não no place.
10. **Ações só do Rick:** salvar/publicar, `Lighting.Technology`, Game Settings, gravar voz, aprovar portões.

## Mecânica e gameplay (resumo — completo em `docs/04`)

| Sistema | Estado | Essência |
|---|---|---|
| Movimento | feito | 1ª pessoa travada, walk 11 / sprint 17, pulo raro, head bob e sway realistas, sem drift |
| Stamina / fadiga | feito | 100, dreno 18/s, regen 14/s; coração, respiração, zumbido, blur pulsando com o batimento; silêncio acima de 90% |
| Inventário | feito | 3 slots, prompt próprio (segurar E), 1/2/3 equipa, G larga; sem itens de combate |
| Lanterna | feito | invisível na mão em 1ª pessoa, feixe na câmera com inércia, 3 cones; bateria futura |
| Acampamento | feito | única zona relativamente segura, sentida e nunca confirmada; instruções in-world |
| Entrada | feito | `InMaze` → parede + névoa → luz cai → pulso de blur → voz interior (só local, 1× por rodada); escurecimento local em 6 s |
| Labirinto | corpo feito | rocha em Terrain, 3 setores, layout em grafo; passada de qualidade em andamento |
| Chave + código | decidido | sorteados por rodada nos setores 2/3, nunca no mesmo ponto; portão exige os dois |
| Homem Lua | decidido | Watch → Stalk → Approach → Chase → Search → Capture, Director único; esconderijo não é imunidade |
| Casa / Homem Estrela | decidido | só teaser, sem IA |
| Áudio | parcial | passos por material, mixer por setor × estado (Normal/Uneasy/Silent/MoonNear/Chase), eventos 3D por setor; assets finais pendentes |
