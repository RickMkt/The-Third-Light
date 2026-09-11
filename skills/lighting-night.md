# Skill: iluminação noturna

## Noite do jogo (estado atual)
`ClockTime 22.6`, `Brightness 1.4`, `ExposureCompensation −0.15`, `Ambient (26,28,38)`, `OutdoorAmbient (56,62,82)`, `ColorShift_Top (150,165,200)`, `EnvironmentDiffuseScale 0.45`, `EnvironmentSpecularScale 0.35`, Sky com `MoonAngularSize 16`, `SunAngularSize 0`, `StarCount 2000`; Bloom 0,25 / 40 / 1,2; DoF far 0,25 a partir de 18 studs; SunRays 0. Atmosphere: ver `terrain-and-forest.md`.

## Luz quente local
- Fogueira: part invisível **acima** das toras (`FireLight`, +2,8): Core PointLight 3,8 / 24 studs com sombras + Halo 0,8 / 38 sem sombras. Luz dentro/abaixo do terreno é ocluída e "não acende".
- Lampião: núcleo 9 studs / 1,4 laranja com sombras + halo 19 / 0,35 âmbar. Lanterna: foco 24° / 62 / 2,6 com sombras + derrame 72° / 28 / 0,45.
- Tremulação: tag `FlickerLight` + atributos `BaseBrightness`, `Flicker` (0,12 chama; 0,35 lampião morrendo; 0,22 fogueira), `FlickerSpeed` (7–9). `LightFlicker` (cliente) usa ruído em duas oitavas; zero tráfego de rede.
- Não iluminar demais: as bordas da clareira devem sumir no escuro. Sem postes modernos.
- `Lighting.Technology = Future` (ação do Rick) faz spot/point lights projetarem sombras por pixel — grande diferença.

## Luz de revisão (temporária, só para screenshots de layout)
Salve `ClockTime, Brightness, ExposureCompensation, Ambient, OutdoorAmbient, Atmosphere.Density/Haze/Offset` em `_G.savedLighting`; aplique `ClockTime 14`, `Brightness 2`, `Expo 0`, ambientes 110/130, `Density 0.15`, `Haze 0.5`, `Offset 0`. **Restaure sempre** ao terminar (confira `ClockTime == 22.6`).
