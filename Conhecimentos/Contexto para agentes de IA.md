---
tipo: conceito
area: IA
projetos: [cet-medicao]
criado: 2026-11-13
---
# Contexto para agentes de IA

## O que é
O modelo não lembra de nada entre conversas e só "sabe" o que está na **janela de contexto** da sessão:
suas mensagens, os arquivos que ele leu, as saídas das ferramentas e os textos que o Claude Code injeta
sozinho. Trabalhar bem com um agente é, em boa parte, **decidir o que entra nessa janela**.

## Por que existe / que problema resolve
A janela é grande, mas finita, e tudo nela disputa atenção. Instrução demais, arquivo inteiro colado ou
regra repetida em três lugares deixam o agente **pior**, não melhor. Por isso o Claude Code separa o
contexto em camadas, cada uma carregada em um momento diferente:

| Camada | Quando entra | Serve para | Exemplo seu |
|---|---|---|---|
| `CLAUDE.md` | **sempre**, no início da sessão | regras estáveis do projeto | o `CLAUDE.md` deste vault |
| Memória automática | sempre (só o índice `MEMORY.md`) | fatos aprendidos com você entre sessões | "guiar pelo Visual Studio", "commits sem assinatura" |
| Skills | **só quando o assunto aparece** | procedimentos passo a passo | [[Skills do Claude Code]] |
| Ferramentas e [[MCP]] | quando o agente decide usar | buscar dado vivo (arquivos, git, browser, APIs) | ler o repo, rodar `git log` |

## Como aparece no código
- `CLAUDE.md` pode existir em três níveis: `~/.claude/CLAUDE.md` (seu, vale em tudo), na raiz do projeto
  (vai para o git, vale para o time) e em subpastas (carregado quando o agente trabalha ali).
- A memória automática fica em `~/.claude/projects/<projeto>/memory/`: um arquivo por fato e um `MEMORY.md`
  como índice. Só o índice entra sempre; o resto é lido quando parece relevante.
- No cet-medicao, quem garante que o Claude te guie pela IDE e não assine commits é a memória, não o repo:
  é preferência **sua**, não do time.

## Pontos de atenção
- **Onde colocar uma instrução nova?** Regra do projeto que o time todo deve seguir → `CLAUDE.md` do repo.
  Preferência sua → memória ou `~/.claude/CLAUDE.md`. Procedimento de vários passos que só às vezes é útil → skill.
- **`CLAUDE.md` curto.** Ele custa contexto em toda mensagem. Detalhe que só às vezes importa vai para uma skill
  ou para um arquivo que o `CLAUDE.md` só aponta.
- **Contexto envelhece.** Memória e notas registram o que *era* verdade. Ao montar estas notas, a memória dizia
  que o número da medição vinha da CET; o código já reservava o número no próprio banco. Confira no código
  antes de confiar.
- **Sessão longa perde detalhe**: quando a conversa cresce, o começo é resumido. Tarefa nova → sessão nova.

## Com minhas palavras


## Relacionados
- [[Skills do Claude Code]]
- [[MCP]]
