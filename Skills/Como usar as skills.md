---
tipo: indice
---
# Como usar as skills

As skills do Claude Code moram **aqui no vault**, versionadas no git, e são ligadas em `~/.claude/skills/`.
Assim elas funcionam em qualquer projeto e em qualquer máquina onde o vault estiver clonado.
O que é uma skill: ver [[Skills do Claude Code]].

## Skills

| Skill | Para quê | Como chamar |
|---|---|---|
| [[Skills/registrar-no-cerebro/SKILL\|registrar-no-cerebro]] | Transformar o que aprendi numa sessão em nota aqui | `/registrar-no-cerebro` ou "registra isso no cérebro" |
| [[Skills/revisar-conceito/SKILL\|revisar-conceito]] | O Claude me faz perguntas sobre um conceito e corrige | `/revisar-conceito Unit of Work` ou "me testa em DI" |
| [[Skills/quebrar-historia-jira/SKILL\|quebrar-historia-jira]] | Quebrar uma história do Jira em tarefas de PR pequena, conferir a cobertura e escrever as descrições | `/quebrar-historia-jira` e colar a história e as tarefas (texto ou print) |
| [[Skills/the-judge/SKILL\|the-judge]] | Revisar uma PR com evidência e mostrar no chat tudo o que ela acusa, com `arquivo:linha`. Só posta no GitHub se eu pedir (precisa do `gh` logado e do Python) | `/the-judge` ou "revise esse PR em português" |

> [!note] the-judge é de terceiros
> Copiada de `tech-leads-club/agent-skills` (autor Felipe Rodrigues, licença CC-BY-4.0), versão 1.4.0,
> fixada no commit `e74dc8a7e8d59bb36f267afd089580e0858e224a` depois de lida por inteiro.
> Não atualize puxando a versão mais nova sem ler o que mudou: ela roda scripts e posta no GitHub.
>
> **Mudança minha:** o Passo 7 original postava a review direto no GitHub. Aqui ele mostra tudo no chat
> e só posta se eu pedir ("posta no GitHub"). A `description` também foi ajustada. Se atualizar a skill, refaça essa mudança.

## Instalar numa máquina nova

1. Clone o vault e abra no Obsidian.
2. Na pasta do vault, rode o script do seu sistema:
   - Windows: `powershell -ExecutionPolicy Bypass -File Skills\instalar.ps1`
   - Mac/Linux: `sh Skills/instalar.sh`
3. Abra uma sessão nova do Claude Code: as skills aparecem na lista.

O script cria **atalhos** (junction no Windows, link simbólico no Mac/Linux):

| Atalho | Aponta para | Para quê |
|---|---|---|
| `~/.claude/skills/<skill>` | cada pasta de skill daqui | o Claude achar as skills. Editar o `SKILL.md` no Obsidian já muda a skill, sem reinstalar |
| `~/.claude/megabrain` | a raiz deste vault | um **endereço fixo** para o vault, igual em todas as máquinas, não importa onde o vault foi clonado |

O `CLAUDE.md` de um projeto importa a nota dele assim, e funciona em qualquer computador:

```markdown
@~/.claude/megabrain/Projetos/cash-flow.md
```

Se mudar o vault de pasta numa máquina, apague o atalho `~/.claude/megabrain` e rode o script de novo.

## Criar uma skill nova

1. Crie `Skills/nome-da-skill/SKILL.md` com o frontmatter `name` e `description`.
   A `description` é o que o Claude lê para decidir **quando** usar a skill: diga o que ela faz e
   que frases do dia a dia devem acioná-la.
2. Rode o script de instalação de novo.
3. Adicione a skill na tabela acima.
