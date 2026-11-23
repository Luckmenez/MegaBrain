---
tipo: padrao
area: C#
origem: claude
revisado: true
criado: 2026-11-13
---
# Projetos da solução

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.
O mapa concreto para montar uma solution nova. O porquê está em [[Arquitetura em camadas]].

## Os projetos
| Item  | Projeto         | O que tem                                                                                            | Referencia                          |
| ----- | --------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------------- |
| - [x] | `X.Api`         | controllers, `Program.cs`, tratador de exceções, autenticação                                        | Aplicacao, Comunicacao, **Infra**   |
| - [x] | `X.Aplicacao`   | casos de uso, validadores, mapeadores                                                                | Dominio, Comunicacao                |
| - [x] | `X.Comunicacao` | records de requisição e resposta (DTOs)                                                              | nada                                |
| - [x] | `X.Dominio`     | entidades, objetos de valor, exceções (opção A, ver abaixo), **interfaces** de repositório e gateway | nada (ou `X.Exception`, na opção B) |
| - [x] | `X.Infra`       | EF Core, repositórios, migrations, gateways, geração de tokens                                       | Dominio                             |
| - [x] | `X.Tests`       | um projeto de testes para tudo, com pastas por camada                                                | Api (e por tabela, o resto)         |

```text
Api ──▶ Aplicacao ──▶ Dominio ◀── Infra
 │          │                       ▲
 │          └──▶ Comunicacao        │
 └──────────────────────────────────┘  (só para chamar AddInfra no Program.cs)
```

## Regras
- [x] **Dominio e Comunicacao não referenciam ninguém** e não instalam pacote de framework (nada de EF Core).
- [ ] **A Api referencia a Infra diretamente.** A Aplicacao **não** referencia a Infra.
  *Por quê:* no [[cet-medicao]] a Aplicacao referencia a Infra (commit `b8f8372`) só para a Api enxergar o
  `AddInfra` por tabela; nenhum arquivo da Aplicacao usa a Infra. Funciona, mas deixa um caso de uso usar o
  `DbContext` direto sem o compilador reclamar. Com a referência na Api, a Aplicacao fica protegida.
- [ ] Classes da Infra são `internal`; a Infra só expõe o método `AddInfra`.
- [ ] Cada camada registra os próprios serviços num método de extensão (`AddAplicacao`, `AddInfra`),
  chamado no `Program.cs`.
- [ ] `InternalsVisibleTo` para o projeto de testes enxergar as classes `internal`.
- [ ] `Directory.Build.props` na raiz com o que vale para todos: `TargetFramework`, `Nullable` e
  `ImplicitUsings` ligados, avisos como erro no Release.
- [ ] Solution no formato novo `.slnx`.

## O que vai na Api e na Aplicacao
- [ ] Um caso de uso por ação, com interface própria (`IEnviarMedicaoUseCase`) e um método `ExecutarAsync`.
- [ ] O controller só recebe, chama o caso de uso e devolve o DTO. Nenhuma regra no controller.
- [ ] A entidade não sai da API: o caso de uso devolve DTO da `Comunicacao`, montado por um mapeador.

## Onde moram as exceções: duas opções
Escolha uma por projeto. O critério é a **necessidade**, não o tamanho.

| | Opção A: pasta `Dominio/Excecoes/` | Opção B: projeto `X.Exception` |
|---|---|---|
| Quando usar | um idioma só, uma solução só | mensagens **traduzidas**, ou exceções compartilhadas entre soluções |
| Projetos na solução | um a menos | um a mais |
| Quem referencia | quem já referencia o Dominio | Dominio, Aplicacao e Api |
| Exemplo | [[cet-medicao]] | [[cash-flow]] (`CashFlow.Exception`) |

- [ ] **Começar pela opção A** e passar para a B quando a tradução aparecer.
  *Por quê:* a mudança é barata (mover a pasta, ajustar namespace e referências), então não vale pagar
  um projeto a mais antes de precisar.
- [ ] Na opção B, o projeto `X.Exception` **não referencia ninguém**, e o Dominio pode referenciá-lo.
  *Por quê:* com [[Modelo de domínio rico]], a própria entidade lança exceção, então o Dominio precisa enxergá-las.
  No cash-flow o Dominio não referencia porque as entidades são simples e quem lança é a Application.

```text
Opção B:
Api ──▶ Aplicacao ──▶ Dominio ──▶ Exception
 │          └────────────────────▶ Exception
 └───────────────────────────────▶ Exception
```
