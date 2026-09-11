# Homem Lua — Fase M2: Refino do corpo

Status: **concluída e parada no portão de aprovação da M2**.

A M1 foi aprovada pelo Rick. Esta etapa refina exclusivamente o corpo, mãos, dedos, pés, ombros e
forma geral. Não foram criados rosto final, relevo lunar final, texturas finais, UV final, rig, bones,
skinning ou animações.

## Ajustes solicitados após a M1

- Cabeça reduzida em 6%, preservando a leitura circular.
- Altura total preservada em 11,5 studs.
- Pescoço reduzido para aproximadamente 0,34 stud de altura visível.
- Postura inclinada para frente preservada.
- Ombros estreitos e tronco tubular preservados, sem musculatura ou detalhes monstruosos.
- Braços e antebraços mantidos longos; mãos receberam mais presença e cinco dedos alongados.

## Refino M2

- Torso contínuo com perfil estreito e deslocamento progressivo para frente.
- Ombros discretos, elevados e não musculosos.
- Braços e antebraços afunilados, reservando leitura de ombro, cotovelo e punho.
- Palmas maiores e dedos individualizados: polegar, indicador, médio, anelar e mínimo.
- Dedos econômicos, alongados e sem unhas ou garras.
- Pernas longas e afuniladas, com joelhos discretos.
- Pés humanos simplificados, mais compridos que o normal.

## Métricas

| Medida | Resultado |
|---|---:|
| Altura total | 11,5 studs |
| Redução da cabeça | 6% |
| Diâmetro da cabeça placeholder | 2,2 studs |
| Altura visual do pescoço | ~0,34 stud |
| Meshes do personagem | 42 |
| Meshes de segmentos dos dedos | 20 |
| Triângulos aproximados | 9.348 |
| Armatures / bones | 0 / 0 |

## Entrega

- Fonte editável: `source/MoonMan_M2_Body.blend`
- Script reprodutível: `source/build_m2_body.py`
- Métricas: `M2_metrics.json`
- Renders: `renders/M2_01_front.png` até `renders/M2_08_dark_test.png`
- Pranchas: `renders/M2_orthographic_contact_sheet.png` e `renders/M2_validation_contact_sheet.png`

## Avaliação crítica

- A silhueta permanece reconhecível e ganhou leitura mais humana nas mãos e pés.
- A redução da cabeça deixou a figura menos caricata sem perder sua assinatura.
- O pescoço curto aproxima a esfera do corpo e melhora o desconforto visual.
- O corpo permanece deliberadamente simples; a identidade final dependerá da cabeça na M3 e do
  movimento após o rig.
- As peças ainda são volumes separados porque a retopologia está reservada para a M4.

## Limites desta etapa

A cabeça continua sendo apenas um placeholder esférico. Não há rosto, olhos, crateras, mapas,
textura final ou emissão definitiva. Não avançar para a M3 sem aprovação explícita da M2.
