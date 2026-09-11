# Skill: terreno, rochas, trilhas, floresta, névoa

## Terreno
- `Terrain:FillBlock/FillBall/FillCylinder/FillWedge`. A superfície resultante fica **~2 studs acima** do topo nominal (grade de 4 studs) — posicione tudo por raycast (`RaycastParams` Include Terrain, `IgnoreWater = true`).
- Leia alturas **em uma chamada separada** da que preencheu (leituras logo após o fill podem vir defasadas).
- Rampas: `FillBlock` base + `FillWedge` (lado alto = +Z do CFrame → `CFrame.lookAt(mid, a)` com `a` na base). R6 não sobe degraus > ~2 studs: suavize transições com cunhas curtas.
- Pads planos sob construções; "chão gasto" (Ground) em pátios; Mud perto de água; trilhas = faixa larga Ground/Mud + faixa central mais clara (Sand) levemente afundada; postes de trilha a cada ~42 studs; placas nas bifurcações.
- Rocha orgânica: bloco central Rock + 30–35 `FillBall` jitterizadas (r 4–9) + calotas LeafyGrass no topo + pedras na base; depois carve o corredor com Air e refill do chão. Alturas de 22–31 studs funcionam para paredes.
- Água: carve Air, Ground no fundo, Water acima; vau = Ground até −1 com pedras Rock.

## Floresta
- Templates em `ServerStorage/Assets/TreeTemplates` (pivot na base). Colocar por grade jitterizada + **campo de densidade por ruído** (`math.noise` em 2 escalas) → clusters e vãos; anel denso e irregular ao redor de clareiras; mata de 7–15 studs margeando trilhas; densidade 0 em trilhas/edificações/água; inclinação ±4°, escala 0,85–1,4; cinturão externo mais denso e maior (1,1–1,6).
- Orçamento: 2.500–3.300 pinheiros (2 MeshParts cada) deram 58–60 fps no Studio com StreamingEnabled.
- Tocos/troncos caídos: assets ou cilindros Wood, metade nas beiras das trilhas.
- Remover árvores que caem em trilhas (distância à polilinha < 9–11).

## Névoa
- `Atmosphere` global: densidade 0,68, haze 9,5, offset 0,4, cor clara (104,112,128), decay escuro — névoa, não escuridão.
- Névoa rasteira: parts invisíveis com `ParticleEmitter` (textura `rbxasset://textures/particles/smoke_main.dds`), tamanho 14–30, vida 8–16 s, rate 0,6–4, alpha 0,45–0,9, cor (120–150, 130–160, 156–186), `LightInfluence 1`. Mais densa onde se quer esconder (entrada, trilha de chegada).
- Rocha de fundo + curva na trilha para nunca ver o fim.
