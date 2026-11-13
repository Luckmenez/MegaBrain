---
tipo: conceito
area: C#
projetos: [cet-medicao]
criado: 2026-11-13
---
# async-await e CancellationToken

## O que é
- **`async`/`await`**: enquanto espera o banco ou a rede, a thread **volta para o servidor** atender outra
  requisição, em vez de ficar parada. Quando a resposta chega, o método continua de onde parou.
- **`CancellationToken`**: um aviso de "pode parar". O ASP.NET dispara esse aviso quando o cliente desiste
  (fechou a aba, deu timeout).

Para quem vem do JS: `Task<T>` é a `Promise<T>`, e o `CancellationToken` é o `AbortSignal`.

## Por que existe / que problema resolve
Uma API passa quase todo o tempo **esperando** (SQL Server, CET). Com chamadas síncronas, cada requisição
prende uma thread durante a espera e o servidor esgota as threads com pouca carga.

O `CancellationToken` evita trabalho jogado fora: se o usuário saiu, não faz sentido terminar uma consulta
pesada nem chamar a CET.

## Como aparece no código
No [[cet-medicao]], o token nasce no controller e é **repassado em toda a cadeia**:

```csharp
// Api/Controllers/MedicoesController.cs: o ASP.NET preenche o ct sozinho
public async Task<ActionResult<MedicoesListadas>> Listar(..., CancellationToken ct)
    => Ok(await listarMedicoesUseCase.ExecutarAsync(UsuarioId(), filtro, ct));

// caso de uso → repositório → EF Core
SaldoReservado reservado = await medicaoRepositorio.ObterSaldoReservadoAsync(contrato.Id, ct);
```

Convenções que o projeto segue:
- Método assíncrono termina em `Async` e devolve `Task` ou `Task<T>`.
- O `CancellationToken ct` é sempre o **último** parâmetro.

## Pontos de atenção
- **Nunca** `.Result` ou `.Wait()` numa `Task`: bloqueia a thread (perde o benefício) e pode travar.
- **`async void` só em evento.** Em qualquer outro lugar, devolva `Task`: exceção em `async void` derruba o processo.
- **Esqueceu o `await`?** A `Task` roda solta e a exceção se perde. O compilador avisa (CS4014): leia os avisos.
- **Repasse o `ct` até o fim.** Um método que recebe `ct` e não o repassa ao EF corta a corrente: o cancelamento
  para ali.
- `await using` (como na `UnidadeDeTrabalho`) é o `using` para objetos que se fecham de forma assíncrona,
  como a transação do banco.

## Com minhas palavras


## Relacionados
- [[Injeção de dependência]]
- [[Gateway]]
