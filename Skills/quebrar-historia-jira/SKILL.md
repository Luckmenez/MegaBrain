---
name: quebrar-historia-jira
description: Quebra uma história do Jira em tarefas pequenas, uma PR pequena cada (poucos arquivos para revisar), confere se as tarefas cobrem a história inteira e depois escreve as descrições prontas para colar no Jira. Use quando o Lucas mandar uma história (texto ou print) e/ou as tarefas que ele criou, ou disser "quebra essa história", "cria as tasks", "revisa as tarefas do Jira", "escreve as descrições das tarefas" ou "isso cobre a história?".
---

# Quebrar história do Jira em tarefas

O objetivo é **PR pequena**: cada tarefa vira uma PR que se revisa de uma vez, sem chegar perto de 30
arquivos alterados. Mais tarefas pequenas é melhor do que poucas grandes.

> **Nunca sugira juntar tarefas para ter menos tarefas.** "Quebrar bem" quer dizer tarefas *menores*, não
> *menos* tarefas. Juntar só se uma delas não compila nem funciona sozinha.

O fluxo tem três paradas. Não pule para a próxima sem o Lucas confirmar.

## 0. Juntar o que precisa (sem questionário)

Ele manda a história (descrição, regras, critérios de aceite, às vezes protótipo) e, se já existirem, as
tarefas criadas (número + título). Pode vir em texto ou print.

- **Não abra com uma lista de perguntas.** Trabalhe com o que veio. Dúvida que bloqueia vai no fim da
  resposta, no máximo 3, e o resto vira premissa escrita ("considerei que...").
- **Olhe o código do repositório** da sessão antes de propor: o que já existe (endpoint, tela, tabela,
  janela de assinatura) muda a tarefa de "criar" para "ajustar". Se houver `docs/` com a especificação,
  leia a parte da história.
- Se o projeto tem nota em `Projetos/` no vault MegaBrain (ache o vault pela variável `MEGABRAIN` ou pelo
  `obsidian.json`, como em `registrar-no-cerebro`), leia: ela diz as camadas e o fluxo do contrato.

## 1. Revisar a cobertura e a quebra (parada 1)

Responda nesta ordem:

**Cobertura.** Cada regra de negócio e cada critério de aceite tem pelo menos uma tarefa? Mostre só o que
**falta** ou está **coberto pela metade**, citando a regra ("regra 2", "critério 4"). Os buracos de sempre:
- validação no **backend** do que a tela já bloqueia (perfil, dono do recurso, situação, valor);
- **quem pode**: ter o perfil é diferente de ser o dono daquele contrato/registro;
- mensagens de erro da história que nenhuma tarefa de front mostra;
- estados da tela: carregando (botão desabilitado contra clique duplo), erro, vazio, sessão expirada;
- registro de histórico/auditoria, com texto diferente para primeiro envio e reenvio;
- integração com sistema externo (consultar e/ou enviar) e o que fazer quando ele cai;
- tudo o que o protótipo mostra e a história não exclui explicitamente.

**Frentes.** Diga quais das quatro frentes a história tem (ver "Regras do time"). Para cada frente sem
tarefa, olhe se a história pede algo de verdade nela e o time não viu:
- **Banco de dados:** coluna nova, situação nova, índice para a consulta nova, tabela de histórico,
  semente de dados.
- **Frontend:** mensagem, estado ou exibição que a história pede na tela.
- **Backend:** validação que só a tela faz, endpoint que a tela vai precisar.

Se achar, proponha a tarefa citando a regra que pede. Se não achar, diga "sem tarefa de Banco de dados:
a história não muda nada no banco". A frente Testes falta só por esquecimento: sempre proponha.

**Quebra.** Para cada tarefa grande demais, diga como dividir. Sinais de que está grande:
- o título tem "e" (duas ações);
- mexe em mais de uma frente (back e front juntos);
- tem mais de ~5 critérios de aceite;
- a estimativa passa de ~15 arquivos (ver "Estimar o tamanho");
- mistura **conferir se pode** (validações) com **gravar** (persistência).

**Ajustes.** Títulos que contradizem a história (ex.: "aprovar" quando a história diz que encaminhar não
é aprovar), "criar" o que já existe, front que "persiste", sobreposição entre duas tarefas.

**Lista final** numa tabela, já na ordem de execução:

| # | Tarefa | Arquivos (estim.) | Depende de |
|---|---|---|---|
| 181 | [Banco de dados] - Criar a estrutura da assinatura do Gestor | ~4 | — |
| nova | [Backend] - Validar o encaminhamento da medição | ~6 | 181 |

Marque as novas como `nova` e as que mudaram como `181 (ajustar título)`. Abaixo da tabela, uma linha
com as frentes: `Frentes: Backend ✓ · Frontend ✓ · Banco de dados ✓ · Testes ✓`.

**Ordem.** Banco → back → front de integração; o front de layout com dados fixos anda em paralelo desde o
início. Testes por último. Diga o que pode andar em paralelo.

Termine perguntando se fecha a lista. **Pare aqui.**

## 2. Escrever as descrições (parada 2)

Só depois de ele fechar a lista. Uma por tarefa, na ordem de execução, todas no mesmo formato, prontas
para colar:

