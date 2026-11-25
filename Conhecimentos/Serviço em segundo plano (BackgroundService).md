---
origem: claude
revisado: false
tipo: conceito
area: .NET / EF Core
projetos: [cetsp-indicadores-termal]
criado: 2026-11-25
---
# Serviço em segundo plano (BackgroundService)

## O que é
Um trabalho que roda **dentro da API, sozinho**, sem esperar ninguém chamar um endpoint. Ele começa quando a API
sobe e para quando ela desliga. No .NET, é uma classe que herda de `BackgroundService` e é registrada com
`AddHostedService<T>()`.

## Por que existe / que problema resolve
Um controller só trabalha quando chega uma requisição, e precisa responder rápido. Tem trabalho que não cabe
nisso:
- **Coisas periódicas:** buscar a lentidão na CET de 5 em 5 minutos, mesmo sem ninguém com a tela aberta.
- **Coisas demoradas:** buscar um ano inteiro na CET leva horas. Ninguém espera isso numa requisição.

Com o serviço em segundo plano, a **tela só lê o resultado** do banco, e o trabalho pesado acontece no servidor.
Por isso ele **continua rodando com a aba fechada** ou o computador de quem usa desligado: ele vive na API, não no
navegador.

```text
Navegador ──► controller ──► lê do banco          (rápido, só quando alguém pede)
API sobe  ──► BackgroundService ──► CET ──► grava no banco   (sempre, sozinho)
```

## Como aparece no código
Projeto [[cetsp-indicadores-termal]], pasta `api/src/Cet.IndicadoresTermal.Api/Servicos/`, com dois serviços:

**`ColetaDoTermalEmSegundoPlano`** (a busca de 5 em 5 minutos, commit `4fcc65b`), com **`PeriodicTimer`**:

```csharp
using PeriodicTimer relogio = new(TimeSpan.FromMinutes(opcoes.Value.IntervaloEmMinutos));
do
{
    await ColetarAsync(ct);
}
while (await relogio.WaitForNextTickAsync(ct));
```

**`BuscaDeDiasAnterioresEmSegundoPlano`** (a fila dos dias anteriores, commit `a4069ad`), com **`Task.Delay`**:

```csharp
while (!ct.IsCancellationRequested)
{
    bool deuCerto = await BuscarAsync(ct);
    await Task.Delay(deuCerto ? intervalo : pausaAposFalha, ct);
}
```

**`PeriodicTimer` × `Task.Delay`:**
- O `PeriodicTimer` marca o **relógio**: 5 em 5 minutos, a cada 5 minutos certinhos. Bom para "de tempos em
  tempos".
- O `Task.Delay` depois do trabalho garante uma **pausa entre um e outro**, por mais que o trabalho demore. Bom
  para não pesar num sistema de fora: se um dia levar 9 s na CET, ainda vêm 10 s de pausa antes do próximo.

## Pontos de atenção
- **Um escopo por ciclo.** O serviço é **singleton** (vive a vida inteira da API), mas o [[DbContext]] é
  **scoped** (deve durar pouco). Por isso cada volta cria um escopo novo e pede o caso de uso dentro dele:
  ```csharp
  await using AsyncServiceScope escopo = escopos.CreateAsyncScope();
  var buscar = escopo.ServiceProvider.GetRequiredService<IBuscarDiaAnteriorUseCase>();
  ```
  Ver [[Injeção de dependência]].
- **Uma falha não pode derrubar o serviço.** Toda volta fica num `try/catch` que só registra no log: se a exceção
  escapar do `ExecuteAsync`, o serviço morre e não volta.
- **Desligar com educação.** O `CancellationToken` do `ExecuteAsync` é cancelado quando a API desliga: o
  `catch (OperationCanceledException) when (ct.IsCancellationRequested)` encerra sem erro. Ver
  [[async-await e CancellationToken]].
- **Se a API parar, ele para junto.** Por isso o estado do trabalho fica no **banco** (a fila em
  `DiaPedidoNaCet`): quando a API volta, ele continua de onde parou.
- **Mais de uma instância da API** (vários servidores) rodaria o serviço em cada uma. Hoje há uma só; se isso
  mudar, precisa de uma trava.

## Com minhas palavras
_(escrito por mim, não pelo Claude)_

## Relacionados
- [[Repository Pattern]]: o repositório só lê; quem grava é o serviço
- [[Gateway]]: o serviço chama a CET pelo `IWazeApiGateway`
- [[2026-11-24 Buscar os dias anteriores por uma fila no banco]]
