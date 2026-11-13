---
tipo: decisao
projeto: cet-medicao
data: 2026-11-04
status: aceita
---
# Regras do envio na entidade antes da transação

## Contexto
No [[cet-medicao]], enviar uma medição tem regras (período válido, ao menos um item, quantidades maiores que
zero, termo de aceite obrigatório). Elas estavam espalhadas entre o caso de uso e a entidade, e a revisão do
código apontou que as mesmas regras eram conferidas em dois lugares. Além disso, enviar **reserva o próximo
número** da medição (`GSV-0001/26`): um envio inválido não podia gastar número. Commit `cc58052`.

## Opções consideradas
1. Deixar as regras no caso de uso.
2. Deixar só na entidade, conferidas quando ela é criada (dentro da transação).
3. Colocar as regras **na entidade**, num método estático público `MedicaoDeContrato.ValidarEnvio`, chamado pelo caso
   de uso **antes** de abrir a transação, e de novo dentro de `MedicaoDeContrato.Enviar`.

## Decisão e porquê
**Opção 3.**
- A regra mora num lugar só, a entidade: ver [[Modelo de domínio rico]].
- Chamar antes da transação faz o envio inválido falhar cedo, sem travar linha nem reservar número.
- Chamar de novo dentro do `Enviar` garante que a entidade **nunca nasce inválida**, mesmo que um caso de uso
  futuro esqueça de validar.

```csharp
// Aplicacao/UseCases/Medicoes/Enviar/EnviarMedicaoUseCase.cs
MedicaoDeContrato.ValidarEnvio(requisicao.PeriodoInicio, requisicao.PeriodoFim, itens, anexos);

return await unidadeDeTrabalho.ExecutarEmTransacaoAsync(async () =>
{
    // saldo + número + gravação: tudo ou nada
}, ct);
```

## Consequências
- A regra roda duas vezes num envio válido. O custo é desprezível: são conferências em memória.
- Hoje o número vem de um contador no próprio banco (`ReservarProximoNumeroAsync`), **dentro** da
  transação. Se a gravação falhar, o contador volta junto e a sequência fica sem buraco.
  Ver [[Unit of Work]] e [[Dual write]].
