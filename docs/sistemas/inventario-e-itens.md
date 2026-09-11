# Inventário e itens

Fonte: `InventoryConfig`, `InventoryServer`, `InventoryController`, `InteractionPrompts`, `CarriedLightController`, `SoundServer` (toggle de luz).

- 3 slots. Itens são `Tool`s em `ServerStorage/Items`. Pickups no mundo são `Model`s (cópias das parts do Tool, ancoradas, sem luzes/sons/welds) com `ProximityPrompt` (Style Custom, tecla E, 0,2 s, 7 studs).
- Servidor: valida distância (12 studs), limite de 3, atribui `Slot` estável (primeiro livre), equipa ao pegar. Drop (G) recria o pickup à frente do jogador.
- Marcadores de spawn: `Gameplay/Interactions/ItemSpawns/*` com atributo `ItemName` (raycast até o chão ou a mesa; `PickupRotation` (graus) e `PickupScale` opcionais no Tool).
- Cheio → `InventoryMessage` "Você não consegue carregar mais nada." (some sozinho).
- Luzes portáteis: `ToggleOnActivate` (clique) → `ToggleLight` → servidor alterna `Lit`, luzes e `LitPart`s, toca `Click`. Lanterna: para quem segura, o feixe é recriado num carrier dentro da Camera (lag 14) e as luzes do Tool ficam desligadas localmente; para os outros, as luzes ficam na mão.
- Primeira pessoa: `CarriedLightController` força `LocalTransparencyModifier = 0` na ferramenta e no braço direito (a câmera nativa apagava tudo).
- Regra futura (Rick): **CarryItem** — componentes grandes não vão para a hotbar; ficam presos ao personagem (1 por jogador), largáveis, visíveis a todos, e o Homem Lua reage a quem carrega. Não implementado.
