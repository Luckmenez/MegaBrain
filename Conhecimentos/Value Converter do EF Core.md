---
origem: claude
revisado: false
tipo: conceito
area: .NET / EF Core
projetos: [cet-medicao]
criado: 2026-11-17
---
# Value Converter do EF Core

## O que é
Um `ValueConverter` ensina o EF Core a transformar uma propriedade do C# em algo que o banco sabe guardar, e
de volta na leitura. O uso mais comum é guardar uma lista ou um objeto pequeno como **JSON numa coluna só**,
sem criar uma tabela para ele.

## Por que existe / que problema resolve
Nem todo dado merece uma tabela. Os itens apontados numa devolução (`[{"Codigo":"1.1","Motivo":"..."}]`) e o
que mudou numa correção são sempre lidos **junto** com o registro e nunca filtrados por dentro. Uma tabela
filha traria chave estrangeira, join e migration a mais sem ganho nenhum. Com o converter, a entidade continua
usando tipos ricos (`List<ItemApontado>`, `AlteracoesDaCorrecao`) e o banco vê só um texto.

## Como aparece no código
`api/src/Cet.Medicao.Infra/DataAccess/Configuracoes/ConversorDeItensApontados.cs` (commit `cad67fe`):

```csharp
public static ValueConverter<IReadOnlyList<ItemApontado>, string> Conversor { get; } = new(
    itens => JsonSerializer.Serialize(itens, (JsonSerializerOptions?)null),
    json => JsonSerializer.Deserialize<List<ItemApontado>>(json, (JsonSerializerOptions?)null) ?? new List<ItemApontado>());

// Sem o comparador, o EF compara a lista pela referência e não percebe uma lista nova com os mesmos itens.
public static ValueComparer<IReadOnlyList<ItemApontado>> Comparador { get; } = new(
    (a, b) => a!.SequenceEqual(b!),
    itens => itens.Aggregate(0, (hash, item) => HashCode.Combine(hash, item.GetHashCode())),
    itens => itens.ToList());
```

Na configuração da entidade: `.HasConversion(Conversor, Comparador)`. O mesmo jeito guarda o que mudou na
correção, no `ConversorDeAlteracoesDaCorrecao` (commit `b64cc34`).

## Pontos de atenção
- **Coleção mutável precisa de `ValueComparer`.** O EF decide se precisa salvar comparando o valor atual com uma
  cópia do valor lido. Para uma lista, a comparação padrão é pela referência: alterar a lista sem trocar a
  referência passaria despercebido. O comparador diz como comparar, como calcular o hash e como copiar.
- **Valor nulo não passa pelo converter.** Para uma coluna anulável, o EF grava `NULL` sozinho. O tipo do
  converter pode ser anulável (`ValueConverter<T?, string>`) só para o compilador não reclamar.
- **Migration de dado tem que poder rodar duas vezes.** Ao trocar o formato do JSON (de `["1.1"]` para
  `[{"Codigo":"1.1","Motivo":""}]`), a migration converteu de novo um registro que já estava no formato novo e o
  "embrulhou" duas vezes. A correção foi filtrar só o formato antigo (`WHERE coluna LIKE N'[[]"%'`). Regra:
  `UPDATE` de dado numa migration sempre confere se o dado ainda precisa da mudança (é idempotente).
- Funciona no SQLite em memória dos testes, então dá para testar a gravação de verdade.
- Se um dia for preciso **filtrar** por algo de dentro do JSON, vale repensar: tabela própria, ou o mapeamento
  JSON nativo do EF (`OwnsMany(...).ToJson()`).

## Com minhas palavras
_(escrito por mim, não pelo Claude)_

## Relacionados
- [[Migrations]]
- [[DbContext]]
- [[Records]]: `ItemApontado` é um record, por isso a igualdade por valor funciona no comparador
- [[cet-medicao]]
