---
tipo: decisao
projeto: cet-medicao
data: 2026-11-12
status: aceita
---
# Adiar o Início do gestor até a história

## Contexto
O protótipo da tela inicial do gestor (rota `/recebidas`) mostra indicadores (KPIs) "A encaminhar",
"Enviada à Financeira", "Devolvida" e "Cancelada", um bloco "Medições por situação" e a lista das medições
recebidas do fiscal. Nenhum card do Jira cobria essa tela ainda, e a tela de recebidas atual é de outra
pessoa do time.

## Opções consideradas
1. Implementar já, a partir do protótipo.
2. **Esperar a história** chegar, deixando as decisões anotadas.

## Decisão e porquê
**Opção 2.** Sem história, o escopo pode mudar e o trabalho seria refeito. Mexer na tela de outra pessoa
sem combinar gera conflito de merge e de responsabilidade.

Já decidido para quando a história vier:
- "Mês vigente" é a **competência** da medição (`MesReferencia`), definida ao criar.
- "A encaminhar" conta `ComGestor` + `Corrigida`, sem filtro de mês.
- Devolvidas **não** entram na lista de recebidas, por enquanto.
- Os números do bloco "Medições por situação" saem dos dados reais (o protótipo conta errado).
- Construir os blocos como **componentes novos** e encaixar na página depois.

## Consequências
Faltam dados na API para quando a história vier:
- sigla e nome da unidade organizacional (UO) no resumo do contrato da listagem;
- a data em que a medição chegou ao gestor (hoje só existe `AtualizadaEm`).
