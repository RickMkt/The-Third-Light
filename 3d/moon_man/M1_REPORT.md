# Homem Lua — Fase M1: Blockout

Status: **concluída e parada no portão de aprovação**.

Este arquivo registra somente o blockout de proporções e silhueta. Não foram criados rosto detalhado,
crateras, texturas finais, UV final, rig, bones, skinning, animações ou exportação para Roblox.

## Entrega

- Fonte editável: `source/MoonMan_M1_Blockout.blend`
- Referência principal empacotada no `.blend`: `reference/HomemLua_concept.png`
- Script reprodutível: `source/build_m1_blockout.py`
- Renders individuais: `renders/01_front.png` até `renders/10_flashlight_test.png`
- Pranchas: `renders/M1_*_contact_sheet.png`

## Medidas

| Medida | Resultado |
|---|---:|
| Altura total | 11,515 studs |
| Dummy R6 | 5,45 studs |
| Razão Homem Lua / R6 | 2,113× |
| Diâmetro da cabeça | 2,34 studs |
| Cabeça / altura | 20,3% |
| Largura visual dos ombros | ~2,0 studs |
| Distância entre articulações dos ombros | 1,52 studs |
| Ombro até ponta da mão | ~5,915 studs |
| Inclinação visual frontal | ~7–8° para frente |
| Mesh objects do personagem | 17 |
| Triângulos aproximados | 4.684 |

## Estrutura do blockout

O personagem está separado em cabeça, pescoço, peito, abdômen, pelve, braços, antebraços, mãos,
coxas, pernas e pés. Essa separação existe apenas para ajuste de proporções e leitura de futuras
articulações; não há armature ou rig.

Materiais de trabalho:

- `MAT_MoonMan_Body_Blockout`: quase preto, roughness alta, reage discretamente à luz.
- `MAT_MoonMan_Head_Blockout`: amarelo lunar quente com emissão baixa, ainda sem textura ou rosto.
- `MAT_R6_Scale_Reference`: cinza neutro para comparação.

## Avaliação crítica

| Critério | Nota | Leitura atual |
|---|---:|---|
| Silhueta | 8,0/10 | Cabeça circular, corpo estreito e braços abaixo dos joelhos sobrevivem bem à distância. |
| Originalidade | 7,0/10 | O contraste cabeça/corpo já assina o personagem; o rosto será decisivo para fugir do humanoide alto genérico. |
| Uncanny feeling | 6,5/10 | A escala e a postura incomodam, mas a esfera sem rosto limita deliberadamente esta leitura na M1. |
| Proporções | 8,0/10 | A escala R6 e os braços funcionam; a cabeça está no limite superior e deve ser aprovada antes do refino. |
| Animação futura | 8,0/10 | Volumes reservam ombro, cotovelo, punho, quadril e joelho sem travar a topologia futura. |
| Adequação ao Roblox | 9,0/10 | Blockout leve, 4.684 triângulos e escala compatível com o labirinto planejado. |

## Decisão necessária antes da M2

A cabeça ocupa 20,3% da altura e é ligeiramente mais larga que os ombros. Isso garante leitura imediata
no escuro, mas a deixa deliberadamente icônica. Se a intenção for parecer mais humano à distância,
a alternativa é reduzir o diâmetro em aproximadamente 5–8%. Recomenda-se aprovar ou ajustar esse ponto
antes de refinar mãos, pés e transições anatômicas.

## Validação técnica

- Coleção `M1_MOON_MAN_BLOCKOUT`: presente.
- Meshes do personagem: 17.
- Armatures: 0.
- Bones: 0.
- Referência: empacotada no `.blend`.
- Dez renders: presentes.
- Resultado do validador: `valid_m1 = true`.

## Limites desta prova

Os cenários de árvores, rocha e corredor são massas de teste, não partes do mapa real. O teste de
lanterna imita um feixe frio estreito, mas a confirmação final de leitura precisa ocorrer no Roblox
Studio com a iluminação viva do place, depois da aprovação das proporções.
