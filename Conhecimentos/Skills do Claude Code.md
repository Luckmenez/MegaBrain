---
tipo: conceito
area: IA
projetos: []
criado: 2026-11-13
---
# Skills do Claude Code

## O que é
Uma skill é uma **pasta com um `SKILL.md`**: um passo a passo que o Claude segue quando aparece uma tarefa
daquele tipo. Pode ter arquivos de apoio junto (scripts, modelos, referências).

```markdown
---
name: revisar-conceito
description: Revisão ativa de um conceito do vault... Use quando ele disser "me testa", "quiz"...
---
# Revisar conceito
1. Achar a nota...
2. Perguntar, uma pergunta por vez...
```

## Por que existe / que problema resolve
Sem skill, você reexplica o mesmo procedimento em toda conversa, ou enfia tudo no `CLAUDE.md` e paga esse
contexto em toda mensagem, mesmo quando não precisa.

A skill resolve com **carregamento sob demanda** (*progressive disclosure*):
1. No início da sessão, o Claude vê só o `name` e a `description` de cada skill: poucas linhas.
2. Quando a tarefa bate com a descrição (ou você digita `/nome-da-skill`), ele lê o `SKILL.md` inteiro.
3. Arquivos de apoio só são abertos se o `SKILL.md` mandar.

Ver [[Contexto para agentes de IA]].

## Como aparece no código
As suas ficam neste vault, em `Skills/`, e são ligadas em `~/.claude/skills/` pelo script de instalação:
ver [[Como usar as skills]].

| Onde | Vale para |
|---|---|
| `~/.claude/skills/` | você, em qualquer projeto |
| `.claude/skills/` dentro de um repo | todo o time que clona o repo |

## Pontos de atenção
- **A `description` é o gatilho.** Ela decide se a skill é usada. Diga *o que faz* e *as frases que você usaria*
  ("registra no cérebro", "me testa"). Descrição vaga = skill que nunca dispara, ou que dispara na hora errada.
- **Um trabalho por skill.** Se a skill tem "e também..." no meio, provavelmente são duas.
- **Escreva o porquê dos passos**, não só a ordem: o modelo segue melhor uma regra cujo motivo ele entende.
- Skill é texto que o agente **segue**: só instale skill de fonte em que você confia, como faria com um script.

## Com minhas palavras


## Relacionados
- [[Contexto para agentes de IA]]
- [[MCP]]
