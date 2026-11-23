---
tipo: padrao
area: C#
origem: claude
revisado: false
criado: 2026-11-13
---
# Tratamento de erros

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.

## Três tipos de erro, três lugares
| Item | Tipo | Exemplo | Onde se confere | Vira |
|---|---|---|---|---|
| - [ ] | Entrada malformada | campo vazio, texto longo demais, fim antes do início | validator do FluentValidation | 422 |
| - [ ] | Regra de negócio | "só se encaminha medição que está com o gestor" | entidade ou caso de uso | 422 |
| - [ ] | Acesso e existência | não logado, sem permissão, não encontrado | caso de uso | 401, 403, 404 |

## Como
- [ ] Caso de uso e entidade **lançam exceções do domínio**; nunca devolvem `null` ou `bool` para dizer que deu erro.
- [ ] Todas as exceções num lugar só: pasta `Dominio/Excecoes/` (opção A) ou projeto `X.Exception` (opção B,
  quando há tradução). Ver [[Projetos da solução#Onde moram as exceções: duas opções]].
- [ ] Uma **classe base abstrata** comum (como a `CashFlowException` do [[cash-flow]]), com o `Codigo` do erro.
  *Por quê:* o tratador reconhece "erro nosso" com uma checagem só, e uma exceção nova não fica sem tratamento
  por esquecimento. Hoje o [[cet-medicao]] não tem base: cada tipo é tratado no `switch` do tratador.
- [ ] Uma exceção por significado, herdando da base:

  | Exceção | HTTP |
  |---|---|
  | `RegraVioladaException` (com `Campo`) | 422 |
  | `RequisicaoInvalidaException` | 400 |
  | `NaoAutorizadoException` | 401 |
  | `AcessoNegadoException` | 403 |
  | `NaoEncontradoException` | 404 |

- [ ] Toda exceção leva um **código de erro** estável (`CodigosDeErro.MedicaoInvalida`), além da mensagem.
  *Por quê:* o front decide pelo código; a mensagem pode mudar sem quebrar nada.
- [ ] Um `IExceptionHandler` (o `TratadorDeExcecoes`) traduz exceção para HTTP com **ProblemDetails**:
  `title` = mensagem, extensões `codigo` e `campo`. Validação do FluentValidation inclui `erros` por campo.
- [ ] Erro de banco conhecido (chave duplicada, concorrência) também é traduzido ali: concorrência vira 409.
- [ ] Mensagens para o usuário em português, dizendo o que fazer ("Informe ao menos um item medido.").
- [ ] Mensagens num arquivo `.resx` (`ResourceMensagensDeErro`), não em texto solto no código.
  *Por quê:* ficam todas num lugar, e traduzir vira acrescentar um `.resx` por idioma.
- [ ] Com tradução (opção B): um `ResourceMensagensDeErro.<idioma>.resx` por idioma; o .NET escolhe pela cultura
  da requisição (cabeçalho `Accept-Language`, com `UseRequestLocalization` no `Program.cs`).
- [ ] Erro inesperado não é tratado: vira 500 e vai para o log.

## Validação
- [ ] Entrada validada com FluentValidation (`AbstractValidator<T>` + `ValidateAndThrowAsync`), não com fila de `if`.
  Ver [[FluentValidation]].
