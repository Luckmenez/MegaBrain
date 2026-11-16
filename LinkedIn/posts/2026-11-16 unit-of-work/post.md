---
tipo: post-linkedin
tema: Unit of Work
status: rascunho
publicado_em:
---
# Unit of Work no supermercado

Conceito: [[Unit of Work]] · projeto de estudo: [[cash-flow]] · registro: [[Posts do LinkedIn]]

## Conceito
O carrinho de supermercado é o `DbContext`: anota tudo e espera. O caixa é o `Commit()`, que grava
tudo de uma vez. Layout em 2 faixas (sem × com Unit of Work) e uma faixa de código.
Movimento: sem UoW, cada produto vai sozinho ao banco e o 3º falha (dados pela metade); com UoW,
tudo vai no carrinho, passa no caixa e chega ao banco numa ida só.

## Roteiro
- **Título:** Unit of Work · *explicado com um carrinho de supermercado*
- **Sem Unit of Work:** "cada item vai sozinho ao caixa". Anotação: "cada Add() já vai direto pro
  banco". Na falha: "o 3º falhou, mas 2 já foram gravados → dados pela metade".
- **Com Unit of Work:** "tudo no carrinho, um caixa só". Anotações: "o carrinho é o DbContext:
  anota tudo e espera", "Commit() grava tudo de uma vez só", "falhou? nada é gravado", "1 ida só ✓".
- **No código:** `await _repository.Add(despesa);` (só põe no carrinho) e
  `await _unitOfWork.Commit();` (passa no caixa). Nomes reais do cash-flow.
- **Ciclo:** 8 s. O MP4 tem 3 ciclos (24 s).

## Texto do post (escrito pelo Lucas)

## Revisão
