# MegaBrain: regras do vault

Este é o "segundo cérebro" do Lucas: notas em Markdown editadas no Obsidian.
Ele está aprendendo .NET / EF Core. Explique de forma simples e sempre o **porquê**.

## Onde cada coisa fica

| Pasta | O que vai lá | Nome do arquivo |
|---|---|---|
| `00-Inbox/` | Rascunho rápido, ainda sem lugar. Esvaziar toda semana. | livre |
| `Projetos/` | Uma nota por projeto (contexto, stack, links). | `nome-do-repo.md` |
| `Conhecimentos/` | Um conceito por nota (Unit of Work, DbContext...). | Nome do conceito, ex. `Unit of Work.md` |
| `Decisões/` | Por que escolhi X e não Y. | `AAAA-MM-DD Título curto.md` |
| `Diario/` | Uma nota por dia, o que fiz e aprendi. | `AAAA-MM-DD.md` |
| `Templates/` | Modelos das notas acima. Não guardar conteúdo aqui. | — |

## Regras

1. **Nenhuma nota órfã**: toda nota nova precisa de um link vindo do [[Home]]
   ou de uma nota de projeto. Ao criar uma nota, adicione o link no índice certo.
2. Use o template da pasta (em `Templates/`) e preencha o frontmatter.
3. Links com `[[Nome da nota]]`. Link para nota que ainda não existe é permitido:
   marca algo a escrever depois.
4. Ao citar código, use o caminho do repo (`src/...`) e o hash do commit, não cole arquivos inteiros.
5. A seção **"Com minhas palavras"** é do Lucas: nunca escreva nela, só deixe o espaço.
6. Não apague nem renomeie notas sem perguntar.
