# 04 · Mecânicas e gameplay (referência completa)

> Documento de referência de **como o jogo deve ser**. O que está marcado como `[IMPLEMENTADO]` existe no place e foi testado; `[DECIDIDO]` está definido mas ainda não construído; `[EM ABERTO]` depende de decisão do Rick. Valores vivos ficam em `ReplicatedStorage/Shared/*Config` — se divergirem deste documento, o Config vence e este arquivo deve ser atualizado.

---

## 1. Pilares de gameplay

1. **Exploração desconfortável.** Andar na floresta já deve gerar tensão sem nada acontecer. Isso vem de escuridão legível, som, névoa, silhuetas e câmera — não de scripts de susto.
2. **Terror por expectativa.** O jogador acha que algo vai acontecer. Quando acontece, foi preparado: primeiro "tem alguma coisa errada", depois "alguma coisa está vindo atrás de mim", só então o evento.
3. **Corpo do jogador importa.** Stamina, respiração, coração, visão embaçada e velocidade são a mecânica central de sobrevivência. Não existe HP.
4. **Objetivo simples, execução perigosa.** Achar chave + código e abrir o portão. Nenhum puzzle complexo; o perigo está em atravessar o labirinto carregando algo, no escuro, com o Homem Lua.
5. **Multiplayer como amplificador.** Ouvir um amigo correndo no escuro, perder o grupo, decidir se espera ou segue. Sem PvP, sem papéis, sem loja.
6. **Nada de UI de jogo.** Sem minimapa, sem marcador de objetivo, sem "safe zone", sem nomes flutuantes, sem barra de HP, sem contador de inimigos. A UI se resume a stamina discreta, crosshair dot, hotbar de 3 slots e legendas de fala.

---

## 2. Jogador `[IMPLEMENTADO]`

### 2.1 Corpo e câmera
- **Rig R6** forçado por `StarterPlayer/StarterCharacter` (corpo neutro, sem avatar do jogador). Todos os jogadores têm o mesmo corpo — coerente com "personagens fixos".
- **Primeira pessoa travada** (`CameraMode = LockFirstPerson`), FOV base **72**. Sem terceira pessoa nunca.
- **Crosshair dot** pequeno e fixo (não treme, não escala).
- **M** solta/prende o mouse sem abrir o menu (para interagir com UI própria). Nada mais usa o mouse.
- **Head bob** posicional via `Humanoid.CameraOffset` (andando 1,7 Hz, correndo 2,3 Hz), roll/pitch por passo, lean em strafe e curva, impacto de aterrissagem, respiração em repouso (0,35° a 0,45 Hz). Tudo suavizado por `deltaTime`; zero drift de pitch (a câmera é restaurada antes do processamento nativo e recebe roll/pitch depois).
- **Look base**: blur 1 px, saturação −0,2, contraste +0,06, brilho −0,03, tint frio. É a "assinatura" visual de terror do jogo, sempre ativa.

### 2.2 Movimento
| Parâmetro | Valor | Observação |
|---|---|---|
| Walk | **11** studs/s | Rick subiu de 10 para 11: mais fluido, ainda humano |
| Sprint (Shift) | **17** studs/s | de 15 para 17; FOV vai a 80 com "kick" de +3 ao iniciar |
| Pulo | JumpPower **35**, cooldown **0,6 s** | pulo é raro e curto; não existe parkour |
| Servidor | aplica `WalkSpeed` | cliente só pede "sprint on/off"; servidor escolhe entre os dois valores da config |

Não existe agachar, rastejar, escalar nem empurrar. Movimento é simples de propósito — a complexidade está em como o corpo reage.

### 2.3 Stamina e fadiga
| Parâmetro | Valor |
|---|---|
| Máximo | 100 |
| Dreno correndo | 18/s (≈ 5,5 s de sprint cheio) |
| Regeneração | 14/s após 1,25 s parado de correr |
| Exaustão | abaixo de 20 não dá para correr; só volta acima do limiar |

Feedback corporal (tudo sincronizado ao batimento e escalado por `1 − stamina`):
- **Coração** 96 → ~130 bpm, começa em 70% de stamina; **respiração** pesada começa em 60%; **zumbido** (2172 Hz) começa em 30% e dá pico ao parar exausto, descendo junto com a respiração.
- **Visão**: blur de 0,3 → 8 px (+3 na exaustão) piscando **junto com o coração** (não aleatório), vignette 0,35 pulsando, dessaturação −0,3, contraste −0,08, tremor de câmera 0,12. Sensação alvo: "a pressão está caindo", não "efeito de dano".
- **Silêncio acima de 90%** de stamina: jogador descansado não ouve nada do próprio corpo. Isso torna o som corporal um sinal, não um ruído.
- Tudo é **local** (cada jogador ouve/vê o próprio corpo). Replicar respiração para os outros é backlog.

