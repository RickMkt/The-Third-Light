# 02 · Regras de desenvolvimento

> Regras válidas para qualquer pessoa ou agente (Codex, Claude Code) que trabalhe neste projeto. Quando uma regra daqui conflitar com uma vontade momentânea, a regra vence — a menos que o Rick a mude e o registro vá para `08-decisoes.md`.

---

## 1. Princípios

1. **Fazer o básico extremamente bem.** Antes de adicionar um sistema, perguntar: isso melhora exploração, suspense, terror ou objetivo? Se não, não existe.
2. **Execução > quantidade.** Uma perseguição que funciona vale mais do que dez mecânicas.
3. **Simplicidade técnica é positiva.** Regras simples com apresentação convincente parecem inteligentes. Arquitetura grande é dívida.
4. **Tudo existe organicamente no mundo.** Instruções são anotações na mesa; limites são rocha e mata; perigo é sentido, nunca anunciado.
5. **Sem "AI slop".** Nada de colagem de assets, nada de placeholder cúbico onde existe asset bom, nada de texto genérico, nada de jumpscare de PNG.
6. **A verdade viva é o place.** `src/`, docs e `.rbxl` são espelhos e devem ser atualizados a cada checkpoint — mas o que está no Studio manda.

---

## 2. Processo (sempre, sem exceção)

```
1. ENTENDER   → ler docs/01-estado-atual.md, inspecionar o place via MCP; não recriar o que existe
2. DEFINIR    → comportamento esperado em poucas linhas (valores, arquitetura, o que NÃO faz)
3. MÍNIMO     → implementar a versão mínima que prova o comportamento
4. TESTAR     → play no Studio via MCP, sondas por script, console limpo, screenshots
5. CORRIGIR   → e testar de novo
6. POLIR      → só depois de o comportamento estar certo
7. RELATAR    → parar e reportar (formato na seção 9)
```

- Trabalhar **por camadas**: estrutura → loop → Homem Lua → terror → polimento.
- Trabalhar **parte por parte** do mapa: acampamento → S1 → S2 → S3 → portão → trilha final → casa. Cada parte é testada e aprovada antes da seguinte.
- **Não implementar o que não foi pedido. Não antecipar cinco etapas.** Se algo além do escopo for claramente necessário, listar no relatório como sugestão.
- Mudança grande (nova área, novo sistema, troca de direção) → **apresentar proposta ao Rick antes**, com valores e alternativas.

### 2.1 Portões de aprovação (parar e mostrar ao Rick)

| Portão | O que entregar antes de seguir |
|---|---|
| Graybox de área nova | screenshots (luz de revisão), contagem de parts, tempos de travessia, rotas, problemas |
| Passada de qualidade de área | relatório de 20 itens (métricas antes/depois, fps, screenshots, notas 0–10) |
| Loop de gameplay (chave/código/portão) | teste com 2+ clientes, casos de borda, o que fica placeholder |
| Modelo/rig do Homem Lua | é trabalho do Rick; agente só integra |
| Comportamento Watch | vídeo/screenshots de aparições, distâncias, frequência |
| Chase | velocidades, taxa de captura em teste, sensação |
| Sequência final / captura | descrição quadro a quadro, áudio, duração |

Em cada portão: testar, documentar, screenshots, contagem de parts, problemas encontrados, **avaliação crítica honesta** e o que mudaria antes de seguir.

---

## 3. Backup antes de destruir (regra permanente)

Antes de substituir Terrain, floresta, reorganizar o Workspace ou apagar qualquer coisa grande:

1. `get_studio_state` → confirmar **Edit** (não Play).
2. Pedir ao Rick **Ctrl+S** (save na nuvem).
3. Confirmar que o checkpoint anterior (`ServerStorage/_Backup_*`) ainda existe.
4. Criar novo snapshot interno `ServerStorage/_Backup_<AAAA-MM-DD>_<nome>` com clones das pastas afetadas + `Terrain:CopyRegion` → `TerrainRegion`.
5. Rick: *Arquivo → Salvar em arquivo como…* → copiar para `backups/`.
6. `git commit` do estado atual (docs + `src/`).

**Nunca apagar backups anteriores.** Nunca apagar `ServerStorage/Assets/*`, `ServerStorage/Items`, `_Backup_*`, `_Archive_*`.

---

## 4. Regras do Roblox Studio via MCP

Detalhes em `skills/studio-mcp-workflow.md`. As regras que já custaram trabalho:

