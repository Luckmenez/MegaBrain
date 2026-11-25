---
origem: claude
revisado: false
tipo: projeto
repo: https://github.com/RautakiTecnologia/cetsp-indicadores-termal
pasta: ~/dev/cet/cetsp-indicadores-termal
status: ativo
---
# cetsp-indicadores-termal

## O que é
Um **"BI de trânsito"** para a CET (trabalho). Hoje os funcionários da CET respondem perguntas sobre trânsito
juntando um monte de planilhas de Excel. Por exemplo:

- "Qual foi o volume no fim do ano passado?", para prever o deste fim de ano.
- "Qual foi a lentidão total do mês anterior?", para passar à imprensa.

O sistema junta esses dados num lugar só, padronizados, e mostra os indicadores de um jeito mais fácil de ler e
de explorar. **Exportar relatórios** está previsto (o botão já aparece no protótipo), mas fica para depois.

### De onde vêm os dados
Da **CET**. Por trás, a CET tira esses dados do Waze, mas o sistema consome só a CET, nunca o Waze direto.
A medida principal é **km de lentidão** (quantos quilômetros de trânsito havia naquele horário).

> **Momento atual (25/11/2026):** a **Tabela termal já lê dados reais da CET**, gravados no nosso banco por dois
> serviços em segundo plano (a busca de 5 em 5 minutos e a fila dos dias anteriores), e segue a **versão nova do
> protótipo** (abre nos últimos 30 dias). Tudo em 3 branches encadeadas, publicadas: ver
> [[#Branches e PRs]]. O protótipo é uma referência viva: código e protótipo vão sendo ajustados
> juntos, então podem não bater 100%.

### O Termal do framework (PR 18)
O mesmo produto existe no `rautaki-framework-trafego` (módulo `waze`, PR 18), a versão que a Rautaki vende a
outras empresas. A da CET é **isolada** e não pode depender de nada da Rautaki. Por isso o **domínio** (as regras)
foi copiado e o resto é reescrito: ver [[2026-11-23 Copiar o domínio do Termal do framework]].

Vale ler antes de mexer na busca de dados:
- `docs/PLANEJAMENTO-CET-SP-TERMAL.md` (no framework): como a API da CET funciona, de onde vem cada aba das
  planilhas e as dúvidas em aberto com a CET.
- **WazeApi da CET:** lentidão já fechada em janelas de 30 minutos, desde 07/01/2019. O rótulo é o **fim** da
  janela ("08:00" = 07:30–08:00), os números vêm como texto e requisição sem corpo precisa de `Content-Length: 0`.
- **A homologação da WazeApi aponta para o banco de produção da CET:** nada de chamar em rajada, e os testes
  automáticos nunca chamam a CET.

### Como os dados chegam
A tela **sempre lê do nosso banco**; a CET só alimenta o banco. Ver [[Repository Pattern]] e [[Gateway]].

```text
                       ┌─ busca de 5 em 5 min (hoje e ontem) ─┐
API da CET (WazeApi) ──┤                                      ├──► IndiceDeLentidao ──► ITermalRepositorio ──► tela
                       └─ fila dos dias anteriores ───────────┘
                              ▲
             a tela pede um período ──► dias que faltam entram em DiaPedidoNaCet
```

Os dois são [[Serviço em segundo plano (BackgroundService)|serviços em segundo plano]] dentro da própria API:
**continuam rodando com a aba fechada** ou o computador de quem usa desligado.

**1. Busca de 5 em 5 minutos** (`ColetarIndiceDoTermalUseCase`), a cada ciclo:
- o **último período fechado**; se faltar período antes dele (primeira busca, CET fora do ar), relê o dia
  inteiro, no máximo hoje e ontem;
- o **período em formação**, gravado como **provisório** (as contas só usam os fechados);
- uma vez por dia, **depois da 01:00**, relê o dia anterior inteiro, porque a CET ainda ajusta valores.
- Se a API ficou parada **mais de um dia**, os dias do meio vão para a fila (inclusive o que parou pela metade).

**2. Fila dos dias anteriores** (sob demanda): ver [[2026-11-24 Buscar os dias anteriores por uma fila no banco]].
- A tela pede um período: a API **responde na hora** com o que tem e põe na fila os dias que faltam (o período e os
  12 meses da escala de cores). A resposta traz `diasCarregando`, e a tela mostra "Buscando N dias na CET".
- O serviço pega **um dia por vez**, busca o dia inteiro, grava e marca `BuscadoEm`. A linha **não sai da
  tabela**: é ela que impede um dia vazio (204 da CET) de voltar para a fila.
- Ordem: quem falhou menos, depois o **pedido mais recente** (o ano que abri por último), depois o dia mais recente.
- **Desiste depois de 3 falhas** (`DesistidoEm`, com o motivo em `UltimaFalha`): um dia com defeito prendia a fila
  e o aviso da tela para sempre.
- Hoje e ontem nunca entram na fila: são da busca de 5 em 5 minutos (assim os dois nunca gravam o mesmo dia).

**Tempos** (quase todos no `appsettings.json`, seção `Termal`):

| O quê | Tempo |
|---|---|
| Busca de 5 em 5 minutos | 5 min (`Coleta:IntervaloEmMinutos`) |
| Pausa entre dois dias da fila | 10 s (`DiasAnteriores:IntervaloEmSegundos`) |
| Pausa depois de uma falha da CET | 5 min (`DiasAnteriores:PausaAposFalhaEmMinutos`) |
| Falhas até desistir de um dia | 3 (no código) |
| Espera máxima por resposta da CET | 40 s (`WazeApi:TempoLimiteEmSegundos`) |
| Tela, com dias na fila / sem | 10 s / 5 min (pausa com a aba em segundo plano) |

Na prática: 2 a 3 dias por minuto, cerca de **2 horas para um ano**.

**Lições do teste real:**
- **A CET pula períodos:** o domingo 22/11/2026 veio com 43 dos 48. Dia com buraco é normal.
- **Qual leitura vale:** o índice do dia fica 5 min em cache na CET e o último fechamento, 3. O último fechamento é
  gravado por último, para valer sobre o dia.
- **Tempos medidos:** último fechamento 0,25 s; período em formação 0,95 s; dia inteiro 6,6 s (0,06 s em cache).
- **Um dia que falha sempre:** 09/12/2025 falhou 15 vezes seguidas, motivo ainda desconhecido. Foi o que
  levou à regra das 3 falhas.
- **Os User Secrets vazavam para os testes:** o teste de integração sobe a API em Development e lia os segredos de
  quem roda. Com a simulação desligada, os testes chamavam a CET. Agora o `ApiDeTeste` força a simulação.

## A Tabela termal (tela inicial)
Uma grande tabela de **km de lentidão por dia e por meia hora**. Chama "termal" porque funciona como um mapa
de calor: cada célula tem fundo **verde** (pouco trânsito), **amarelo** (piorando) ou **vermelho** (muito
trânsito), e **branca** (escura no tema escuro) quando a CET não mediu aquele horário.

```text
                       00:00 ... │ 06:00 ... 20:00 │ ... 23:30 │ Média diária │ Média do período
▼ Últimos 30 dias · 19/07–17/08  │ faixa de cálculo│           │  334 (30 dias)│ 408 (21 dias úteis ✓)
  19/07 dom              19  ... │  15  ...  64    │ ...  30   │      64      │  fim de semana
  20/07 seg              22  ... │  22  ...  318   │ ...  17   │     242      │        ✓
```

- **Período:** abre nos **últimos 30 dias** (até o último dia com dado). Também há **ano** e **mês**: aí cada mês
  vira um bloco, recolhido como "resumo" (média de cada horário).
- **Colunas:** os 48 horários de meia hora. **Horários: Só a faixa** esconde os de fora da faixa (as contas não
  mudam).
- **Faixa de cálculo:** o recorte de horário (ex.: Diurno, 06:00–20:00) fica emoldurado em azul. As médias usam só
  os horários dentro da faixa.
- **As duas médias da direita** (regra da CET, já no domínio):
  - **Média diária:** a média do dia na faixa. No topo do bloco, a média de **todos** os dias com dado.
  - **Média do período:** ✓ se o dia entra, ou o motivo (fim de semana, feriado...). No topo, a média só dos
    **dias úteis com ✓**. É esse o número do cartão. As duas são **média das médias diárias**.
- **Bolinha ao lado do dia (•):** **data atípica** (feriado, aniversário de SP...): mexe muito no trânsito.
- **Cartões de cima:**
  - **Dia:** setas, calendário, botão **Hoje** e o selo "Hoje", "Ontem" ou "Há N dias"; média e pico do dia.
    Clicar numa linha da grade também escolhe o dia.
  - **Período:** o intervalo, os dias úteis, a média e o pico (com data e hora).
- **Barra do topo:** "● 17/08 · 14:00", a **última atualização** dos dados, e um botão que busca tudo de novo.
- **Ainda sem ação:** Ajuda, Exportar e o botão **Escala** da legenda.

**Termal histórico** é a mesma tabela olhando para trás. Por enquanto fica tudo na Tabela termal.

## Telas
Lista única em `web/src/lib/telas.ts`. Fora a Tabela termal, todas só têm o cabeçalho e o seletor de faixa.

| Grupo | Tela | Para que serve (pelo que se sabe hoje) |
|---|---|---|
| Acompanhamento | Tabela termal | o mapa de calor acima |
| | Comparativos | comparar períodos (ex.: este fim de ano × anteriores) |
| | Corredores e grupos | lentidão por via ou grupo de vias |
| Histórico | Médias mensais | totais e médias do mês (ex.: número para a imprensa) |
| | Dias da semana | comportamento por dia da semana |
| | Médias horárias | comportamento por horário |
| | Termal histórico | a tabela termal dos anos anteriores (**está no protótipo, ainda não no código**) |
| Eventos | Datas atípicas | feriados e datas comemorativas |
| | Análise de eventos | efeito de um evento no trânsito |
| Análises | Análise e Relatórios Dinâmicos | tabela dinâmica, o "BI" livre |
| — | Configurações | — |

## Stack
Mesma base do [[cet-medicao]]:
- **API:** .NET 10, ASP.NET Core (controllers), EF Core + SQL Server (Docker em dev), JWT
- **Testes:** xUnit na API; Playwright de ponta a ponta no front (`npm run e2e`)
- **Web:** Vite + React 19 + TypeScript, TanStack Router/Query, Tailwind 4 + shadcn, react-hook-form + zod
- Ícones: recorte da fonte Material Symbols (só os nomes listados em `MaterialSymbolsRounded-cet.txt`)

## Arquitetura (camadas)
Mesma divisão do [[cet-medicao]]: ver [[Arquitetura em camadas]].

| Projeto | Papel |
|---|---|
| `Cet.IndicadoresTermal.Api` | Controllers, `Program.cs`, JWT e os dois serviços em segundo plano (`Servicos/`) |
| `Cet.IndicadoresTermal.Aplicacao` | Casos de uso: login, tabela termal, última atualização, a busca de 5 em 5 minutos e a fila (`UseCases/Termal/`) |
| `Cet.IndicadoresTermal.Comunicacao` | DTOs de requisição e resposta |
| `Cet.IndicadoresTermal.Dominio` | Entidades (`Sessao`, `IndiceDeLentidao`, `ColetaDoTermal`, `DiaPedidoNaCet`), interfaces de repositório e gateway, `Termal/` (regras copiadas do framework) |
| `Cet.IndicadoresTermal.Infra` | EF Core e repositórios, `WazeApiGateway`, `CetGateway` (login) e as simulações |

### O que já está pronto
- **Login no AD da CET** pelo `ICetGateway.CredenciaisConferemAsync`; em dev, uma simulação liga no lugar.
  Sessão com JWT + token de renovação gravado no banco (`Sessao`), renovar e sair.
- **Perfis:** Administrador, Operações, Consulta.
- **Layout:** barra do topo (com a última atualização), menu lateral, cabeçalho de tela.
- **Faixa de cálculo** (TERMAL-121 a 127): faixas prontas (Diurno, Pico manhã, Pico tarde, Dia todo) ou Manual.
  As posições vão de 0 a 47: Diurno é `inicio: 12` (06:00) até `fim: 40` (20:00). Ver
  `web/src/lib/faixa-de-calculo.ts`, commit `f3a0c90`.
- **Tabela termal** com os dados reais da CET (ou os do protótipo, com a simulação ligada).
- **Números conferidos com o protótipo novo:** últimos 30 dias no Diurno, **408 km com 21 dias úteis** e linha
  de 334 km; no Pico manhã, 401 km e pico de 839 km em 11/08 às 08:30. Ficam em testes de ponta a ponta.

### Branches e PRs
As três branches são encadeadas: cada PR aponta para a branch anterior e mostra só os próprios commits.
**Merge na ordem inversa:** a tela nova na fila, a fila na tabela termal, e a tabela termal na `develop`.

| Branch | PR para | Commits |
|---|---|---|
| `feat/termal-tabela-termal` (PR #44) | `develop` | `e3283fd` domínio, `0fe402a` repositório simulado, `917e367` endpoint, `110acc6` tela, `3aa0575` gateway da WazeApi, `2d5c3fe` tabelas do índice, `4fcc65b` busca de 5 em 5 minutos |
| `feat/termal-dias-anteriores` | `feat/termal-tabela-termal` | `2928281` testes presos na simulação, `a4069ad` fila, `99b2e59` tela a cada 5 min, `f60a4ce` desiste depois de 3 falhas |
| `feat/termal-tabela-nova-versao` | `feat/termal-dias-anteriores` | `2784151` últimos 30 dias e última atualização (API), `2b87ca1` protótipo novo (tela) |

Migrations novas: `AdicionaIndiceDeLentidao`, `AdicionaDiaPedidoNaCet`, `DesisteDoDiaQueFalha`.

### Diferença para confirmar com a CET
A **média anual** do cartão não bate com o protótipo: 2026 dá **403 km com 150 dias úteis** (protótipo: 402 com
149) e 2019 dá 487 (protótipo: 484). Os dias que entram na média são **exatamente os mesmos** do protótipo, então a
diferença está na conta do cartão. O sistema segue a regra do backlog (média dos dias que entram). Os últimos 30
dias, por outro lado, batem exatos.

### Ambiente local
- O banco sobe com `docker compose -p cet-termal -f infra/docker-compose.yml up -d`. Sem o `-p`, o Docker confunde
  com o banco do [[cet-medicao]] (as duas pastas se chamam `infra`) e troca um container pelo outro.
- A API só sobe em **Development**: abra a `.slnx` (não a pasta), em **Debug**, perfil **https**.
- **User Secrets** (botão direito no projeto da Api → Gerenciar Segredos do Usuário): a chave do JWT, o token da
  WazeApi e `"Termal:UsarSimulacao": false` para usar os dados reais. Ficam só na máquina: em outra máquina,
  grave de novo.
- **Banco novo começa vazio:** ao abrir a tela, a fila busca os 30 dias e os 12 meses da escala (cerca de 2 horas).
- Com a API aberta no Visual Studio, o build em **Debug** pelo terminal falha (as DLLs ficam presas): use
  `-c Release` para testes e migrations.
- Login de teste: o da simulação descrito no README do repo.

## Conceitos usados aqui
- [[Arquitetura em camadas]]
- [[Gateway]]: `ICetGateway` (login) e `IWazeApiGateway` (lentidão) no Dominio, implementados na Infra
- [[Repository Pattern]]: `ITermalRepositorio` só lê; quem grava é a busca
- [[Serviço em segundo plano (BackgroundService)]]: a busca de 5 em 5 minutos e a fila
- [[Injeção de dependência]]
- [[async-await e CancellationToken]]
- [[Records]]: DTOs da `Comunicacao`
- [[Migrations]]

## Decisões
- [[2026-11-23 Copiar o domínio do Termal do framework]]
- [[2026-11-24 Buscar os dias anteriores por uma fila no banco]]

## Próximos passos
- [ ] Abrir os PRs da fila e da tela nova (encadeados no #44) e fazer o merge na ordem certa.
- [ ] Descobrir por que a CET falha em **09/12/2025** (o motivo agora fica em `UltimaFalha`).
- [ ] Confirmar com a CET **desde quando a WazeApi tem dado** (`Termal:DiasAnteriores:PrimeiroDia`, hoje 2019-01-01).
- [ ] **Carga inicial** do histórico desde 2019, sem depender de alguém abrir cada ano (algumas horas na fila).
- [ ] Confirmar com a CET a conta da **média anual** do cartão (403 × 402).
- [ ] Mostrar quantos dias têm valor em cada horário na dica do "resumo" (o protótipo mostra; a API não devolve).
- [ ] Dar ação a **Ajuda**, **Exportar** e **Escala** (de onde vêm os limites das cores: regra fixa ou configurável).
- [ ] Criar a tela **Termal histórico** no código (está no protótipo).
- [x] Definir **como a CET entrega os dados**: API própria (WazeApi), gravando no nosso banco.
- [x] **Busca na CET:** de 5 em 5 minutos e fila sob demanda dos dias anteriores.
- [x] Mostrar a **última atualização** na barra do topo.
- [x] Marcar **datas atípicas** nos dias (calendário do domínio, na Tabela termal).
