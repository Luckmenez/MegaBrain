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

## Instalar numa máquina nova

1. Clone o vault e abra no Obsidian.
2. Na pasta do vault, rode o script do seu sistema:
   - Windows: `powershell -ExecutionPolicy Bypass -File Skills\instalar.ps1`
   - Mac/Linux: `sh Skills/instalar.sh`
3. Abra uma sessão nova do Claude Code: as skills aparecem na lista.

O script cria um **atalho** (junction no Windows, link simbólico no Mac/Linux) de cada pasta daqui
para `~/.claude/skills/`. Por isso, editar o `SKILL.md` no Obsidian já muda a skill, sem reinstalar.

Opcional: defina a variável de ambiente `MEGABRAIN` com o caminho do vault. Sem ela, as skills acham o
vault pelo registro do Obsidian (`obsidian.json`).

## Criar uma skill nova

1. Crie `Skills/nome-da-skill/SKILL.md` com o frontmatter `name` e `description`.
   A `description` é o que o Claude lê para decidir **quando** usar a skill: diga o que ela faz e
   que frases do dia a dia devem acioná-la.
2. Rode o script de instalação de novo.
3. Adicione a skill na tabela acima.
