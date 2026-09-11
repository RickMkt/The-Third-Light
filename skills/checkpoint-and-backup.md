# Skill: checkpoint e backup

1. `get_studio_state` = Edit.
2. Snapshot interno: `ServerStorage/_Backup_<AAAA-MM-DD>_<nome>` com clones de Workspace (exceto Camera/Terrain), Lighting (+ propriedades como atributos), StarterGui, StarterPlayerScripts, ServerScriptService, ReplicatedStorage, SoundService, ServerStorage; e `Terrain:CopyRegion(Region3int16)` → `TerrainRegion` (restaurar com `PasteRegion`).
3. Arquivo: Rick faz *Arquivo → Salvar em arquivo como…* em `TheThirdLight.rbxl`; copiar para `backups/TheThirdLight_<data>_<nome>.rbxl`.
4. Exportar código para `src/`: `execute_luau` (Server ou Edit) listando `LuaSourceContainer` de ReplicatedStorage / ServerScriptService / StarterPlayer / ServerStorage.Items / StarterGui com delimitadores `=====FILE <caminho> [Classe]` … `=====END`; dividir com Python em `src/<caminho>.{lua|server.lua|client.lua}`. Excluir scripts da Roblox (`RbxCharacterSounds`). Scripts dentro de Tools (`ToggleOnActivate`) também.
5. Atualizar `docs/01-estado-atual.md`, `docs/07-assets.md`, `docs/08-decisoes.md`, `docs/09-backlog.md`.
6. `git add -A && git commit` com mensagem descritiva. Nunca apagar backups anteriores.
