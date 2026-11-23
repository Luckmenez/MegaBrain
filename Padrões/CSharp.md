---
tipo: padrao
area: C#
origem: claude
revisado: true
criado: 2026-11-13
---
# Padrões de C#

O que eu costumo usar quando escrevo C#. Serve para a IA seguir quando eu peço para implementar algo.
Esta nota é o **índice**: o conteúdo está nas notas de `Padrões/CSharp/`.

## Como a IA deve usar
1. **O repositório vence.** Se o projeto já tem um padrão diferente (código existente, `.editorconfig`,
   `CLAUDE.md` do repo), siga o projeto. Estas notas valem para projeto novo ou quando o repo não diz nada ou se for pedido explicitamente para que as regras daqui sejam aplicadas.
2. **Só vale o item marcado** (`- [x]`). Item sem marca é sugestão que eu ainda não aprovei: pode citar, não aplicar.
3. Leia **só as notas da tarefa** (tabela abaixo), não todas.
4. Ao fugir de um item marcado, diga por quê.

## Qual nota ler
| Tarefa | Leia |
|---|---|
| Criar uma solution ou projeto novo | [[Projetos da solução]], [[Estrutura de pastas]], [[Bibliotecas]] |
| Criar ou mudar um endpoint / caso de uso | [[Projetos da solução]], [[Tratamento de erros]], [[Estilo de código]] |
| Adicionar um pacote NuGet | [[Bibliotecas]] |
| Escrever testes | [[Testes]] |
| Qualquer código C# | [[Estilo de código]] |

## Arquitetura
Não há nota de padrão de arquitetura, para não repetir o que já está explicado em `Conhecimentos/`.
As decisões de arquitetura que eu sigo são as dessas notas:
[[Arquitetura em camadas]], [[Modelo de domínio rico]], [[Gateway]], [[Unit of Work]] e [[Dual write]].

## Como me ajudar
- [ ] Em C#, me guie pelo **Visual Studio** (menu, clique, atalho), não por comando de terminal.
- [ ] Passos curtos: fluxo → o que fazer na IDE → código → uma ou duas linhas de porquê.

> Rascunho montado pelo Claude a partir do [[cet-medicao]] e do [[cash-flow]]. Marque o que concorda,
> apague ou mude o resto.
