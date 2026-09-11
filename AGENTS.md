# AGENTS.md — instruções para agentes (Codex, Claude Code, etc.)

Você está ajudando a construir **THE THIRD LIGHT**, um jogo de terror psicológico para Roblox.
O dono do projeto é o Rick. Responda em **português**. Leia `docs/01-estado-atual.md` antes de qualquer coisa; depois `docs/02-regras-de-desenvolvimento.md` (regras completas) e `docs/04-mecanicas-e-gameplay.md` (como o jogo deve ser).

## O que este projeto é (e não é)

- É: atmosfera, som, luz, silhueta, timing, pacing, comportamento convincente com regras simples.
- Não é: coleção de sistemas, jumpscares constantes, PNG na tela, "colagem" de assets, mundo aberto.
- Regra central: **fazer o básico extremamente bem**. Se uma mecânica não melhora exploração,
  suspense, terror ou objetivo, ela provavelmente não deve existir.

## Fluxo de trabalho obrigatório

1. **Entender** o sistema/área (ler `docs/`, inspecionar o place via MCP — não recriar o que existe).
2. **Definir** o comportamento esperado em poucas linhas (valores, arquitetura) e, se a mudança for
   grande, **apresentar ao Rick antes de implementar**.
3. **Implementar a versão mínima.**
4. **Testar no Studio** (play via MCP, sondas por script, `get_console_output` limpo).
5. Corrigir → testar de novo → só então polir.
6. **Parar** ao fim da etapa e relatar: o que mudou, valores, o que foi validado, o que ficou placeholder.

Portões onde é proibido avançar sem avaliação do Rick: graybox de área nova, loop de gameplay,
modelo do Homem Lua, comportamento Watch, Chase, final.

## Nunca

- Destruir Terrain/floresta/Workspace sem checkpoint (snapshot em `ServerStorage/_Backup_*`, `.rbxl`, commit).
- Apagar `ServerStorage/Assets/TreeTemplates`, `ServerStorage/Assets/Props`, `ServerStorage/Items`, os backups, nem os sistemas listados em `docs/03-arquitetura.md`.
- Editar com o play rodando: **alterações feitas em Play não persistem** (já perdemos trabalho assim). Confirme `get_studio_state` = Edit.
- Deixar `print` permanente, warnings, conexões duplicadas por respawn, loops por frame desnecessários.
- Colocar texto de UI/placa como "SAFE ZONE", "SEASON 2", "RESTRICTED (game)". Tudo existe organicamente.
- Copiar personagens existentes (ex.: "That Isn't the Moon"). O Homem Lua tem identidade própria.
- Mudar `Lighting.Technology`, `Game Settings > Avatar` ou salvar/publicar sem o Rick — são ações dele.

## Convenções de código (Luau)

- `--!strict`, nomes claros, tipos onde ajudam, comentários curtos explicando o **porquê**.
- Valores ajustáveis sempre em `ReplicatedStorage/Shared/*Config` (Movement, Inventory, Sound, Dialogue).
- Cliente = visual/input (câmera, FOV, UI, luzes locais); servidor = estado que importa (velocidades, itens, gatilhos).
- Um `RenderStepped`/bind por sistema; usar `deltaTime` (FPS-independente); suavizações com `approach()` exponencial.
- Ao mexer em respawn: limpar conexões em `CharacterRemoving`/`Died`, sem memory leak.
- Sons: `RollOffMode = InverseTapered`; sem reverb em área aberta (`SoundService.AmbientReverb = NoReverb`).
- Espelho do código: `src/` (atualizar ao fazer checkpoint; a verdade viva é o place).

## Assets (Creator Store / Toolbox)

- Buscar com `verifiedCreatorsOnly`, preferir Roblox / Pro Sound Effects / APM / DistrokidOfficial para áudio.
- **Inserir primeiro em `ServerStorage` como `Probe_*`**, inspecionar (`GetDescendants`: scripts, remotes, contagem de parts, tamanho, SurfaceAppearance), remover scripts, ancorar, só então usar.
- Máximo de 2–3 famílias visuais por área. Sem colagem. Registrar em `docs/07-assets.md` (ID, criador, uso, observações de licença).
- Sem modelo pronto de "moon monster": o Homem Lua será próprio (blockout no Studio ou Blender).

## Trabalhando via Roblox Studio MCP

Ver `skills/studio-mcp-workflow.md`. Resumo: `list_roblox_studios` → `get_studio_state` → `execute_luau` (datamodel `Edit` para construir, `Server`/`Client` em play para testar) → `start_stop_play` → sondas por script → `get_console_output` → `screen_capture` (só em Edit; à noite use a "luz de revisão" temporária e **restaure** a noite depois).

Se `execute_luau` retornar "Target is closed" ou "No Roblox Studio instances", o Studio reconectou: **re-verifique o que persistiu** antes de continuar.

## Comunicação com o Rick

- Relatórios objetivos: arquivos criados/alterados, valores, testes feitos, problemas achados/corrigidos, o que ficou placeholder, nota crítica quando pedido.
- Quando não conseguir ver/ouvir algo (screenshot em play, áudio), diga e peça que ele valide o *feeling*.
- Lembrar de `Ctrl+S` (save na nuvem) após entregas; o `.rbxl` local é atualizado via *Arquivo → Salvar em arquivo como…*.
