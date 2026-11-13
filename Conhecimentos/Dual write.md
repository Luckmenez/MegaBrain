---
tipo: conceito
area: Arquitetura
projetos: [cet-medicao]
criado: 2026-11-13
---
# Dual write

## O que é
Quando uma operação precisa gravar em **dois lugares** (duas tabelas em `SaveChanges` separados, ou o banco e
um sistema externo) e não há nada que garanta que as duas gravações aconteçam juntas. Se a segunda falha, a
primeira já ficou gravada e o sistema fica **pela metade**.

## Por que existe / que problema resolve
Não é um padrão, é um **problema** que se aprende a enxergar. Duas perguntas para fazer em todo caso de uso:
1. **E se cair no meio?** Entre a gravação A e a B, o que fica no banco?
2. **E se duas requisições vierem ao mesmo tempo?** As duas leem o mesmo estado antes de qualquer uma gravar?

## Como resolver
| Situação | Solução |
|---|---|
| Duas gravações no **mesmo banco** | Uma transação: [[Unit of Work]] (tudo ou nada) |
| Duas requisições disputando a mesma linha | `UPDATE` condicional: `WHERE RevogadoEm IS NULL`; se afetou 1 linha, venceu |
| Banco + **sistema externo** | Não há solução perfeita: chamar o externo no ponto que deixa a menor janela, fazer a chamada **idempotente**, ou guardar um "pendente" e enviar depois (*outbox*) |

## Como aparece no código

### No cet-medicao: resolvido no envio da medição
O envio confere o saldo, reserva o número e grava a medição **na mesma transação** (commit `a6ade20`):
```csharp
return await unidadeDeTrabalho.ExecutarEmTransacaoAsync(async () =>
{
    SaldoReservado reservado = await medicaoRepositorio.ObterSaldoReservadoAsync(contrato.Id, ct);
    ValidacaoDeSaldo.Validar(itens, contrato, reservado);
    int sequencial = await medicaoRepositorio.ReservarProximoNumeroAsync(hoje.Year, ct);
    // ... cria e grava a medição
}, ct);
```
Se a gravação falha, o contador do número volta junto: a sequência não fica com buraco.
Ver [[2026-11-04 Regras do envio na entidade antes da transação]].

### No cet-medicao: ainda aberto
`Aplicacao/UseCases/Autenticacao/Renovar/RenovarTokenUseCase.cs`:
```csharp
tokenAtual.Revogar(agora);
await refreshTokenRepositorio.AtualizarAsync(tokenAtual, ct);          // gravação 1
return await emissorDeSessao.EmitirAsync(tokenAtual.ObterUsuario(), ...); // gravação 2
```
- **Cai no meio:** se a gravação 2 falha, o token antigo já foi revogado e o usuário perde a sessão.
- **Concorrência:** duas renovações com o mesmo token (duas abas, ou o front repetindo a chamada) leem a
  linha ativa ao mesmo tempo e emitem **dois** tokens novos.

Correção combinada:
1. Consumir o token com `ExecuteUpdateAsync` condicional (`WHERE RevogadoEm IS NULL AND ExpiraEm > agora`).
2. Revogar e emitir o sucessor dentro de `IUnidadeDeTrabalho.ExecutarEmTransacaoAsync`.
3. No front, o interceptor do axios renova **uma vez só** e as outras chamadas esperam (*single-flight*).

### No cet-medicao: banco + CET no encaminhamento
`Aplicacao/UseCases/Medicoes/Encaminhar/EncaminharMedicaoUseCase.cs` (commit `c8d4b18`). Dentro da transação:
1. trava as medições do contrato e confere o saldo;
2. `medicao.Encaminhar(...)` e `SalvarAlteracoesAsync`;
3. **por último**, `cet.RegistrarEncaminhamentoAsync(...)`.

Por que a CET fica por último: se ela recusar, a exceção desfaz a transação e nada foi gravado aqui.
Mas sobra uma janela, que está num `TODO(MDC-182)` no código: **se a CET aceitar e o commit falhar**, a CET
fica com um encaminhamento que o banco não tem. Transação não desfaz HTTP. A saída prevista é um reenvio
**idempotente** (a CET aceitar o mesmo `MedicaoId` duas vezes sem duplicar).

Outro truque do mesmo arquivo: `Situacao` é **token de concorrência** no EF Core. O `UPDATE` sai com
`WHERE Situacao = 'ComGestor'`; se outro pedido já encaminhou, nenhuma linha é afetada, o EF lança
`DbUpdateConcurrencyException` (vira 409) e a CET não é avisada duas vezes.

## Pontos de atenção
- **Transação não cobre HTTP.** Com banco + sistema externo sempre sobra uma janela; escolha qual lado pode
  ficar "a mais" e como corrigir (idempotência, reenvio, *outbox*).
- Teste de unidade com mock não pega concorrência. Isso aparece em revisão de código ou em teste com banco de verdade.

## Com minhas palavras


## Relacionados
- [[Unit of Work]]
- [[Gateway]]
- [[2026-10-26 Sessão de 24h e CET só no login]]
