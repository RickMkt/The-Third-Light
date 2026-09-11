# Ambiente — Acampamento

Coordenadas com norte = −Z, centro da clareira em (0, 0), chão em y ≈ 2,5.

| Elemento | Posição / notas |
|---|---|
| Spawn | (0, 3.5, +30), olhando para −Z: fogueira → barracas → entrada |
| Fogueira | (0, 0): asset Synoou afundado 0,6; `FireLight` a +2,8 (Core 3,8 / 24 studs com sombras, Halo 0,8 / 38, tremulação); som `Crackle`; chão de basalto |
| Cadeiras | (5.5, −5.5), (−7, −3), (3, 8); tora de assento em (−6.5, 3.5) |
| Barracas | (−26, −13) rot 35°, (23, −17) rot −40°, (−23, 15) rot 140°; escala 0,95–1,05 |
| Mesa de trabalho | mesa de piquenique em (12, −3) rot −0,35 rad: rádio antigo, `MapSheet`, `FieldNotes` (SurfaceGui), pickup **Lanterna** deitado (`PickupRotation` (0,35,0), `PickupScale` 0,8) |
| Poste da mesa | (15.5, −7.5) com lampião estático `CampLantern` |
| Postes de madeira | `LampPost_Arrival` (−12, 24), `LampPost_East` (31, −3), `LampPost_Gate` (−17, −34, quase apagado) |
| Caixas / tambor / lenha | SE (19–25, 4–14); segunda pilha de lenha em (−16, −20) |
| Tocos | (−33, 6), (28, 24) |
| Varal + toalha | entre (−34, −20) e (−24, −30) |
| Cerca velha + corrente + placa | z = −42; abertura entre os postes x −8,5 e +8 |
| Rochas da entrada | oeste: centro (−31, −64), 44×40, topo ~25; leste: (32, −66), 46×44, topo ~31; abertura 12–18 studs; corredor limpo x ±9 de z −36 a −96; rocha de fundo em (−26, −132) |
| Trilha da entrada | (0, −14) → (0, −60) → (−10, −104) → (−24, −118), Mud/Ground |
| Trilha de chegada | (0, 18) → (24, 110) → (14, 170), Ground/Sand; sem árvores num raio de 11; névoa densa além de z 58 |
| Névoa | 8 emissores na borda + 4 fortes na trilha sul; entrada mais densa |
| Limites | paredes invisíveis em z +58, x ±62, z −126; mata densa (espaçamento 8, escala 1,1–1,6) além delas |
| Gatilho | `MazeEntrance` em (0, 10, −62), 22×16×6 |

Floresta: densidade por ruído (clusters), anel irregular denso na borda da clareira, corredor da entrada denso. Total ≈ 1.259 pinheiros; ~1.700 parts; 60 fps no Studio.

Terreno: base LeafyGrass 440×460 centrada em (0, −20); chão pisoteado (Ground) ao redor do fogo; lama a SW. As superfícies de terreno ficam ~2 studs acima do valor nominal do `FillBlock` (grade de voxels) — sempre posicionar por raycast.

Texto das anotações de campo (in-world, sem sobrenatural explícito):
> ANOTAÇÕES DE CAMPO — 3ª noite · A trilha ao norte foi interditada. Não passem da cerca sem lanterna. · Fiquem juntos. Quem se afasta não escuta o resto do grupo. · Marquem o caminho. É fácil se perder depois da pedra. · Voltem antes do amanhecer. · Se ouvirem alguma coisa, não respondam.
