---
tipo: conceito
area: Arquitetura
projetos: [cet-medicao]
criado: 2026-11-13
---
# Gateway

## O que é
Uma interface que representa um **sistema externo** (outra API, um serviço de e-mail, um ERP) na linguagem
do seu domínio. O resto do código fala com o gateway; só a implementação sabe de HTTP, URL e formato do outro lado.

É o "irmão" do [[Repository Pattern]]: o repositório esconde o **seu** banco, o gateway esconde o sistema
**dos outros**.

## Por que existe / que problema resolve
- **O outro sistema muda ou ainda não existe.** No cet-medicao a CET real ainda não tem os endpoints; com o
  gateway, o time desenvolve tudo contra um mock e troca depois, sem mexer nos casos de uso.
- **Testes.** No teste, o gateway vira um substituto (`Substitute.For<ICetGateway>()` com NSubstitute) que
  devolve o que o teste quiser.
- **Tradução.** O formato de lá não contamina o domínio: o gateway devolve tipos próprios (`ContratoCet`, `UsuarioCet`).

## Como aparece no código
Commit `6e177c2` do [[cet-medicao]].

```csharp
// Dominio/Gateways/ICetGateway.cs (a "porta", no Domínio)
public interface ICetGateway
{
    Task<bool> ValidarCredenciaisAsync(string login, string senha, CancellationToken ct);
    Task<ContratoDetalhadoCet?> ObterContratoAsync(string contratoId, CancellationToken ct);
    Task RegistrarEncaminhamentoAsync(MedicaoEncaminhadaCet medicao, CancellationToken ct);
    // ...
}
```

A implementação mock fica na Infra, e o registro tem uma **trava de segurança**:

```csharp
// Infra/DependencyInjectionExtension.cs
bool usarMock = bool.TryParse(configuration["Cet:UsarMock"], out bool valor) && valor;
if (!usarMock)
    throw new InvalidOperationException("A integração real com a CET ainda não existe...");

services.AddSingleton<ICetGateway, CetGatewayMock>();
```
Sem `Cet:UsarMock`, a API nem sobe. Assim o mock nunca roda em produção por engano.

## Pontos de atenção
- **Chamada externa e transação não combinam.** O banco desfaz um `INSERT`, mas não desfaz uma chamada HTTP
  que já foi feita. Por isso a ordem importa: ver [[Dual write]].
- Chamada externa é lenta e pode falhar: sempre passe o `CancellationToken` ([[async-await e CancellationToken]]).
- O mock é `Singleton` porque guarda dados em memória e não tem estado por requisição.

## Com minhas palavras


## Relacionados
- [[Arquitetura em camadas]]
- [[Repository Pattern]]
- [[Dual write]]
