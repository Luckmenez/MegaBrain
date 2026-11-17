---
tipo: post-linkedin
tema: Unit of Work
status: publicado
publicado_em: 2026-11-16
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
  `await _unitOfWork.Commit();` (passa no caixa). Nomes genéricos o bastante; a arte não cita o cash-flow.
- **Ciclo:** 8 s. O MP4 tem 3 ciclos (24 s).

## Texto do post (escrito pelo Lucas)
Publicado em 2026-11-16, com o vídeo `arte.mp4`.

> Você já entrou em uma aplicação e deu de cara com um monte de repositórios que salvam no banco a cada alteração? Já parou para pensar que isso pode ser um problema para a sua aplicação?
>
> O grande problema dessa abordagem é que os commits dessas alterações passam a ser enviados para o banco isoladamente. Pense que você tenha uma tabela de User e outra de Address. Se a regra é "todo usuário precisa ter um endereço", e der erro depois de salvar o User e antes de salvar o Address, o que garante que você não terá um usuário sem endereço?
>
> Quem estudou um pouco de ACID já deve ter percebido que o conceito de atomicidade se perde nessa abordagem.
>
> Para resolver isso, existe o padrão Unit of Work: você tira o commit de dentro dos repositórios e deixa um único método responsável por ele. Os repositórios só preparam as alterações, e quando precisar salvar o usuário e o endereço, um commit só grava os dois. Se der erro, nada é salvo. Se não der, você garante que nenhum usuário fica sem endereço.
>
> Na animação: o carrinho é o DbContext, que anota tudo, e o caixa é o Commit, que grava de uma vez.
>
> E você, já deu de cara com algum repositório que foi escrito dessa maneira?
>
> #dotnet #csharp #entityframework #arquiteturadesoftware

## Revisão
O texto é do Lucas, com tom humano; a revisão foi pontual e ele aceitou tudo:
- **Gancho:** "repositórios que commita as alterações... a cada alteração" virou "repositórios que salvam no banco a cada alteração" (concordância e repetição).
- **Português:** "alteração" → "alterações", "alterções" → "alterações", "Para quem estudou... já deve" → "Quem estudou... já deve", "eventualmente" removido (em português é "de vez em quando").
- **Clareza:** o exemplo passou a dizer onde o erro acontece ("depois de salvar o User e antes de salvar o Address").
- **Solução:** a frase única virou três e ganhou o nome do padrão (Unit of Work), que é o que a pessoa vai pesquisar.
- **Acréscimos opcionais aceitos:** a frase ligando o texto à animação e 4 hashtags.
- **Parte técnica:** correta; a ligação com a atomicidade do ACID foi o ponto forte.
