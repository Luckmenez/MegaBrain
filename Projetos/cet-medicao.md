---
tipo: projeto
repo: https://github.com/RautakiTecnologia/cetsp-medicao-de-contratos
pasta: ~/dev/cet/cet-medicao
status: ativo
---
# cet-medicao

## O que é
Sistema de **medição de contratos** (trabalho). O fiscal de um contrato registra o que foi executado no
período (itens e quantidades, com anexos como o termo de aceite) e envia ao gestor. O gestor assina e
encaminha à Financeira, ou devolve ao fiscal para correção.

Dados de usuários e contratos vêm de um sistema externo, a **CET**, por meio de um [[Gateway]]. Por
enquanto ele é um mock (`CetGatewayMock`), porque a integração real ainda não existe.

### Ciclo de vida da medição
```text
Rascunho ──enviar──▶ ComGestor ──encaminhar──▶ EnviadaFinanceira
                        │  ▲
                devolver│  │corrigir (ainda não existe)
                        ▼  │
                     Devolvida ──▶ Corrigida
(Cancelada: feito pela Financeira fora do sistema)
```
Quem garante que só se encaminha uma medição `ComGestor` é a própria entidade: ver [[Modelo de domínio rico]].

## Stack
- **API:** .NET 10, ASP.NET Core (controllers), EF Core + SQL Server, JWT, FluentValidation
- **Testes:** xUnit, NSubstitute, AwesomeAssertions, SQLite em memória
- **Web:** Vite + React + TypeScript, TanStack Router/Query, cliente gerado pelo **Orval** a partir do OpenAPI
- Versões dos pacotes num lugar só: `api/Directory.Packages.props` (Central Package Management)

## Arquitetura (camadas)
Mesma ideia do [[cash-flow]], mas com a regra de dependência levada a sério: ver [[Arquitetura em camadas]].

| Projeto | Papel |
|---|---|
| `Cet.Medicao.Api` | Controllers, `Program.cs`, `TratadorDeExcecoes` (exceção → HTTP), JWT |
| `Cet.Medicao.Aplicacao` | Casos de uso (`EnviarMedicaoUseCase`...), validadores |
| `Cet.Medicao.Comunicacao` | DTOs de requisição e resposta (records) |
| `Cet.Medicao.Dominio` | Entidades, regras, **interfaces** de repositório, gateway e [[Unit of Work]] |
| `Cet.Medicao.Infra` | EF Core, repositórios, `UnidadeDeTrabalho`, `CetGatewayMock`, geração de tokens |

### Contrato da API → front
```text
controllers + records (C#) ──build──▶ api/openapi/Cet.Medicao.Api.json ──npm run api:gerar──▶ web/src/api/gerado/
```
O `Name = "..."` da rota vira o nome do hook (`useListarContratos`) e o `[ProducesResponseType<T>]` vira o tipo.
Sem eles o front recebe `unknown`. C#, JSON do contrato e código gerado vão **no mesmo commit**.

### Erros
Casos de uso lançam exceções do domínio; o `TratadorDeExcecoes` (um `IExceptionHandler`) traduz para HTTP
com `ProblemDetails`:

| Exceção | HTTP |
|---|---|
| `RegraVioladaException`, `ValidationException` (FluentValidation) | 422 |
| `RequisicaoInvalidaException` | 400 |
| `NaoAutorizadoException` | 401 |
| `AcessoNegadoException` | 403 |
| `NaoEncontradoException` | 404 |

Commit `c442f10`.

## Conceitos usados aqui
- [[Arquitetura em camadas]]: a regra de dependência e onde mora cada interface
- [[Gateway]]: `ICetGateway` no Dominio, mock na Infra (commit `6e177c2`)
- [[Unit of Work]]: `IUnidadeDeTrabalho` no Dominio com `ExecutarEmTransacaoAsync` (commit `a6ade20`)
- [[Dual write]]: o problema que a transação resolve, e um caso ainda aberto
- [[Modelo de domínio rico]]: `MedicaoDeContrato` com setters privados e métodos `Enviar`/`Encaminhar`/`Devolver`
- [[Injeção de dependência]]: `AddAplicacao` e `AddInfra`, scoped × singleton, `TimeProvider`
- [[async-await e CancellationToken]]: todo caso de uso recebe `CancellationToken ct`
- [[FluentValidation]]: `SalvarRascunhoValidador`
- [[Records]]: DTOs da `Comunicacao` e `SaldoReservado`

## Decisões
- [[2026-10-26 Sessão de 24h e CET só no login]]
- [[2026-11-04 Regras do envio na entidade antes da transação]]
- [[2026-11-12 Adiar o Início do gestor até a história]]

## Próximos passos
- [ ] **Dual write na renovação do token.** O `RenovarTokenUseCase` revoga o token antigo e grava o novo em
  dois `SaveChanges` separados. Ver [[Dual write#No cet-medicao: ainda aberto]].
- [ ] **FluentValidation no login e na renovação**, no lugar dos `if` + `throw` (padrão já usado no
  `SalvarRascunhoValidador`). Ver [[FluentValidation]].
- [ ] Fechar a janela do encaminhamento (`TODO(MDC-182)`): CET aceitou e o commit falhou. Ver
  [[Dual write#No cet-medicao: banco + CET no encaminhamento]].
- [ ] Ligar o fluxo de **correção** (`Corrigida`), hoje só previsto em TODOs da `MedicaoDeContrato`.
- [ ] Trocar o `CetGatewayMock` pela integração real quando a CET entregar os endpoints.
