---
tipo: conceito
area: .NET / EF Core
projetos: [cash-flow]
criado: 2026-11-11
---
# Unit of Work

## O que é
Um objeto que junta várias alterações no banco e grava **todas de uma vez**, numa única transação.
O repositório só *prepara* a alteração; o Unit of Work é quem dá o "salvar".

## Por que existe / que problema resolve
Sem ele, cada repositório chamaria `SaveChanges()` sozinho. Se um caso de uso mexe em duas
tabelas e a segunda gravação falha, a primeira já foi salva e o banco fica pela metade.
Com o Unit of Work, ou grava tudo, ou não grava nada.

Também separa responsabilidades:
- **Repositório:** sabe *o que* adicionar/alterar.
- **Caso de uso:** decide *quando* está tudo pronto para gravar.

## Como aparece no código
Commit `d686b1e` do [[cash-flow]].

```csharp
// src/CashFlow.Infrastructure/DataAccess/IUnitOfWork.cs
public interface IUnitOfWork
{
    void Commit();
}

// src/CashFlow.Infrastructure/DataAccess/UnitOfWork.cs
public void Commit() => _dbContext.SaveChanges();
```

O fluxo no `RegisterExpenseUseCase`:
1. `_repository.Add(entity)`: o [[DbContext]] passa a *rastrear* a despesa (ainda não foi ao banco).
2. `_unitOfWork.Commit()`: chama `SaveChanges()` e o EF gera o `INSERT`.

**Por que funciona:** repositório e Unit of Work recebem **a mesma instância** de `CashFlowDbContext`.
Isso acontece porque o `AddDbContext` registra o contexto como **scoped** (uma instância por
requisição HTTP), ver [[Injeção de dependência]]. Se fossem instâncias diferentes, o `Commit`
salvaria um contexto que não sabe nada da despesa adicionada.

## Pontos de atenção
- **Onde fica a interface?** Hoje `IUnitOfWork` está em `CashFlow.Infrastructure`, e por isso
  o `CashFlow.Application` passou a referenciar a Infrastructure. Na arquitetura em camadas o
  normal é o contrário: a interface fica no **Domain** (igual a `IExpenseRepository`) e só a
  implementação fica na Infrastructure. Assim a Application não depende de detalhe de banco.
  **Decidido:** manter como está, seguindo o curso. Ver [[2026-11-11 Manter IUnitOfWork na Infrastructure]].
- O próprio `DbContext` do EF Core já é um Unit of Work. A interface `IUnitOfWork` serve
  para o caso de uso não depender do EF diretamente.

## Com minhas palavras
A ideia de implementar esse tipo de prática é fazer com que a aplicação mantenha a atomicidade do ACID. Eu preparo as operações e faço o commit de uma vez só.
Isso mantém o banco de dados mais organizado.

## Relacionados
- [[Repository Pattern]]
- [[DbContext]]
- [[Injeção de dependência]]
