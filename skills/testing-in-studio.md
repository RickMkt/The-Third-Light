# Skill: testar no Studio

- Play: `start_stop_play true` → `execute_luau` em `Client` e `Server`. Esperar `Character` + `HumanoidRootPart` antes de tudo.
- **Sondas**: `RunService.Heartbeat` amostrando a cada 0,2–1 s em `_G.probe` (WalkSpeed, FOV, CameraOffset, pitch/roll da câmera, volumes de Sound, blur, transparências de UI, estado do Humanoid). Ao reiniciar a sonda, recriar a conexão inteira (o `last` do closure não zera sozinho — bug clássico da "probe vazia").
- Input: `user_keyboard_input` (W/Shift/Space/E/M/G funcionam; números não) e `user_mouse_input`. Se falhar por CoreGUI/menu Esc, dirija com `Humanoid:MoveTo` no servidor (reemitir a cada 3 s; `MoveTo` não desvia de obstáculos — um FAIL pode ser só isso).
- Navegação de mapa: `PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = false})` entre POIs → comprimento e status; complementa o walkthrough real.
- Performance: contar frames em `RenderStepped` por 4–5 s (fps médio, pior frame); contar BaseParts/MeshParts com `GetDescendants`.
- Sempre `get_console_output` ao final (deve estar vazio, exceto avisos esperados).
- Pickups: checar `Gameplay/Items` (pivot, extents, UpVector para orientação). Luzes: `Enabled`, `Brightness` oscilando. Ferramenta em 1ª pessoa: `LocalTransparencyModifier` e posição relativa à câmera.
- Multiplayer real (2+ clientes) só manualmente: Test → Clients and Servers.
- Terminar parando o play; lembrar o Rick de `Ctrl+S`.

## Screenshots à noite com luzes locais (lição de 11/09)
`screen_capture` com `camera_position` **não** move a câmera real do Studio; a grade de iluminação (voxels) é calculada em volta da câmera real. Uma SpotLight/PointLight a 300+ studs da câmera do Studio **não aparece** na captura — parece que "a lanterna não ilumina". Para avaliar luz local: `workspace.CurrentCamera.CFrame = CFrame.lookAt(pos, alvo)` em Edit, `task.wait(1)`, e só então `screen_capture` sem argumentos de câmera. Para simular a lanterna, criar um Part invisível com os mesmos SpotLights na posição da câmera e apagar depois.
