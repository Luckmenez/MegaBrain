---
tipo: post-linkedin
tema: Tempos de vida na injeção de dependência
status: rascunho
publicado_em:
---
# Copo, caneca ou garrafa?

Conceito: [[Injeção de dependência]] · projeto de estudo: [[cash-flow]] · registro: [[Posts do LinkedIn]]

## Conceito
Os 3 tempos de vida como recipientes do escritório: **Transient** = copo descartável (um novo a cada
pedido), **Scoped** = caneca da reunião (uma por requisição), **Singleton** = garrafa de café da
firma (uma para a app toda). Estilo **lousa**, em 3 colunas. Cada recipiente tem um número (`#1`,
`#2`...), e contadores mostram pedidos × objetos criados.

Primeira versão no estilo caderno (3 faixas), refeita em lousa para não repetir a cara do post do
Unit of Work.

## Roteiro
- **Título:** Copo, caneca ou garrafa? · *os 3 tempos de vida da injeção de dependência no .NET*
- **Legenda:** pessoa azul = reunião 1 (requisição 1); pessoa rosa = reunião 2 (requisição 2).
- **Transient** (`AddTransient`): copos `#1` a `#4` saem do dispensador, um por pedido, e vão para a
  lixeira. "copo novo a cada pedido, até na mesma reunião". Fim: 4 pedidos → 4 copos.
- **Scoped** (`AddScoped`): a caneca nasce no primeiro pedido da reunião e é a mesma para todos ali;
  na reunião 2 nasce a `#2`. "mesma reunião, mesma caneca (o DbContext é assim)". Fim: 2 canecas.
- **Singleton** (`AddSingleton`): a garrafa `#1` serve todo mundo. "a mesma para todo mundo,
  cuidado: acesso simultâneo". Fim: 1 garrafa.
- **Código:** os 3 registros com exemplo genérico, alinhados:
  `AddTransient<IEnviaEmail, EnviaEmail>()`, `AddScoped<IPedidoRepository, PedidoRepository>()` e
  `AddSingleton<IConfiguracao, Configuracao>()`. Sem citar o cash-flow (quem lê não conhece).
- **Legibilidade:** giz leve (`chalkText`) nos textos e nos números; `AddX` em mono negrito, 29 px.
- **Ciclo:** 10 s; no fim, um apagador passa pelos contadores. O MP4 tem 3 ciclos (30 s).

## Texto do post (escrito pelo Lucas)

## Revisão