### 2.4 Regras de feel (não negociáveis)
- Nunca input-lag: suavização exponencial pequena, nunca `Lerp` fixo por frame.
- Nunca overlay 2D de "dano" ou vinheta vermelha. Efeitos sempre em tons frios e orgânicos.
- Efeito só existe se o jogador consegue **sentir** sem que precise ser explicado.

---

## 3. Inventário e itens `[IMPLEMENTADO]`

- **3 slots**, sem mais. Itens são `Tool`s; **1/2/3** equipa, **G** larga. Hotbar padrão da Roblox desligada; a nossa é discreta na base da tela.
- Pickups no mundo são `Model`s com **prompt próprio** (sem `ProximityPrompt` visual da Roblox): segurar **E**, um badge preenche. Atributos `ItemName`, `PickupRotation`, `PickupScale` definem a apresentação do item deitado no mundo.
- Servidor valida distância, limite de slots e existência do item. Cliente só pede.
- Itens atuais: **Lanterna** (a única no mapa, na mesa do acampamento). `Lampião` existe como Tool mas é usado só como prop nos postes. Chave Inglesa / Bateria / Fusível são placeholders de uma versão anterior, sem uso.
- Regra: **não existem itens de combate**. Nada fere o Homem Lua. Itens só iluminam, abrem ou são transportados.

### 3.1 Lanterna (item central da Temporada 1)
- Aparece pequena e deitada na mesa de piquenique. As anotações de campo dizem para pegá-la.
- Em primeira pessoa **não aparece na mão** (`LocalTransparencyModifier = 1`); outros jogadores a veem na mão do colega, acesa ou apagada (replicado por `ToggleLight`).
- Feixe preso à **câmera**, não ao braço: rotação com inércia exponencial (`RotationLag 10`), deriva base `0,26°` (`0,25×` parado; `1,55×` correndo), sem blur ao girar. Três cones: foco (68 studs, 18°, 2,8), meio (48, 36°, 1,15), derrame (30, 74°, 0,42). Só o foco projeta sombra. Um quarto `SpotLight` frontal largo (32 studs, 100°, 1,8), deslocado 4 studs à frente e 1 abaixo, preenche o piso próximo sem iluminar atrás do jogador.
- `[DECIDIDO]` Bateria: consumo lento + luz enfraquecendo (nunca apaga de vez sem aviso). Ainda não implementado.
- Ligar/desligar tem som seco de interruptor e é ouvido pelos outros a curta distância — a luz **denuncia** o jogador tanto quanto ajuda.

### 3.2 Itens de objetivo `[DECIDIDO]`
- **Chave** e **Código de acesso**: ocupam slot. Podem ser largados (G) e pegos por outro jogador — cooperação real: quem tem a chave não precisa ser quem tem o código.
- **CarryItem** (conceito guardado da versão anterior): objeto grande preso ao personagem, que reduz velocidade e impede correr; volta em uma temporada futura ou na casa.

---

## 4. Estrutura da rodada `[DECIDIDO]`

```
LOBBY (spawn no acampamento, todos juntos, ~1–2 min de "normalidade")
  → ENTRADA DO LABIRINTO (fecha atrás de cada jogador; fala + escurecimento)
  → SETOR 1  · Homem Lua só OBSERVA        · ~45 s andando
  → SETOR 2  · perseguição começa          · chave ou código aqui
  → SETOR 3  · zona mais perigosa          · chave ou código aqui
  → PORTÃO FINAL (CHAVE + CÓDIGO, ambos randomizados por rodada)
  → TRILHA FINAL → CASA → teaser do Homem Estrela → fim da Parte 1
```

- **Rodada**: 4–5 jogadores, começa quando o servidor enche ou após timer curto (`[EM ABERTO]`). Não há "voto de mapa": só existe a Temporada 1.
- **Acampamento** é a única zona relativamente segura, e isso é **sentido** (luz quente, fogueira, rádio, amigos), nunca confirmado (sem círculo, sem UI). O Homem Lua não entra no acampamento, mas pode ser visto da borda da mata (`[DECIDIDO]`, não implementado).
- **Não dá para voltar**: ao cruzar a entrada, parede local + cortina de névoa + pulso de blur. Depois do pulso permanece blur 1,5 e um grão procedural sutil (36 pontos + 2 linhas, atualização a cada 0,13 s). Quem ficou no acampamento continua vendo o acampamento normal. Isso é por jogador, não global; respawn remove o tratamento.
- **Progressão do Homem Lua** é dirigida por **setor** (Director): o setor mais avançado alcançado por qualquer jogador define o estado máximo permitido.
- **Morte/captura**: sem HP. Captura curta com jumpscare físico no mundo → tela preta → retorno a um ponto (acampamento ou início do setor, `[EM ABERTO]`) e o item crítico cai onde o jogador foi pego. Perder a rodada = todos capturados ou timer (`[EM ABERTO]`).
- **Vitória da Parte 1**: um jogador abre o portão; a trilha final e a casa são caminho sem Homem Lua (alívio falso), fechando no teaser do Homem Estrela.

