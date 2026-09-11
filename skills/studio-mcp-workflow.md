# Skill: trabalhar no Roblox Studio via MCP

## Ferramentas
`list_roblox_studios` (pegar `studio_id`) → `get_studio_state` (Edit / Play; datamodels disponíveis) → `execute_luau` (datamodel_type `Edit` para construir, `Server`/`Client` em play) → `multi_edit` (criar/editar scripts; só em Edit) → `script_read` → `start_stop_play` → `get_console_output` → `screen_capture` (só em Edit) → `user_keyboard_input` / `user_mouse_input` (só em Client) → `search_asset` / `insert_asset` (só em Edit).

## Regras aprendidas
- **Alterações feitas em Play não persistem.** Sempre `get_studio_state` antes de editar. Se o Rick estiver em Play, avise e pare o play (`start_stop_play false`).
- `execute_luau` em Edit tem `require()` **cacheado**: depois de editar um ModuleScript, não confie em `require` no mesmo Edit — replique os valores literalmente ou teste em Play.
- Se aparecer "Target is closed" / "No Roblox Studio instances", o Studio reconectou: **verifique o que persistiu** (já perdemos um lote de alterações assim) e reaplique.
- Saídas grandes de `execute_luau` (acima de ~100k caracteres) vão para um arquivo em `tool-results/`; processe com Python.
- Input virtual falha quando o **menu Esc** da Roblox está aberto ("CoreGUI has keyboard focus") ou o viewport não tem foco; teclas numéricas são recusadas ("permanently bound to a CoreGUI action"). Alternativa: dirigir o Humanoid por `MoveTo` no servidor e ler o estado por sondas.
- `screen_capture` só funciona em Edit e mostra a iluminação de Edit (luzes sim, UI não). Para avaliar layout à noite use a **luz de revisão** (ver `lighting-night.md`) e **restaure** depois — esquecer de restaurar já aconteceu.
- Propriedades protegidas (não acessíveis por script): `Lighting.Technology`, `StarterPlayer.GameSettingsAvatar`, `Terrain.Decoration`. Peça ao Rick.
- Salvar: `Ctrl+S` = nuvem (place publicado). Automação de teclado no Studio é arriscada (quase renomeou uma pasta) — peça ao Rick para salvar em arquivo.
- Scripts com `multi_edit`: criar com `className` e primeiro edit `old_string = ""`. Para reescrever um script inteiro, destrua e recrie. Escapes unicode nas strings funcionam.
- Luau no bridge: evite expressões `if … then … elseif … else` muito longas em uma linha (o parser já falhou); prefira statements `if/elseif`.