```markdown
### MDC-174 · [Backend] - Gravar a assinatura do Gestor e mudar a situação

**Descrição**
Uma ou duas frases: o que a tarefa entrega e onde (endpoint, tela, tabela). Se algo parecido já existe,
diga para reaproveitar.

**Critérios de aceite**
- Comportamento observável, um por linha, com o código HTTP ou o texto exato da mensagem da história.
- Caso de erro: "retorna 422 e não grava nada".
- Testes de unidade desta tarefa entram nesta PR.

**Fora do escopo**
- O que parece fazer parte mas é de outra tarefa (com o número dela).

**Depende de:** MDC-181 e a tarefa de validação.
```

- Título: `[Frente] - Verbo no infinitivo + o quê`. Frentes: `[Backend]`, `[Frontend]`, `[Banco de dados]`,
  `[Testes]`.
- **Fora do escopo** é o que segura a PR pequena: sem ele, quem pega a tarefa "aproveita" e vai somando.
- Códigos HTTP e nomes de exceção: use os do projeto (olhe o tratador de exceções). Se não achou, diga
  que é sugestão.
- Tarefa condicional ("só se o encaminhamento precisar chamar o GC") vai marcada como tal, com a pergunta
  que decide.
- No fim, lembre de registrar as dependências com o link **"é bloqueada por"** do Jira.

## 3. Conferir o que foi criado (parada 3)

Se ele mandar o print do Jira depois de criar: confira títulos com texto colado a mais ("...Critérios"),
prefixo sem ` - `, tipo errado do item, tarefa fora da história, e se as condicionais foram decididas.

## Regras do time

- **O ponto ótimo é a história ter as quatro frentes**: pelo menos uma tarefa de `[Backend]`, uma de
  `[Frontend]`, uma de `[Banco de dados]` e uma de `[Testes]`.
  *Por quê:* o esforço da história conta **uma vez por frente presente**, não por tarefa. 20 tarefas de
  Backend contam como 1 Backend; uma frente sem nenhuma tarefa conta 0.
  - **Testes é obrigatória** em toda história.
  - Backend, Frontend e Banco de dados: tenha uma de cada **quando fizer sentido**. Se a história não tem
    nada de verdade numa frente, tudo bem ficar sem. **Nunca invente trabalho** para preencher a frente.
  - Por isso quebrar uma frente em várias tarefas é de graça: deixa as PRs menores sem mudar a conta.
- **Uma tarefa de `[Testes]` por história**, cobrindo backend e frontend juntos (fluxo de ponta a ponta e
  integração). Nunca separe testes por frente: a frente Testes conta uma vez de qualquer jeito, e duas
  tarefas só espalham o mesmo trabalho.
- Mesmo assim, **cada tarefa de código leva os próprios testes de unidade** na PR dela. A tarefa de Testes
  fica com o fluxo inteiro, não com o acúmulo dos testes das outras (isso viraria a PR gigante).
- Cada tarefa precisa poder ser mergeada sozinha: compila, os testes passam e não quebra o que existe
  (tela nova ainda sem link no menu, endpoint novo sem ninguém chamando).

## Como quebrar cada frente

Moldes que costumam dar PRs pequenas. Adapte ao que a história pede.

**Banco de dados**
- Entidade + configuração do EF + migration de uma coisa (uma tabela ou um conjunto de colunas). Sem regra
  de negócio. Semente (seed) separada se for grande.

**Backend**
- Consulta (GET) separada do comando (POST/PUT).
- Validações ("conferir se pode": perfil, dono, situação, saldo) separadas da gravação, quando juntas
  passam do tamanho.
- Gravação: muda o estado e grava, numa transação.
- Histórico/auditoria em tarefa própria, se for outra tabela.
- Integração com sistema externo: um gateway por operação, com o mock para desenvolvimento.

**Frontend**
- Rota + página com layout e dados fixos (não depende do back).
- Integração com a API (gerar o cliente do contrato, ex. Orval, entra aqui), com carregando e erro.
- Cada ação da tela (botão, janela, formulário) numa tarefa.
- Regras de exibição (quem vê o botão, em que situação) junto da ação ou separadas, se forem muitas.
- Mostrar o resultado depois da ação (bloco novo, linha no histórico) sem recarregar a página.

## Estimar o tamanho

Para cada tarefa, liste mentalmente os arquivos que ela cria ou altera, seguindo a estrutura do repositório
(para C#, `Padrões/CSharp/Estrutura de pastas.md` no vault). Para calibrar, procure uma funcionalidade
parecida já feita e veja quantos arquivos ela mexeu:

```bash
git log --oneline --grep "<palavra da funcionalidade>"
git show --stat <commit>
```

Até ~15 arquivos está bom; acima de ~20, quebre. Arquivo gerado (migration, cliente do Orval,
`routeTree.gen.ts`) conta pouco para a revisão, mas diga que ele entra.

## Se existir ferramenta do Jira na sessão

Se houver um conector do Jira/Atlassian disponível, ofereça criar ou atualizar as tarefas por ele, mas
**só depois da parada 2 e com o OK dele**, mostrando antes a lista exata do que será criado. Sem conector,
entregue o texto para colar.
