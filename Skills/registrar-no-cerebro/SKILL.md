---
name: registrar-no-cerebro
description: Transforma o que o Lucas aprendeu ou decidiu nesta sessão em notas do vault MegaBrain (Obsidian), seguindo as regras do vault. Use quando ele disser "registra no cérebro", "salva isso no MegaBrain", "anota isso no vault", "vira nota" ou pedir para guardar um conceito, uma decisão ou o resumo do dia.
---

# Registrar no cérebro

Leva o que aconteceu nesta conversa para o vault MegaBrain, sem encher o vault de coisa que ele não vai reler.

## 1. Achar o vault

1. Se a variável de ambiente `MEGABRAIN` existir, é o caminho do vault.
2. Senão, leia o `obsidian.json` do Obsidian e pegue o vault cujo `path` termina em `MegaBrain`:
   - Windows: `%APPDATA%\obsidian\obsidian.json`
   - Mac: `~/Library/Application Support/obsidian/obsidian.json`
   - Linux: `~/.config/obsidian/obsidian.json`
3. Se nada disso funcionar, pergunte o caminho ao Lucas.

Depois **leia o `CLAUDE.md` da raiz do vault**: ele manda nas pastas, nos nomes e nas regras. Se algo aqui
contradisser o `CLAUDE.md`, vale o `CLAUDE.md`.

## 2. Escolher o que vira nota

Olhe a conversa e separe candidatos em três tipos:

| Tipo | Vira nota quando... | Pasta / template |
|---|---|---|
| Conceito | ele aprendeu algo que vai reaparecer (um padrão, um recurso do C#, uma ideia de arquitetura ou de IA) | `Conhecimentos/` + `Templates/Conceito.md` |
| Decisão | houve uma escolha entre opções, com motivo | `Decisões/` + `Templates/Decisao.md` |
| Diário | ele pediu o resumo do dia | `Diario/AAAA-MM-DD.md` + `Templates/Diario.md` |

Antes de criar, procure no vault uma nota que já cubra o assunto (busque pelo nome e por sinônimos).
Se existir, **complemente a nota existente** em vez de criar outra.

Mostre ao Lucas a lista curta do que pretende registrar (uma linha por nota, dizendo se é nova ou
complemento) e espere ele confirmar. Pouco e bom: 1 a 3 notas por sessão é o normal.

## 3. Escrever

- Preencha o frontmatter do template. `area` é um de: `Arquitetura`, `C#`, `.NET / EF Core`, `IA`.
- Escreva simples, sempre com o **porquê**.
- Em "Como aparece no código": caminho do arquivo no repo + hash curto do commit
  (`git log --oneline -S "trecho"` ajuda a achar). Trecho curto, nunca o arquivo inteiro.
- **Nunca escreva na seção "Com minhas palavras".** Deixe-a vazia; ela é do Lucas.
- Links com `[[Nome da nota]]`. Pode linkar nota que ainda não existe.
- Nada de caminho absoluto de máquina: use `~` e a URL do repo.
- Projeto de trabalho: nada de senha, chave, connection string, dado de cliente ou nome de colega.

## 4. Ligar ao resto (nenhuma nota órfã)

- Conceito novo: link no `Home.md`, na seção da `area`, e em "Conceitos usados aqui" da nota do projeto.
- Decisão nova: link na seção "Decisões" do `Home.md` e da nota do projeto.
- Nota de projeto nova: link na seção "Projetos" do `Home.md`.

## 5. Fechar

Diga em poucas linhas o que criou ou mudou, com o caminho de cada nota, e lembre que a seção
"Com minhas palavras" está esperando por ele. Não faça commit no vault, a menos que ele peça.
