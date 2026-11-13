# MegaBrain: regras do vault

Este é o "segundo cérebro" do Lucas: notas em Markdown editadas no Obsidian.
Ele está aprendendo .NET / C#, arquitetura de software e como trabalhar com IA.
Explique de forma simples e sempre o **porquê**.

## Onde cada coisa fica

| Pasta | O que vai lá | Nome do arquivo |
|---|---|---|
| `00-Inbox/` | Rascunho rápido, ainda sem lugar. Esvaziar toda semana. | livre |
| `Projetos/` | Uma nota por projeto (contexto, stack, links). | `nome-do-repo.md` |
| `Conhecimentos/` | Um conceito por nota (Unit of Work, DbContext...). | Nome do conceito, ex. `Unit of Work.md` |
| `Decisões/` | Por que escolhi X e não Y. | `AAAA-MM-DD Título curto.md` |
| `Diario/` | Uma nota por dia, o que fiz e aprendi. | `AAAA-MM-DD.md` |
| `Skills/` | Skills do Claude Code, uma pasta por skill (`Skills/nome/SKILL.md`). | `nome-em-kebab-case/` |
| `Templates/` | Modelos das notas acima. Não guardar conteúdo aqui. | — |

### Áreas dos conceitos
O campo `area` do frontmatter usa um destes valores, que são também as seções do [[Home]]:
`Arquitetura`, `C#`, `.NET / EF Core`, `IA`.

## Regras

1. **Nenhuma nota órfã**: toda nota nova precisa de um link vindo do [[Home]]
   ou de uma nota de projeto. Ao criar uma nota, adicione o link no índice certo.
2. Use o template da pasta (em `Templates/`) e preencha o frontmatter.
3. Links com `[[Nome da nota]]`. Link para nota que ainda não existe é permitido:
   marca algo a escrever depois.
4. Ao citar código, use o caminho do repo (`src/...`) e o hash do commit, não cole arquivos inteiros.
   Trechos curtos (até ~15 linhas) que mostram o conceito são bem-vindos.
5. A seção **"Com minhas palavras"** é do Lucas: nunca escreva nela, só deixe o espaço.
6. Não apague nem renomeie notas sem perguntar.
7. **Pouco e bom**: só vira nota o que o Lucas quer aprender ou vai precisar lembrar.
   Na dúvida, deixe um link para nota ainda não escrita em vez de criar a nota.
8. **Projetos de trabalho:** este vault vai para o GitHub. Nada de senha, chave, connection string,
   dado de cliente ou nome de colega. Registre o conceito e a decisão, não o segredo.

## Caminhos (valem em qualquer máquina)

Nunca escreva caminho absoluto de uma máquina (`C:\Users\fulano\...`). Use:

| O quê | Como escrever |
|---|---|
| Pasta pessoal | `~` (no Windows é `%USERPROFILE%`, no Mac/Linux é `$HOME`) |
| Repositório de um projeto | frontmatter `repo:` com a URL do GitHub e `pasta:` com o caminho a partir de `~`, ex. `~/dev/cash-flow` |
| Skills globais do Claude | `~/.claude/skills/` |
| Este vault | variável de ambiente `MEGABRAIN`; se não existir, o vault chamado `MegaBrain` no registro do Obsidian (ver abaixo) |

**Achar o vault sem saber o caminho:** o Obsidian guarda a lista de vaults em `obsidian.json`:
- Windows: `%APPDATA%\obsidian\obsidian.json`
- Mac: `~/Library/Application Support/obsidian/obsidian.json`
- Linux: `~/.config/obsidian/obsidian.json`

Procure ali o vault cujo `path` termina em `MegaBrain`.

**Achar o repositório de um projeto:** use a `pasta:` da nota. Se ela não existir nesta máquina,
procure em `~/dev` um clone cujo `git remote -v` bata com o `repo:`.
