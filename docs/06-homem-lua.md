# 06 · Homem Lua — brief de design (não implementado)

O Rick fará o modelo 3D e as animações. Só depois de o acampamento e o Setor 1 estarem aprovados começamos o comportamento. Este documento guarda as decisões para quem for implementar.

## Visual (referência: concept art "Homem Lua v0.1")
- Muito alto: ~3,5–4 m em proporção visual (≈ 3× o R6). Corpo fino, humanoide simples, preto/escuro fosco. Braços muito longos, mãos grandes com dedos alongados, pernas longas, ombros discretamente altos, tronco um pouco comprido.
- Cabeça esférica com textura lunar; rosto **humano demais**: sorriso quase amigável, olhos humanos, expressão teatral, vale da estranheza. Brilho suave (material/SurfaceAppearance emissivo + PointLight fraquíssimo + Bloom do ambiente). Visível entre as árvores à distância, nunca uma lâmpada.
- Postura: raramente ereto — levemente inclinado para a frente, como alguém muito alto olhando alguém menor. Quando finalmente ficar ereto, deve parecer muito maior do que o jogador imaginava.
- Proibido: espinhos, ossos, carne, músculos, asas, tentáculos, armadura, dentes monstruosos, olhos sangrando, "demônio genérico". O erro anatômico só aparece quando se olha melhor.
- Inspiração de sensação em figuras como "That Isn't the Moon" — **sem copiar** personagem/modelo de outro artista.

## Rig
Root, Pelvis, Torso, UpperTorso, Neck, Head, braços (Upper/Lower/Hand) e pernas (Upper/Lower/Foot); menos bones se não prejudicar. `AnimationController` ou `Humanoid` (se pathfinding/movimento ficarem mais simples). Não é um R6 gigante escalado.

## Animações (MVP)
Idle (quase imóvel: respiração mínima, sway, cabeça inclinando devagar) · Walk (lenta, passos longos, braços soltos, elegância estranha — nada de zumbi) · Fast Walk/Chase (passos enormes, mais ereto; a velocidade parece impossível pelo tamanho das pernas) · Observe · Turn Head · Capture · (Search depois). Cabeça segue o jogador com ângulo limitado e interpolação; às vezes o corpo aponta para um lado e a cabeça continua olhando para o jogador.

## Comportamento por camadas (ordem obrigatória)
1. **Watch** — aparece em um `MoonWatchPoint` quando o jogador está a distância adequada, o ponto não está perto demais e, de preferência, fora da câmera no instante do spawn. Fica parado. Olha. Some quando ninguém olha por alguns segundos ou quando o jogador perde a visão por obstáculo. Aparições raras, com peso. Quase nenhum áudio (talvez mudança mínima do ambiente).
2. **Stalk** — com progressão, aparece gradualmente mais perto, em outra lateral da trilha.
3. **Approach** — caminha alguns metros em direção ao jogador, para, observa, some. Nem toda aproximação vira perseguição.
4. **Chase** — só depois das anteriores estarem boas. Com linha de visão: direto ao jogador; sem: `PathfindingService` até a última posição conhecida. Velocidade inicial 18–20 studs/s (jogador 11/17) — ajustar jogando. Stamina do jogador é parte central.
5. **Hiding/Search** — armários primeiro. Esconderijo não é imunidade: se ele **viu** o jogador entrar (`LastSeenPosition`/`LastSeenHidingSpot`), anda até a porta, para, olha, espera, talvez abre. Se perdeu antes, procura. Respeitar só a informação que a IA realmente tinha.
6. **Capture** — sem barra de HP. Sem item crítico: captura curta, jumpscare físico no mundo (câmera perde o controle ~1 s, braço entra no campo de visão, jogador é puxado, câmera sobe, rosto da Lua muito perto, som grave abafado, corte para preto), retorno a ponto seguro ou consequência leve. Com item crítico: derruba o item / interrompe o transporte. Uma boa captura antes de variações.

## Director (controller central)
Estados sugeridos: Dormant, Watch, Stalk, Approach, Chase, Search, Capture, Cooldown. Controla progressão, cooldowns, aparições, estado; nunca dois Homens Lua sem querer. Progressão por avanço dos jogadores (na estrutura nova: Setor 1 observa, Setor 2 persegue, Setor 3 mais ativo; retorno/portão = sequência forte).

## Áudio
Nada de rosnado/rugido/screamer. Hum grave, vento invertido, som metálico distante, ruído muito baixo, passos pesados abafados. Durante Watch: quase silêncio.

## Casa e Homem Estrela (Temporada 1)
Só teaser: ex. o jogador pega algo, a luz pisca, o Homem Estrela aparece muito longe no corredor e some. Sem IA, sem chase.