---

## 5. Mapa — regras de design (Temporada 1)

### 5.1 Acampamento `[IMPLEMENTADO]`
Clareira ~84×74 studs. Spawn ao sul, virado para a fogueira → barracas → entrada ao norte. Tudo funcional e coerente com um acampamento real: fogueira, 3 barracas de expedição, cadeiras, mesa com rádio antigo, mapa e anotações de campo (as instruções do jogo, in-world), lenha, caixas, postes de madeira com lampiões, varal, cerca velha com corrente rompida e placa "TRILHA FECH DA". Paredes invisíveis só aqui (sul e lados), mascaradas por mata densa e névoa.

### 5.2 Labirinto — corpo e passada de qualidade `[IMPLEMENTADO — AGUARDANDO APROVAÇÃO]`
- Paredes são **formações de rocha em Terrain** (não muros): 26+ studs, assimétricas, saliências, musgo, pinheiros nas cristas. Sensação alvo: **floresta presa entre rochas**, não canyon nem corredor de jogo.
- Grade 11×12 células de 40 studs; layout gerado (DFS por setor + laços) e guardado em atributos de `Map/Maze/Layout` para o Homem Lua navegar pelo grafo.
- **Larguras medidas após o terceiro refinamento**: todas média 24,9/min 20,0; principais média 28,8/min 22,3; secundárias média 23,0/min 20,0. Núcleo limpo de 13 studs auditado com zero objetos colidíveis e travessia R6 validada nos três setores.
- O núcleo dos 151 corredores e 132 nós é plano a Y≈2; a faixa elevada central foi removida. Duas clareiras existentes reservam áreas livres para landmarks futuros: observatório em ruínas no S2 (64×44) e cabana abandonada no S3 (54×38). São apenas marcadores invisíveis por enquanto.
- **Nunca ver o fim de um corredor**: curvas, névoa, vegetação.
- **Sem paredes invisíveis dentro do labirinto.** Contenção é rocha e cinturão de mata.
- Colisão: terreno é a colisão principal; árvores só no tronco; samambaias, grama, pedras pequenas, troncos decorativos `CanCollide = false`.

### 5.3 Identidade dos setores `[COMPOSIÇÃO IMPLEMENTADA; GAMEPLAY DECIDIDO]`
| Setor | Sensação | Composição | Homem Lua |
|---|---|---|---|
| **1** | "Ainda parece uma trilha" | mais aberto, mais céu, corredores largos, poucas árvores dentro | **Watch** apenas: aparece em `MoonWatchPoints`, olha, some |
| **2** | "A floresta fechou" | mais denso, raízes, vegetação maior, curvas, névoa local, posto de vigia em ruínas | **Stalk/Approach/Chase** começam; chave **ou** código |
| **3** | "Isso é antigo e errado" | paredes mais altas, musgo, rocha irregular, árvores sobre as paredes, névoa, **silêncio** | mais ativo, cooldowns menores; chave **ou** código |

### 5.4 Chave e código `[DECIDIDO — não implementar até aprovação]`
- 6 candidatos no Setor 2 e 6 no Setor 3 (`Gameplay/FutureObjectiveSpawns/*`), atributos `Cell`, `Sector`.
- Servidor sorteia **um ponto para a chave e um para o código** no início da rodada; nunca o mesmo ponto, nunca no S1, no acampamento ou depois do portão. Podem cair ambos no mesmo setor.
- O código é um objeto físico (papel/placa/etiqueta) — o jogador **lê** o número e digita no portão; ou um item de slot (`[EM ABERTO]`).

### 5.5 Portão, trilha final e casa `[DECIDIDO]`
- Portão em `FutureGateMarker` (80, −670): precisa de chave (slot) + código (teclado in-world). Sem UI de "objetivo": quem chega ao portão entende.
- Trilha final: descompressão falsa, sem Homem Lua, som mudando.
- Casa: hall + 1–2 cômodos + porta de porão trancada. Ganchos orgânicos para T2/T3 (escada inacessível, grade, entrada técnica). Teaser do Homem Estrela: luz pisca, figura muito longe no corredor, some. Sem IA, sem chase.

---

## 6. Homem Lua — mecânica `[DECIDIDO, não implementado]`

Resumo de `06-homem-lua.md`, do ponto de vista de gameplay:

