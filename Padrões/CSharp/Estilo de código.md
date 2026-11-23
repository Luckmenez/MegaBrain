---
tipo: padrao
area: C#
origem: claude
revisado: false
criado: 2026-11-13
---
# Estilo de código

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.

## Classes e tipos
- [x] Classes `internal sealed` por padrão; `public` só o que outra camada precisa enxergar.
- [x] Construtor primário para receber dependências: `class X(IRepo repo, TimeProvider relogio)`.
- [x] `record` para DTOs e objetos de valor. Ver [[Records]].
- [x] Coleções com `[]` (`List<Item> itens = [];`) e listas expostas como `IReadOnlyList<T>`.
- [x] Tipo explícito no lugar de `var` (`List<ItemMedicao> itens = ...`).
  *Por quê:* lendo fora da IDE (no GitHub, num diff), dá para saber o tipo sem passar o mouse.
- [x] `Nullable` ligado e levado a sério: `string?` só onde nulo é permitido de verdade.
- [x] Sempre chaves `{ }` no `if`, mesmo com uma linha.
- [x] Constantes com nome no lugar de número solto (`TamanhoMaximoOrdemServico = 50`).

## Async
- [x] Método assíncrono termina em `Async` e recebe `CancellationToken ct` como **último** parâmetro, repassado até
  o EF e o HTTP. Ver [[async-await e CancellationToken]].
- [x] Nunca `.Result` nem `.Wait()`.

## Dependências e configuração
- [x] `TimeProvider` injetado no lugar de `DateTime.Now`. *Por quê:* dá para testar datas.
- [x] Configuração em classes de Options com `.Validate(...)` e `.ValidateOnStart()`: config errada impede a API de subir.
- [x] Segredos fora do repositório: User Secrets em desenvolvimento, variável de ambiente no servidor.

## Nomes
- [x] Em projeto meu: domínio e casos de uso em português (`MedicaoDeContrato`, `EnviarMedicaoUseCase`), sufixos
  técnicos em inglês (`UseCase`, `Async`, `Exception`).
- [x] Em projeto de curso: seguir os nomes do curso.
- [x] Geralmente existe um apontamento no README.md para dizer que é curso ou não, caso contrário pode ser perguntadol.

## Comentários
- [x] Comentário explica o **porquê** ou uma regra de negócio, não o que a linha faz.
  Exemplo bom: `// O ano do número é o do envio, não o da competência`.
- [x] Pendência conhecida vira `// TODO(<card>): ...` com o que falta e quando rever.
