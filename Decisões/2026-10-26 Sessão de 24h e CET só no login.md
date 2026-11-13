---
tipo: decisao
projeto: cet-medicao
data: 2026-10-26
status: aceita
---
# Sessão de 24h e CET só no login

## Contexto
No [[cet-medicao]], quem diz se o usuário existe e quais papéis tem (Fiscal, Gestor...) é a CET, um
sistema externo ([[Gateway]]). A API emite os próprios tokens. Era preciso decidir quanto tempo
uma sessão dura e quando consultar a CET de novo. Commit `e2b2521`.

## Opções consideradas
1. Consultar a CET a **cada renovação** do token: dados sempre frescos, mas uma chamada externa a cada 15 min
   por usuário, e a sessão cai se a CET estiver fora do ar.
2. Consultar a CET **só no login** e guardar id, nome e papéis junto do token de renovação.
3. Sessão que **estica** a cada renovação (nunca vence enquanto o usuário usa).

## Decisão e porquê
**Opção 2, com sessão fixa de 24h.**

| Token | Validade | Onde fica |
|---|---|---|
| Access token (JWT) | 15 min | no front, cabeçalho `Authorization: Bearer` |
| Token de renovação | 24h a partir do login | no front; no banco só o **hash SHA-256** |

- Cada renovação **revoga** o token usado e entrega outro, mas com o **mesmo vencimento** do login (rotação).
- Depois de 24h, o `/renovar` responde 401 e o usuário passa pela CET de novo.
- No banco fica só o hash: se o banco vazar, os tokens não servem para nada.

## Consequências
- Aceito: um usuário desligado na CET continua com acesso até o fim da sessão (no máximo 24h).
- `/sair` revoga o token de renovação na hora, mas o access token vale até vencer (no máximo 15 min).
  É o preço do JWT: ele é conferido pela assinatura, sem ir ao banco.
- A rotação abriu um problema de concorrência ainda pendente: ver [[Dual write#No cet-medicao: ainda aberto]].
