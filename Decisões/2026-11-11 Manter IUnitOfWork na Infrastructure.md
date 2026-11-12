---
tipo: decisao
projeto: cash-flow
data: 2026-11-11
status: aceita
---
# Manter IUnitOfWork na Infrastructure

## Contexto
No commit `d686b1e` do [[cash-flow]], a interface `IUnitOfWork` foi criada em
`src/CashFlow.Infrastructure/DataAccess/IUnitOfWork.cs`. Para o `RegisterExpenseUseCase`
conseguir usá-la, o `CashFlow.Application.csproj` passou a referenciar o `CashFlow.Infrastructure`.

Na arquitetura em camadas, isso é um desvio: a Application não deveria depender da camada de banco.
Ver [[Unit of Work#Pontos de atenção]].

## Opções consideradas
1. **Mover a interface para o Domain** (`CashFlow.Domain/Repositories/IUnitOfWork.cs`), como já é o
   `IExpenseRepository`, e remover a referência da Application para a Infrastructure.
2. **Manter como está**, seguindo o curso.

## Decisão e porquê
**Opção 2.** O objetivo do projeto é aprender acompanhando o curso até o fim. Se eu mudar a estrutura
agora, as próximas aulas deixam de bater com o meu código, e cada passo vira uma adaptação.

## Consequências
- A Application continua conhecendo a Infrastructure (`using CashFlow.Infrastructure.DataAccess`).
  Funciona, mas a separação entre as camadas fica menos rígida.
- Se o curso corrigir isso mais para frente, atualizar esta nota com o commit da correção.
- Se eu levar esse padrão para um projeto próprio, colocar a interface no Domain desde o início.
