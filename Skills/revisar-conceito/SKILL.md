---
name: revisar-conceito
description: Revisão ativa de um conceito do vault MegaBrain - o Claude faz perguntas, o Lucas responde com as próprias palavras e recebe correção. Use quando ele disser "me testa", "revisa comigo", "quero revisar <conceito>", "quiz" ou quiser preencher a seção "Com minhas palavras" de uma nota.
---

# Revisar conceito

Ler a nota de novo dá a sensação de que se sabe. Tentar lembrar sem olhar é o que fixa.
Esta skill faz o Lucas **explicar**, e só depois mostra o que faltou.

## 1. Achar o vault e a nota

Ache o vault como em `registrar-no-cerebro` (variável `MEGABRAIN`, senão o vault `MegaBrain` no
`obsidian.json` do Obsidian). Leia o `CLAUDE.md` do vault.

- Se ele disse o conceito, abra a nota em `Conhecimentos/`.
- Se não disse, liste as notas de `Conhecimentos/` cuja seção "Com minhas palavras" está vazia e
  sugira até 3 para ele escolher.

## 2. Perguntar (uma pergunta por vez)

Faça de 3 a 5 perguntas, **uma por mensagem**, esperando a resposta antes da próxima:

1. **O que é**, em uma frase.
2. **Que problema resolve**: o que dá errado sem isso?
3. **Onde aparece no código** de um projeto dele (as notas de `Projetos/` dizem quais).
4. **Um caso limite ou erro comum** tirado de "Pontos de atenção".
5. (Opcional) **Comparação**: em que difere de um conceito vizinho linkado em "Relacionados".

Não dê a resposta junto com a pergunta. Se ele travar, dê uma dica pequena, não a resposta.

## 3. Corrigir

Depois de cada resposta, diga em uma ou duas linhas: o que está certo, o que faltou e o porquê.
Seja direto: se está errado, diga que está errado.

## 4. Fechar

- Resuma em 3 tópicos o que ele domina e o que vale rever.
- Se ele quiser, sugira que escreva a seção "Com minhas palavras" a partir das próprias respostas.
  **Quem escreve é ele.** Você pode, no máximo, devolver as frases dele organizadas para ele colar,
  sem acrescentar ideias que ele não disse.
- Se a revisão mostrou um erro ou lacuna na própria nota, proponha a correção (fora da seção dele)
  e só altere depois que ele concordar.
