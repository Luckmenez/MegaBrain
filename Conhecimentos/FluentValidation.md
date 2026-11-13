---
tipo: conceito
area: C#
projetos: [cash-flow, cet-medicao]
criado: 2026-11-13
---
# FluentValidation

## O que é
Biblioteca que descreve as regras de **entrada** de uma requisição numa classe própria, com uma regra por
linha, em vez de uma fila de `if` + `throw` dentro do caso de uso.

## Por que existe / que problema resolve
- O caso de uso fica só com o **fluxo**; as regras de formato ficam num lugar fácil de ler e de testar.
- Junta **todos** os erros de uma vez (o front pode marcar vários campos), enquanto `if` + `throw` para no primeiro.
- Mensagem e código de erro ficam junto da regra.

## Como aparece no código
[[cet-medicao]], `Aplicacao/UseCases/Rascunhos/SalvarRascunhoValidador.cs` (commit `c98f919`):

```csharp
internal sealed class SalvarRascunhoValidador : AbstractValidator<SalvarRascunhoRequisicao>
{
    public SalvarRascunhoValidador()
    {
        RuleFor(r => r.ContratoId).NotEmpty()
            .WithErrorCode(CodigosDeErro.RascunhoInvalido).WithMessage("O contrato é obrigatório.");

        RuleFor(r => r.Fim).GreaterThanOrEqualTo(r => r.Inicio)
            .When(r => r.Inicio is not null && r.Fim is not null)
            .WithMessage("O fim do período não pode ser anterior ao início.");
    }
}
```

O fluxo inteiro:
```text
AddScoped<IValidator<SalvarRascunhoRequisicao>, SalvarRascunhoValidador>()   (registro)
   → CriarRascunhoUseCase recebe IValidator<...> no construtor
   → await validador.ValidateAndThrowAsync(requisicao, ct)
   → ValidationException → TratadorDeExcecoes → HTTP 422 com { codigo, campo, erros }
```
No [[cash-flow]] o mesmo padrão está no `RegisterExpensesValidator`.

## Pontos de atenção
- **Validação de entrada × regra de domínio.** "Campo obrigatório", "máximo 50 caracteres" e "fim depois do
  início" são entrada: validator. "Só se encaminha medição que está com o gestor" é regra de negócio:
  fica na entidade ([[Modelo de domínio rico]]). Regra que precisa do banco ou da CET ("o item é do
  contrato?") fica no caso de uso.
- **Pendente no cet-medicao:** `LoginUseCase` e `RenovarTokenUseCase` ainda validam com `if` + `throw`.
  Migrar para um validator cada, seguindo o `SalvarRascunhoValidador`.
- O `EnviarMedicaoUseCase` também tem muitos `if` de entrada (`ValidarEntrada`). Bom candidato para um validator.

## Com minhas palavras


## Relacionados
- [[Modelo de domínio rico]]
- [[Injeção de dependência]]
