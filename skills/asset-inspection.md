# Skill: assets do Creator Store

1. `search_asset` com `scope=creator_store`, `priceFilter=free`, `verifiedCreatorsOnly=true`, `assetType` (Model/Audio). Para áudio use `audioMinDuration`/`audioMaxDuration`.
2. Preferir: Roblox, Pro Sound Effects, APM, DistrokidOfficial (áudio licenciado); modelos com PBR/SurfaceAppearance de criadores com portfólio. Desconfiar de nomes-spam com emojis e "tags trending", de packs ripados (Fallout, SCP) e de descrições "não fui eu que fiz".
3. `insert_asset` para `game.ServerStorage` com nome `Probe_*`. Nunca direto no Workspace.
4. Inspecionar por `execute_luau`: contagem por ClassName, `GetExtentsSize` (alguns vêm com 30–250 studs), scripts (`LuaSourceContainer`), RemoteEvents, Seats, Sounds, luzes, SurfaceAppearance/TextureId. Ler a `Source` de qualquer script antes de decidir.
5. Sanitizar: destruir scripts/remotes; converter Seats em Parts se necessário; `Anchored = true`; ajustar colisão; remover luzes/sons do autor se você tem os seus.
6. Pré-visualizar: pasta `_Preview` no Workspace com um piso, `ScaleTo` para normalizar tamanho, luz de revisão, `screen_capture` de perto. Apagar `_Preview` depois.
7. Aprovado → renomear e mover para `ServerStorage/Assets/Props` (ou `TreeTemplates`); registrar em `docs/07-assets.md` (ID, criador, uso, licença). Rejeitado → destruir.
8. Colocar no mundo com `placeModel(template, name, x, z, rot, scale, sink)`: pivot pelo bounding box, base no chão por raycast. `GetExtentsSize` é orientado ao pivot — para o ponto mais baixo real, amostre os 8 cantos de cada part.
9. Modelos Z-up (como os pinheiros): `PivotTo(... * CFrame.Angles(-π/2, 0, 0))` e recalcular a base pelos cantos.
10. MeshParts com SurfaceAppearance ignoram `Color`; para tingir use `SurfaceAppearance.Color`. Unions aceitam cor com `UsePartColor = true`.
