# THE THIRD LIGHT (A Terceira Luz)

Jogo de terror psicológico multiplayer (4–5 jogadores) para Roblox.
Filosofia do projeto em uma frase: **fazer o básico extremamente bem** — atmosfera, som,
luz, comportamento das entidades, câmera, pacing. Nada de jumpscare de PNG, nada de
"AI slop", nada de sistema que não melhore exploração, suspense ou objetivo.

- Place publicado: **A Terceira Luz** — grupo Necrovale — `PlaceId 86901786058243`
- Engine: Roblox Studio + Luau · Rig: **R6** (via `StarterPlayer/StarterCharacter`)
- Ferramentas: Claude Code / Codex via **Roblox Studio MCP** (edição, testes e captura direto no Studio)

## Como usar este repositório

| Pasta | O que é |
|---|---|
| `AGENTS.md` | Instruções para agentes (Codex/Claude): regras, fluxo de trabalho, o que nunca fazer |
| `docs/` | Visão, estado atual, regras de desenvolvimento, arquitetura, sistemas, mapa, Homem Lua, assets, decisões, backlog |
| `lore/` | Universo, entidades e temporadas — o que está decidido e o que está em aberto |
| `skills/` | Playbooks reutilizáveis (como trabalhar no Studio via MCP, inspecionar assets, terreno, luz, testes) |
| `src/` | **Código-fonte exportado do Studio** (Luau). A verdade viva está no place; este espelho é atualizado a cada checkpoint |
| `backups/` | Cópias `.rbxl` de checkpoints |
| `TheThirdLight.rbxl` | Último save em arquivo (o place na nuvem é o principal) |

Comece por `docs/01-estado-atual.md` e depois `docs/09-backlog.md`.

## Estrutura da Temporada 1 (direção atual)

```
ACAMPAMENTO (spawn, única zona relativamente segura)
   ↓ entrada do labirinto (fecha atrás do jogador)
SETOR 1  — Homem Lua só observa
SETOR 2  — Homem Lua começa a perseguir · chave/código podem aparecer
SETOR 3  — zona mais perigosa · chave/código podem aparecer
   ↓ PORTÃO FINAL (precisa de CHAVE + CÓDIGO, randomizados por rodada)
TRILHA FINAL → CASA → teaser do Homem Estrela → fim da Parte 1
```

Só o **acampamento** está construído. Labirinto, setores, portão, casa e Homem Lua ainda não.

## Regras inegociáveis (resumo)

1. Trabalhar **por camadas** e **parte por parte**; testar no Studio antes da próxima etapa.
2. **Backup antes de destruir** (snapshot interno + `.rbxl` + commit).
3. Todo asset da Toolbox é **inspecionado** (scripts removidos, peso/colisão checados) e registrado em `docs/07-assets.md`.
4. Nada de UI/placa dizendo "safe zone", "season 2", etc. Tudo existe organicamente no mundo.
5. Não implementar o que não foi pedido. Não antecipar cinco etapas.
