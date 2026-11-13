---
tipo: conceito
area: C#
projetos: [cash-flow, cet-medicao]
criado: 2026-11-13
---
# Injeção de dependência

## O que é
A classe **não cria** as coisas de que precisa: ela as **pede no construtor**, e o *contêiner* do .NET
entrega prontas. Quem decide qual implementação entregar é o registro feito na subida da aplicação.

```csharp
// a classe só declara o que precisa (construtor primário do C# 12)
internal sealed class EnviarMedicaoUseCase(ICetGateway cet, IMedicaoRepositorio medicaoRepositorio,
    IUnidadeDeTrabalho unidadeDeTrabalho, TimeProvider relogio) : IEnviarMedicaoUseCase

// o registro liga a interface à implementação
services.AddScoped<IEnviarMedicaoUseCase, EnviarMedicaoUseCase>();
```

## Por que existe / que problema resolve
- **Trocar a peça sem mexer em quem usa.** O caso de uso pede `ICetGateway`; hoje recebe o mock, amanhã
  a CET real. É o que faz a [[Arquitetura em camadas]] funcionar.
- **Testar.** No teste, você mesmo chama o construtor passando substitutos.
- **Controlar o tempo de vida** de cada objeto num lugar só.

## Os três tempos de vida
| Registro | Uma instância por... | Exemplo no cet-medicao |
|---|---|---|
| `AddSingleton` | aplicação inteira | `TimeProvider.System`, `CetGatewayMock`, `GeradorDeTokensJwt` |
| `AddScoped` | requisição HTTP | `MedicaoDbContext` (`AddDbContext`), repositórios, `UnidadeDeTrabalho`, casos de uso |
| `AddTransient` | cada vez que alguém pede | (não usado) |

**Por que o `DbContext` é scoped:** repositório e [[Unit of Work]] precisam da **mesma instância** dentro de
uma requisição, senão o `Commit` salva um contexto que não viu as alterações. E não pode ser singleton,
porque o `DbContext` não aguenta várias requisições ao mesmo tempo.

## Como aparece no código
- [[cash-flow]]: commit `b5e5e51`.
- [[cet-medicao]]: cada camada tem o próprio método de extensão, chamado no `Program.cs`:
  ```csharp
  // Aplicacao/DependencyInjectionExtension.cs
  public static IServiceCollection AddAplicacao(this IServiceCollection services, IConfiguration configuration)
  // Infra/DependencyInjectionExtension.cs
  public static IServiceCollection AddInfra(...)
  ```
  Assim o `Program.cs` não precisa conhecer as classes `internal` da Infra.

### `TimeProvider`: o relógio também é dependência
Os casos de uso pedem `TimeProvider relogio` e usam `relogio.GetUtcNow()` em vez de `DateTime.Now`.
No teste, entra um relógio falso parado numa data. É assim que dá para testar "registrada em 16/11 vira
competência de dezembro" sem esperar o dia 16.

## Pontos de atenção
- **Dependência cativa:** um singleton que recebe um scoped prende aquela instância para sempre. Se o
  `CetGatewayMock` (singleton) pedisse o `DbContext` (scoped), daria erro ou bug. Regra: um serviço só
  depende de outros que vivem **tanto quanto ele ou mais**.
- **Options com validação:** `AddOptions<JwtOpcoes>().Bind(...).Validate(...).ValidateOnStart()` faz a API
  **não subir** com configuração errada, em vez de quebrar na primeira requisição.

## Com minhas palavras


## Relacionados
- [[Arquitetura em camadas]]
- [[Unit of Work]]
- [[DbContext]]
