---
name: criar-post-linkedin
description: Cria o material de apoio visual de um post do LinkedIn do Lucas (infográfico animado no estilo desenhado à mão, gravado em MP4 e GIF) e revisa o texto que ele escreve. Use quando ele disser "quero postar sobre X", "cria uma arte para o LinkedIn", "material de apoio", "infográfico animado", "post do LinkedIn", "revisa meu post" ou trouxer um tema para publicar.
---

# Criar post do LinkedIn

O fluxo é: **ele pensa no tema → a gente cria o material de apoio → ele escreve o texto, e eu reviso.**
O post é dele. O material precisa parecer feito à mão e com cuidado, não gerado.

O fluxo tem quatro paradas. Não pule para a próxima sem ele confirmar.

## 0. Antes de propor

- Leia `LinkedIn/Posts do LinkedIn.md` no vault (`~/.claude/megabrain`): o registro do que já foi feito
  (metáfora, layout, cor de destaque). **Não repita** metáfora nem layout dos últimos posts.
- Se o tema veio do estudo dele (ex.: cash-flow), olhe o código e use os nomes reais
  (`_unitOfWork.Commit()`, não um nome inventado).
- **Nada do trabalho (CET) vai para o post**: sem nome de cliente, de sistema, de tela ou regra de
  negócio de lá. Conceito genérico, sim; o caso do trabalho, não.

## 1. Três conceitos (parada 1)

Proponha **3 conceitos bem diferentes entre si**, cada um com:
- **Metáfora visual**: um objeto do dia a dia que *explica* o conceito (Unit of Work = carrinho de
  supermercado que passa no caixa uma vez só). Nada de fluxograma com ícones genéricos.
- **Layout**: faixas comparativas (sem × com), lista de casos (4 a 5 faixas), diagonal
  antes/depois, linha do tempo, um objeto grande com anotações em volta, mapa...
- **O que se move** e o "momento" da animação (o erro acontecendo, a fila andando, o clique).

Diga qual você recomenda e por quê. Se ele trouxer a própria ideia, ela vence: refine, não troque.
**Pare aqui.**

## 2. Roteiro (parada 2)

Antes de desenhar, em texto: título, subtítulo, o que vai em cada faixa (rótulo + desenho), as
anotações à mão (frases curtas, uma ideia cada) e a cena da animação segundo a segundo (ciclo de
6 a 10 s). Confira a explicação técnica: o material ensina, então errar o conceito é o pior defeito.
**Pare aqui.**

## 3. Arte animada (parada 3)

1. Crie `LinkedIn/posts/AAAA-MM-DD tema/arte.html` a partir de
   `Skills/criar-post-linkedin/ferramentas/modelo.html`. O exemplo aprovado é
   `LinkedIn/posts/2026-11-16 unit-of-work/arte.html`: use como **referência de acabamento**,
   não como molde para copiar.
2. Desenhe em SVG. Para conferir, tire fotos de 3 ou 4 instantes do ciclo e **olhe as fotos**
   (texto sobreposto, objeto desbotado, seta em cima de palavra, algo saindo da página):
   ```
   node ~/.claude/megabrain/Skills/criar-post-linkedin/ferramentas/foto.mjs "<pasta do post>/arte.html" 1000 3500 6500
   ```
3. Corrija e só então grave (demora ~1 min):
   ```
   node ~/.claude/megabrain/Skills/criar-post-linkedin/ferramentas/gravar.mjs "<pasta do post>/arte.html"
   ```
   Sai `arte.mp4` (3 ciclos, para o feed) e `arte.gif` (leve). Mande os dois para ele ver
   (SendUserFile). **Pare aqui** e ajuste o que ele pedir.

Se `node_modules` não existir na pasta `ferramentas`, rode `npm install` nela (o `instalar.ps1`
já faz isso).

## 4. Texto do post e registro

- **Ele escreve o texto.** Eu reviso: gancho da primeira linha, clareza, tamanho, erro técnico,
  português. Sugestões pontuais, mostrando o trecho e a troca, **sem reescrever com a minha voz**.
  Só escreva um rascunho inteiro se ele pedir.
- Crie `post.md` na pasta do post (molde abaixo) e adicione uma linha em `Posts do LinkedIn.md`.
- Quando ele postar, ele avisa a data e a gente marca como publicado.

```markdown
---
tipo: post-linkedin
tema: Unit of Work
status: rascunho | pronto | publicado
publicado_em:
---
# Unit of Work no supermercado

## Conceito
Metáfora, layout e o que se move, em 2 ou 3 linhas.

## Roteiro
Título, faixas e anotações, como foi aprovado.

## Texto do post (escrito pelo Lucas)

## Revisão
O que eu sugeri e o que ele aceitou.
```

## Regras

**Autoria e marca**
- Nenhuma marca de IA: nada de "feito com IA", assinatura, marca d'água ou hashtag sobre isso.
- Pegamos a **linguagem visual** das referências, nunca a marca de ninguém: sem logo, mascote,
  rodapé, nome ou frase de outro perfil. O rodapé é o dele (`Lucas Menezes` + tags do tema).

**Para não ter cara de gerado**
- Papel com granulado, traço levemente tremido (filtro `rough`), letra de mão nas anotações,
  setas vermelhas curvas, pontilhados.
- Um ponto focal e uma metáfora, não 15 ícones. Assimetria e respiro são bem-vindos.
- Evite: brilho neon, gradiente roxo-azul, ícone de engrenagem/cérebro/foguete, tudo centralizado e
  simétrico, título com emoji.

**Criatividade**
- Sempre 3 conceitos e sempre uma metáfora diferente das já registradas.
- Varie também o layout e a cor de destaque entre posts seguidos. A base (papel, tinta azul-escura,
  vermelho das anotações) é a identidade e fica.

**Legibilidade**: no celular a arte aparece com ~1/3 do tamanho. Texto com no mínimo 22 px no
1080×1350, frases curtas, contraste forte.

**Canva**: se ele pedir pelo Canva, use o conector (cria, edita e exporta, mas **não anima**).
Se algo não der pelo Canva, pare e pergunte antes de ir para o HTML.

**Técnico** (detalhes nos comentários de `modelo.html`):
- Todo movimento em keyframes CSS, com o ciclo igual a `window.loopMs`, para o vídeo repetir sem emenda.
- Objeto que se move: desenhado com centro em (0,0) e movido com `translate`. Repita `opacity: 1`
  nos quadros-chave intermediários, senão ele desbota no caminho.
- Fontes do Google Fonts (`Bowlby One` no título, `Architects Daughter` na mão, `JetBrains Mono` no código).

**Git**: `arte.html` e `post.md` vão para o vault. `mp4`, `gif` e as fotos `png` ficam fora do git
(são gerados de novo com o `gravar.mjs`).
