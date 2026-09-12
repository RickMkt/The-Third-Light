# Maze V2-B — levantamento antes da ampliação central (12/09/2026)

Estado lido diretamente no place em **Edit**, sem mudança de Terrain nesta etapa. Base restaurável atual: `ServerStorage/_Backup_2026-09-12_preMazeV2A`, commit `172a3ea`, tag local `checkpoint-before-maze-v2b-central`. A única cópia `.rbxl` em `backups/` ainda é `TheThirdLight_2026-09-11_preGraybox.rbxl` — está antiga demais para ser checkpoint do V2-A. **Não escavar até Rick confirmar `Ctrl+S` e novo `.rbxl` atual.**

## O que Claude deixou no V2-A

- Grafo de 11×12 células (40 studs) e 165 links; S1/S2/S3 ainda têm 4 linhas e área nominal igual de **70.400 studs²** cada. S2 ocupa **33,3%** das três faixas nominais, não é o maior. Links internos: S1 52, S2 53, S3 56 (ciclos internos estimados 9/10/13 se cada subgrafo é conexo).
- Quatro reservas invisíveis no S2, nenhuma estrutura final construída: `RangerCabin` em `(-160,-440)` 40×46, `Observatory` em `(0,-360)` 56×56, `WatchPost` em `(120,-320)` 30×34, `TechnicalArea` em `(160,-401)` 30×40. Clareira S3 `AncientFoundation` em `(120,-560)`. Cabana antiga S3 arquivada.
- Acessos de grafo dos centros: Cabana 4, Observatório 4, Posto 3, Área Técnica 2. Centros das quatro áreas não têm linha de visão direta (raycast de Terrain na altura dos olhos).
- Distâncias curtas pelo grafo, a 11 studs/s: Cabana↔Observatório **8 links/29 s**; Observatório↔Posto **4/15 s**; Observatório↔Técnica **5/18 s**; Posto↔Técnica **3/11 s**. Cabana↔Posto 12/44 s e Cabana↔Técnica 13/47 s são pares não adjacentes. Tempos são estimativas por 40 studs/link, não cronometragem de Play.
- Workspace: **5.731 BaseParts**, **5.460 MeshParts**, 63 ParticleEmitters, 12 luzes. Floresta: S1 274, S2 372, S3 455, área do portão 153 = **1.254 árvores**; sub-bosque: 165/224/187 = **576** instâncias. Os documentos anteriores misturam estatísticas pré-V2; estes valores foram recontados no place.

## Diagnóstico e direção de implementação

O problema medido não é falta de acesso ou visão direta (esses pontos já estão razoáveis). O núcleo do S2 tem a **mesma profundidade de 160 studs** que S1/S3, enquanto concentrará quatro landmarks; Posto e Área Técnica ficam separados por apenas 90 studs em linha reta e 3 links. O S2 precisa de um intervalo adicional de floresta e de pequenos loops, não de quatro vazios maiores justapostos.

Opção técnica preferida para o graybox de Terrain: inserir uma faixa central de **40 studs** entre as linhas atuais 4 e 5, mantendo S1 com 4 linhas, convertendo S2 para 5 e trasladando S3/portão **40 studs** ao sul, sem ampliá-los. Isso dá S2 nominal **88.000 studs² (+25%)**, participação **38,5%** no mapa de 13 linhas: claramente maior que os outros dois, embora abaixo da proporção conceitual de 45%. Ampliar de 25–35% e atingir 45% exatos ao mesmo tempo é matematicamente incompatível mantendo S1/S3 em 4 linhas; a instrução do Rick permite proporção aproximada e prioriza o crescimento central.

Uma nova linha não deve virar corredor transversal reto: distribuir 2–3 subrotas com curvas e ligações verticais, aumentando ciclos do S2 e dando percurso adicional principalmente entre Posto e Técnica. Revisar `Layout` (`Rows`, `OpenWalls`, `Clearings`, zonas, candidatos, pontos futuros), `MazeAmbienceController` (limite S2/S3) e todos os marcadores deslocados. Confirmar que a camada de Terrain inserida se conecta aos voxels existentes antes de mover decoração. Alternativa menos segura conceitualmente: só ampliar clareiras/corredores no S2, pois aumenta área livre mas quase não muda o tempo entre estruturas.

Alvos de clareira após testar o Terrain: Cabana ~40×45 (já quase atende); Observatório ~60×65; Posto ~35×40; Técnica ~40×45. Bordas irregulares e não totalmente planas; piso central apenas onde futuro footprint exige. Volumes de teste removíveis/invisíveis para verificar cabimento e ocupação — **não construir estruturas**. Nota de proporção: footprint futuro da Cabana 18×22 ocupa só **22%** de uma reserva retangular 40×45; para chegar a 30–45% da *área útil*, a borda irregular teria de reduzir a área útil ou o footprint precisaria incluir varanda/circulação. Não forçar agora uma clareira menor só para cumprir porcentagem.

## Portão obrigatório antes de executar

1. Studio em Edit (confirmado na inspeção).
2. Rick confirma `Ctrl+S` e salva `.rbxl` **atual** em `backups/` (pendente na inspeção).
3. Criar novo snapshot interno V2-B, incluindo `Terrain:CopyRegion` e clones de Map/Gameplay/Lighting/scripts afetados; confirmar backup anterior.
4. Só então mover/esculpir Terrain, atualizar grafo e marcadores; testar Play, console, FPS e rotas; screenshots em luz de revisão e restauração da câmera/iluminação. Parar antes de qualquer estrutura final.
