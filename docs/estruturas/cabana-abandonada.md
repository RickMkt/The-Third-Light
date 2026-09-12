# Cabana abandonada — proposta de composição

> Estado: **proposta aguardando aprovação do Rick**. Nenhuma geometria da cabana foi construída.

## Função

A cabana é um landmark do Setor 3 e uma antiga instalação de apoio florestal, abandonada antes da expedição atual. Ela deve orientar o jogador, oferecer um possível ponto físico para chave/código e criar linhas de visão perigosas. **Não é zona segura** e não terá texto meta, eletricidade funcional ou exposição longa de lore.

## Implantação

- Área reservada existente: centro `(120, 2, -560)`, **54×38 studs**, rotação `Y=-5°`, célula `8,10`.
- A célula recebe corredores pelos quatro lados. A cabana ocupa o quadrante nordeste para preservar uma circulação em L, larga, pelo oeste e pelo sul.
- Centro proposto do corpo: `(129, 3.2, -568)`, acompanhando a rotação `-5°` da clareira.
- Corpo: **30×18 studs**. Varanda frontal: **20×4**. Parede: 10,5 studs; cumeeira: 16 studs.
- Piso elevado 1,2 stud sobre apoios baixos, com dois degraus quebrados. Frente voltada para sul/sudoeste, visível ao entrar na clareira, mas não de um corredor distante.

```text
                           NORTE (-Z)
                               ↓
                     passagem larga pelo oeste
                   ┌──────────────┐
                   │              │ ┌───────────────┐
OESTE  ───────────►│              │ │ fundo quebrado│
                   │ circulação   │ │   CABANA      │
                   │ livre 14+    │ │  30 × 18      │
                   │              │ └──────┬────────┘
                   └──────────────┴── varanda/porta ◄── LESTE
                                  passagem sul
                                       ↓
                                      SUL
```

## Arquitetura visual

- Silhueta simples de cabana de serviço: madeira escura, estreita e envelhecida; telhado de duas águas em metal oxidado.
- Um canto traseiro/direito cedeu. A ruptura cria uma segunda visão para o interior e impede que a construção funcione como abrigo invulnerável.
- Fachada assimétrica: porta deslocada, uma janela com duas tábuas e outra abertura sem vidro. Nada perfeitamente reto.
- Interior de um cômodo com uma pequena divisória incompleta: mesa de trabalho, prateleira caída e cama/catre deteriorada. Máximo de 6–8 props na fase de acabamento.
- Sem luz elétrica. A lanterna do jogador deve ser a principal leitura do interior; luar entra pelo telhado e pela parede rompida.

## Circulação e gameplay futuro

- Faixa livre mínima externa: **14 studs** pelo oeste e pelo sul; as quatro conexões do grafo continuam utilizáveis.
- Porta normal para o jogador e ruptura traseira ampla para manter duas rotas de fuga e múltiplas linhas de visão.
- O Homem Lua não precisa atravessar a porta: ele pode contornar, observar pelas aberturas e cortar a saída. A cabana não concede imunidade.
- Um ponto de objetivo pode existir sobre a mesa, mas chave/código, interação e esconderijo continuam fora desta etapa.

## Construção em etapas

1. **Graybox:** 18–24 parts, corpo/varanda/telhado/duas aberturas; testar as quatro aproximações e cápsula do Homem Lua.
2. **Casca:** madeira e metal, 45–65 parts, colisão somente em piso, paredes e vigas essenciais.
3. **Danos e composição:** canto rompido, tábuas, 6–8 props e vegetação assentada no perímetro.
4. **Atmosfera:** uma névoa local discreta e sons de madeira/vento; sem iluminação gratuita.

## Fora desta aprovação

Chave/código funcional, esconderijo, IA, evento do Homem Lua, porta interativa, áudio final e qualquer lore escrito.

