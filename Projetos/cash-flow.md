---
tipo: projeto
repo: C:\Users\USER\dev\cash-flow
status: ativo
---
# cash-flow

## O que é
API para registrar e controlar despesas. Projeto de estudo de .NET.

## Stack
- .NET (ASP.NET Core, controllers)
- EF Core + MySQL (Pomelo), MySQL 8.4 em container (`compose.yaml`)
- FluentValidation

## Arquitetura (camadas)
| Projeto | Papel |
|---|---|
| `CashFlow.Api` | Controllers, filtros, middleware, `Program.cs` |
| `CashFlow.Application` | Casos de uso (ex. `RegisterExpenseUseCase`) |
| `CashFlow.Domain` | Entidades (`Expense`) e interfaces de repositório |
| `CashFlow.Infrastructure` | `CashFlowDbContext`, repositórios, [[Unit of Work]] |
| `CashFlow.Communication` | DTOs de request/response |
| `CashFlow.Exception` | Exceções da aplicação |

## Conceitos usados aqui
- [[Unit of Work]] (commit `d686b1e`)
- [[Repository Pattern]] (commit `6ea6817`)
- [[DbContext]] (commit `61e1210`)
- [[Injeção de dependência]] (commit `b5e5e51`)

## Decisões
_(nenhuma registrada ainda)_

## Próximos passos
- [ ] Decidir onde mora a interface `IUnitOfWork` (ver [[Unit of Work#Pontos de atenção]])