- **Camadas obrigatórias em ordem**: Watch → Stalk → Approach → Chase → Search/Hiding → Capture. Nunca começar pela perseguição. Cada camada é aprovada pelo Rick antes da próxima.
- **Director** central (estados Dormant, Watch, Stalk, Approach, Chase, Search, Capture, Cooldown): um único Homem Lua, cooldowns, aparições raras e com peso, progressão por setor.
- **Watch**: spawn em um `MoonWatchPoint` fora da câmera, a distância adequada; fica parado olhando; some quando ninguém olha por alguns segundos ou quando o jogador perde linha de visão. Quase sem áudio.
- **Chase**: com linha de visão vai direto; sem, `PathfindingService` até a última posição conhecida **ou** grafo do `Layout` (o navmesh não cobre todo o labirinto). Velocidade inicial 18–20 studs/s contra 11/17 do jogador — o jogador escapa por stamina, curvas e esconderijo, não por velocidade.
- **Esconderijo não é imunidade**: se ele viu o jogador entrar, sabe onde está. Só usa a informação que realmente teve (`LastSeenPosition`).
- **Captura**: ~1 s de câmera sem controle, braço entra no quadro, jogador puxado, rosto muito perto, som grave abafado, corte para preto. Sem barra de HP, sem ragdoll cômico.
- **Áudio**: nunca rugido/screamer. Hum grave, vento invertido, metálico distante, passos pesados abafados.
- Navegação: corredores com largura mínima 13–14 e curvas suaves para uma criatura de 3,5–4 m.

---

## 7. Áudio — regras de design

- **Camadas implementadas**: vento base baixo · copas · cama fria da floresta · eventos 3D espaciais aleatórios (galho, folhagem, coruja) · gancho de **silêncio controlado** (`ForestSilence`) pronto para o Director cortar as quatro famílias. O mixer muda gradualmente por setor; a cama cai até 0,30 no S3.
- Volumes nunca cobrem passos, respiração e amigos. Posicional sempre `RollOffMode = InverseTapered`; sem reverb em área aberta.
- **Passos por material** (grama/terra/madeira, 6 variações cada) sincronizados ao head bob e replicados em 3D. Sons padrão da Roblox silenciados.
- **Silêncio é ferramenta**: cortar a cama da floresta é o sinal mais forte de que o Homem Lua está perto. Usar pouco.
- Falas: curtas, em inglês, voz jovem adulta baixa e nervosa; **melhor sem voz do que com voz ruim** — enquanto não houver voz de qualidade, só legenda + `VoiceId` vazio documentado.

---

## 8. Luz e escuridão — regras de design

- Noite: `ClockTime 22.6`, lua, Atmosphere como névoa. Acampamento: quente (fogueira, lampiões) contra ambiente frio/azul.
- Labirinto: **escurecimento local por jogador** ao entrar (tween de 6 s): `Brightness 0,72`, `Exposure −0,58`, `Ambient (10,12,19)`, `OutdoorAmbient (22,27,39)`, Atmosphere `Density 0,74`, `Haze 10,5`, `Offset 0,48`, `Color (65,72,92)`, `Decay (12,16,26)`. Resultado alvo: muito escuro mas legível.
- Lanterna: foco `68 studs / 18° / 2,8`, médio `48 / 36° / 1,15`, spill `30 / 74° / 0,42`; apenas o foco projeta sombra. Preenchimento próximo com `SpotLight 32 / 100° / 1,8`, deslocado 4 studs à frente e 1 abaixo, sem sombras e sem emissão traseira. Inércia exponencial `RotationLag 10`, sway base `0,26°`, multiplicadores `0,25` parado e `1,55` correndo.
- Luzes com sombra: poucas (foco da lanterna, fogueira). `Lighting.Technology = Future` recomendado (só o Rick muda).
- Sem luzes gratuitas no labirinto: apenas manchas frias de luar onde a copa abre, e futuros pontos de composição (ruínas, posto de vigia).

---

## 9. Multiplayer — regras

- Estado por jogador para tudo que é sensorial (escurecimento, parede local, fadiga, falas). Estado global só para o que importa (Director, chave/código, portão, rodada).
- O que o outro jogador vê: corpo neutro R6, lanterna na mão (acesa/apagada), passos em 3D. O que **não** vê: efeitos de câmera, blur, UI alheia.
- Remotes mínimos e validados no servidor (`Footstep`, `ToggleLight`, `DropItem`, `ShowLine`); nunca confiar em valor vindo do cliente além de "qual dos valores da config".
- Sem chat de proximidade próprio por enquanto; sem nomes sobre a cabeça (`[DECIDIDO]`).

---

## 10. O que o jogo **não** tem (por decisão)

Terceira pessoa · HP/vida · combate ou itens ofensivos · minimapa/marcadores/bússola · loja, moedas, gamepasses que afetam gameplay · classes ou papéis · PvP · jumpscare de imagem 2D · texto meta ("safe zone", "season 2") · mundo aberto · personagens/monstros copiados de outros jogos.
