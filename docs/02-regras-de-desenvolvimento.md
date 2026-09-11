# 02 · Regras de desenvolvimento

## Processo (sempre)

1. Entender → 2. definir comportamento exato → 3. versão mínima → 4. testar no Studio →
5. corrigir → 6. testar de novo → 7. só então polir. **Nunca** pular para arquitetura gigante.

Trabalhar **por camadas**: estrutura → loop → Homem Lua → terror → polimento.
Trabalhar **parte por parte** do mapa: acampamento → Setor 1 → Setor 2 → Setor 3 → portão → trilha final → casa.
Cada parte é testada e aprovada antes da seguinte.

## Portões de aprovação (parar e mostrar ao Rick)

Graybox de área nova · loop de gameplay · modelo/rig do Homem Lua · comportamento Watch ·
Chase · sequência final. Em cada portão: testar, documentar, screenshots, contagem de parts,
problemas encontrados, avaliação crítica e o que mudaria antes de seguir.

## Backup antes de destruir

Antes de substituir Terrain, floresta ou reorganizar o Workspace:
1. `get_studio_state` = Edit.
2. Snapshot interno em `ServerStorage/_Backup_<data>_<nome>` (clones + `Terrain:CopyRegion` → `TerrainRegion`).
3. `.rbxl` salvo (Rick: *Arquivo → Salvar em arquivo como…*) e copiado para `backups/`.
4. Commit no Git.
Nunca apagar backups anteriores.

## Regras de mapa e ambiente

- Não é mundo aberto. Mapa compacto que parece maior por vegetação, neblina, curvas, elevação, bloqueio visual, som.
- Evitar corredores artificiais de árvores, simetria perfeita, caminhos radiais iguais, POIs "parque temático".
- Graybox primeiro (parts simples) validando tamanho, distância, navegação, linha de visão, rotas; depois substituir por assets gradualmente.
- Segurança relativa (acampamento) é **sentida**, nunca confirmada: sem círculo visível, sem "SAFE", sem UI de imunidade.
- Sinalização in-world só funcional/envelhecida ("TRILHA FECHADA", parte ilegível). Nada sobrenatural escrito; nada de "Season 2/3".
- Contraste de luz: ambiente frio/azul/escuro; fogueira e lampiões quentes; entrada do labirinto mais escura ainda.
- Não iluminar demais; sem postes modernos (postes de madeira com lampião são ok).

## Regras de assets (Toolbox / Creator Store)

- Inserir em `ServerStorage` como `Probe_*` e **inspecionar**: scripts/LocalScripts/ModuleScripts/RemoteEvents (remover), `require` suspeito, contagem de parts/MeshParts, tamanho (alguns vêm em escala absurda), colisão (`CanCollide`, tronco sim/folhagem não), `Anchored`, materiais/SurfaceAppearance, peso.
- Poucos packs, mesma linguagem visual, mesma densidade de detalhe. Sem colagem.
- Preferir criadores verificados; áudio de Pro Sound Effects / APM / DistrokidOfficial. Marcar uploads de comunidade como "trocar antes do lançamento".
- Não usar "moon monster" pronto. Não usar assets ripados de outros jogos (ex.: packs Fallout).
- Registrar tudo em `07-assets.md`.

## Regras de código

- Luau `--!strict`, legível, sem código morto, sem prints permanentes, sem warnings.
- Configs centralizados em `ReplicatedStorage/Shared/*Config`.
- Cliente: câmera, FOV, head bob, UI, input, luzes locais. Servidor: velocidades, itens, gatilhos, tudo que importa.
- Sem anti-cheat complexo, mas sem LocalScript definindo valores arbitrários (servidor escolhe entre valores da config).
- Respawn: reinicializa sem conexões duplicadas nem leaks. Um `RenderStepped` por sistema. `deltaTime` sempre.
- Multiplayer: estado por jogador; nada de câmera/UI afetando outros.

## Performance

Monitorar BaseParts, MeshParts, luzes, sombras, partículas. Colisão simples (tronco das árvores só).
Objetos decorativos pequenos `CanCollide = false`. `StreamingEnabled` ligado. Meta: 60 fps no Studio com a área completa.

## Homem Lua — regras de implementação futura

Camadas: **Watch** → **Stalk** → **Approach** → **Chase** → **Search/Hiding** → **Capture**.
Nunca começar pela perseguição. Um controller central (director) controla progressão, cooldowns, estado e impede múltiplos Homens Lua. A maioria da experiência é ver/achar que viu/ouvir/esperar/sentir presença; perseguição é evento. Ver `06-homem-lua.md`.