- **Alterações feitas com o Play rodando não persistem.** Sempre `get_studio_state` = Edit antes de construir. Em Play só testar (datamodel `Server`/`Client`).
- `require()` de ModuleScript é **cacheado em Edit**: depois de editar um Config, ler valores por `script_read` ou usar literais nas sondas.
- Se `execute_luau` responder "Target is closed" / "No Roblox Studio instances", o Studio reconectou: **re-verificar o que persistiu** antes de continuar (já perdemos um lote inteiro assim).
- `screen_capture` só funciona em Edit. À noite usar a **luz de revisão** temporária (`skills/lighting-night.md`) e **sempre restaurar** a noite depois (foi esquecido duas vezes).
- `user_keyboard_input` não envia teclas numéricas nem funciona com o menu Esc aberto. Para testar equipar item, usar sondas por script.
- Nunca automatizar salvar/publicar por teclado (SendKeys) — quase renomeou uma pasta. Salvar e publicar são ações do Rick.
- `Lighting.Technology`, `Game Settings > Avatar`, `StreamingEnabled` em Game Settings: **só o Rick**.
- Saídas grandes de `execute_luau` vão para arquivo; imprimir resumos, não `GetDescendants()` inteiro.
- Depois de gerar/editar Terrain ou reparentar milhares de instâncias, o Studio fica 10–20 s a ~15 fps. **Não é o jogo** — esperar estabilizar antes de medir.

---

## 5. Regras de mapa e ambiente

- **Não é mundo aberto.** Mapa compacto que parece maior por vegetação, neblina, curvas, elevação, bloqueio visual e som.
- Evitar corredores artificiais de árvores, simetria perfeita, caminhos radiais iguais, POIs "parque temático", objetos flutuando, objetos enterrados.
- **Graybox primeiro** (parts simples) validando tamanho, distância, navegação, linha de visão, rotas. Substituir por assets gradualmente.
- Tudo o que o jogador **anda em cima** é Terrain ou parte sólida com colisão limpa. Decoração pequena `CanCollide = false`. Árvores: só tronco.
- **Sem paredes invisíveis no labirinto.** Só no acampamento (sul e lados), mascaradas por mata, névoa e composição.
- Segurança relativa (acampamento) é **sentida**, nunca confirmada: sem círculo, sem "SAFE", sem UI de imunidade.
- Sinalização in-world só funcional/envelhecida ("TRILHA FECH DA"). Nada sobrenatural escrito; nada de "Season 2/3".
- Luz: ambiente frio/azul/escuro; fogueira e lampiões quentes; labirinto mais escuro que o acampamento mas **legível**. Sem postes modernos.
- **Composição autoral**, não aleatória: árvores em grupos de 2–3 com vazios, sub-bosque onde faz sentido (base das paredes, bolsões, clareiras), vegetação nas paredes irregular (não musgo uniforme).
- Pensar sempre no **Homem Lua de 3,5–4 m**: largura mínima 13–14 studs, curvas suaves, nada atravessado nas rotas principais.
- Larguras de referência do labirinto: principais 18–24 (26–28 em bifurcações), secundárias 15–20, apertos intencionais ≥ 13–14, núcleo limpo 10–12.

---

## 6. Regras de assets (Toolbox / Creator Store)

1. Buscar com `verifiedCreatorsOnly` quando possível. Áudio: Roblox, Pro Sound Effects, APM, DistrokidOfficial. Marcar uploads de comunidade como **"trocar antes do lançamento"**.
2. **Inserir primeiro em `ServerStorage` como `Probe_*`** e inspecionar (`skills/asset-inspection.md`): Scripts/LocalScripts/ModuleScripts/RemoteEvents (remover), `require` suspeito, contagem de parts/MeshParts, tamanho (muitos vêm em escala absurda), colisão, `Anchored`, materiais/SurfaceAppearance, eixo (alguns vêm Z-up).
3. Máximo de **2–3 famílias visuais por área**, mesma densidade de detalhe. Sem colagem.
4. Não usar "moon monster" pronto. Não usar assets ripados de outros jogos (Fallout, etc.). Conferir licença de meshes vindos de Sketchfab.
5. Preferir asset bonito a part própria. Part própria só quando não existe asset adequado (e registrar em `08-decisoes.md`).
6. Registrar **tudo** em `07-assets.md`: ID, criador, uso, observações (scripts removidos, escala, licença).

---

## 7. Regras de código (Luau)

### 7.1 Estilo
- `--!strict`, nomes claros em inglês, tipos onde ajudam, comentários curtos explicando o **porquê**.
- Sem código morto, sem `print` permanente, sem warnings no console, sem `wait()` legado.
- Um arquivo = um sistema. Nome `XxxController` (cliente), `XxxServer` (servidor), `XxxConfig` (dados), `XxxRemotes` (Folder de remotes).

