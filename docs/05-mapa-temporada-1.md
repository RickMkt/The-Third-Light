# 05 · Mapa da Temporada 1

## Direção atual (decidida em 11/09/2026, substitui o mapa de POIs espalhados)

```
ACAMPAMENTO → ENTRADA DO LABIRINTO → SETOR 1 → SETOR 2 → SETOR 3 → PORTÃO FINAL → TRILHA FINAL → CASA → teaser Homem Estrela → fim da Parte 1
```

| Área | Estado | Função |
|---|---|---|
| Acampamento | **construído** (ver `sistemas/ambiente-acampamento.md`) | spawn, última zona relativamente segura, instruções in-world, lanterna |
| Entrada do labirinto | **construída** (rochas, cerca, névoa, fala, fechamento) | curiosidade e medo; fecha atrás do jogador |
| Setor 1 | a desenhar | zona inicial; Homem Lua **só observa** (MoonWatchPoints) |
| Setor 2 | a desenhar | Homem Lua começa a perseguir; chave/código podem aparecer |
| Setor 3 | a desenhar | zona mais perigosa, Homem Lua mais ativo; chave/código podem aparecer |
| Portão final | a desenhar | precisa de CHAVE + CÓDIGO |
| Trilha final + casa | a desenhar | teaser do Homem Estrela (sem IA); portas para as temporadas 2 e 3 existem organicamente |

Referência visual do Rick: mapa-protótipo em três setores com paredes de pedra, posto de vigia em ruínas no Setor 2, esconderijos, watch points da Lua, rotas alternativas.

## Regra de chave e código (guardada; implementar nos Setores 2/3)
- Dois elementos para abrir o portão: **KEY** e **ACCESS CODE**, ambos **randomizados a cada partida**.
- Spawn points pré-definidos em `Gameplay/FutureObjectiveSpawns/Sector2KeyCodeSpawns` e `Sector3KeyCodeSpawns`.
- Nunca no acampamento, no Setor 1, fora do labirinto ou depois do portão. Chave e código nunca no mesmo ponto.
- No início da rodada o servidor sorteia um ponto válido para cada.

## Linguagem do labirinto (a validar no Setor 1)
- Paredes = formações de rocha em Terrain (como na entrada), 18–31 studs, assimétricas, com musgo, raízes e pinheiros nas cristas; boulders MeshPart nos cantos. Aprovar o estilo com um trecho curto antes de estender.
- Corredores que dobram (nunca ver o fim), clareiras pequenas, atalhos, esconderijos (armários/ruínas), névoa rasteira, sons pontuais.
- Watch points escolhidos pela composição (entre árvores, atrás de rocha, no alto, pela janela), 12–16 por setor no início.

## Mapa anterior (arquivado)
Floresta 650² com trailer, camping, galpão, casa do guarda, banheiro, rio/ponte/vau, casa principal no platô. POIs em `ServerStorage/_Archive_2026-09-11_grayboxV1_POIs`. Lições que continuam válidas: tempos de trilha (11 studs/s → 16 s para 180 studs), pathfinding como teste de navegação, névoa + curvas para esconder o tamanho real.