### 7.2 Arquitetura
- Valores ajustáveis **sempre** em `ReplicatedStorage/Shared/*Config`. Nada de número mágico em script.
- **Cliente** = visual e input: câmera, FOV, head bob, UI, luzes locais, escurecimento local, prompts.
- **Servidor** = estado que importa: velocidades, itens, gatilhos, Director, chave/código, portão.
- Cliente nunca define valores arbitrários; pede uma **escolha** (`sprint on/off`, `equip slot 2`) e o servidor aplica valores da config.
- Remotes mínimos, validados (distância, cooldown, tipo). Um Folder `XxxRemotes` por sistema.

### 7.3 Loop e performance
- **Um** `RenderStepped`/`BindToRenderStep` por sistema. `deltaTime` sempre (FPS-independente).
- Suavizações com `approach()` exponencial: `value += (target − value) * (1 − exp(−speed·dt))`.
- Câmera: dois passes ao redor do processamento nativo (restaurar CFrame antes; aplicar roll/pitch depois) — nunca acumular offsets.
- Respawn: reinicializar sem conexões duplicadas; limpar em `CharacterRemoving`/`Died`. Sem memory leak.
- Multiplayer: estado por jogador; nada de câmera/UI afetando outros.

### 7.4 Som
- `RollOffMode = InverseTapered`; `SoundService.AmbientReverb = NoReverb`.
- Sons pontuais em emissores no mundo, nunca 2D quando o evento tem posição.
- Sons padrão do personagem (CoreScript) silenciados no cliente, não sobrescritos.

### 7.5 Espelho `src/`
Ao fazer checkpoint, exportar os scripts alterados para `src/` na mesma hierarquia (`StarterPlayer/StarterPlayerScripts/X.client.lua`, `ServerScriptService/X.server.lua`, `ReplicatedStorage/Shared/X.lua`). O place manda; `src/` serve para diff, revisão e para outro agente ler.

---

## 8. Performance

- Meta: **60 fps no Studio** com a área completa, lanterna ligada e sombras.
- Monitorar: BaseParts, MeshParts, luzes (com sombra ≤ 3 ativas), ParticleEmitters, SurfaceAppearances, Terrain voxels.
- Colisão simples: terreno como colisão principal; tronco das árvores só; decoração `CanCollide = false`, `CanTouch = false`, `CanQuery = false` quando não interativa.
- `StreamingEnabled` ligado (Rick). Cinturões de contenção de mata devem ser revisados (hoje ~1.740 árvores) — preferir menos árvores maiores + névoa.
- Medir fps **por setor** e registrar no relatório.

---

## 9. Testes e relatório

### 9.1 Testes mínimos por entrega
- Walkthrough completo da área (acampamento → lanterna → S1 → S2 → S3 → saída) em Play, R6, a 11 e 17 studs/s.
- Console limpo (`get_console_output`): sem erros, sem warnings, sem prints.
- Para áreas de perseguição: passar uma **cápsula placeholder de 3,5–4 m** pelas rotas principais e remover depois.
- Áudio: 60 s parado por setor ouvindo camadas; passos/respiração nunca cobertos.
- Multiplayer: quando o sistema tem estado por jogador, testar com 2+ clientes (Test → Clients and Servers).
- Screenshots com luz de revisão **e** restaurar a noite.

### 9.2 Formato do relatório de entrega
1. O que mudou (arquivos/instâncias criadas e alteradas).
2. Valores (antes → depois).
3. Testes feitos e resultado (inclusive fps).
4. Problemas encontrados e corrigidos.
5. O que ficou placeholder / pendente.
6. Avaliação crítica (quando pedido: notas 0–10 por critério).
7. Ações do Rick (Ctrl+S, Technology, salvar `.rbxl`, gravar voz…).
8. Sugestões de próximo passo — **sem executá-las**.

---

## 10. Documentação e Git

- `docs/01-estado-atual.md` é o ponto de entrada; atualizar a cada checkpoint. Decisões vão para `08-decisoes.md` (data · decisão · motivo · consequência). Assets para `07-assets.md`. Backlog em `09-backlog.md`.
- Commits pequenos, mensagem no imperativo em português ou inglês, descrevendo **o que** e **por quê** (`Maze: widen main corridors to 18–24 for Moon Man navigation`).
- Não commitar `.remember/`, `*.rbxl.lock`. `.rbxl` são binários (LFS não usado; manter poucos checkpoints em `backups/`).
- Branch `master` é a linha principal; trabalho experimental grande em branch própria e merge após aprovação do Rick.

---

## 11. Homem Lua — regras de implementação futura

Camadas: **Watch** → **Stalk** → **Approach** → **Chase** → **Search/Hiding** → **Capture**.
Nunca começar pela perseguição. Um Director central controla progressão, cooldowns, estado e impede múltiplos Homens Lua. A maioria da experiência é ver / achar que viu / ouvir / esperar / sentir presença; perseguição é evento. Navegação pelo **grafo do Layout** (o navmesh não cobre todo o labirinto). Ver `06-homem-lua.md` e `04-mecanicas-e-gameplay.md §6`.
