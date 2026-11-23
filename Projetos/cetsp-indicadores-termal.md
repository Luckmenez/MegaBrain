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

> **Momento atual (23/11/2026):** a base está pronta (login, layout, filtro de horário) e a **Tabela termal já
> funciona com dados simulados** (branch `feat/termal-tabela-termal`, publicada, sem PR ainda). A **busca dos
> dados na CET ainda não existe**. O protótipo é uma referência viva: código e protótipo vão sendo ajustados
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

### Como os dados vão chegar (ainda não implementado)
A tela **sempre lê do nosso banco**; a CET só alimenta o banco. Ver [[Repository Pattern]].

```text
API da CET (WazeApi) ──► Gateway ──► grava ──► nosso banco ──► ITermalRepositorio ──► API ──► tela
```

- **Por que não chamar a CET direto da tela:** um dia leva de 5 a 25 s na API da CET (um ano = minutos), a série
  vem desde 2019, e a tela tem que funcionar mesmo com a CET fora do ar.
- **Sob demanda** (a opção que deve ser escolhida): ao abrir um período sem dado no banco, os dias faltantes são
  pedidos à CET; a tela mostra "carregando" até eles chegarem. O framework já faz isso.
- **Periódica**, para o dia de hoje: sem ela, o dia corrente fica parado no valor da primeira consulta. O framework
  busca a cada 5 minutos. Confirmar com o time se "sob demanda" é só para o passado.
- **Para a Tabela termal basta o índice da cidade** (um número por meia hora, cerca de 130 mil linhas desde 2019).
  A lentidão **por via** (cerca de 1 GB por ano) só entra com as telas de corredores.

## A Tabela termal (tela inicial)
Uma grande tabela de **km de lentidão por dia e por meia hora**. Chama "termal" porque funciona como um mapa
de calor: cada célula tem fundo **verde** (pouco trânsito), **amarelo** (piorando) ou **vermelho** (muito
trânsito), e **branco** quando não há registro.

```text
              00:00 00:30 ... │ 06:00 ... 20:00 │ ... 23:30 │ Média diária │ Soma diária │ Média mensal
▼ Janeiro 2026                │ faixa de cálculo│           │              │             │
  01/01 qui •   12    20  ... │  12   ...  36   │ ...  21   │      18      │     534     │
  02/01 sex •   ...           │                 │           │              │             │
▶ Fevereiro 2026 (linha com a média de cada horário no mês)
```

- **Linhas:** os dias, agrupados por mês. Mês fechado mostra uma linha com a média de cada horário; aberto,
  um dia por linha com o dia da semana.
- **Colunas:** os 48 horários de meia hora (00:00 a 23:30).
- **Faixa de cálculo:** o recorte de horário (ex.: Diurno, 06:00–20:00) fica destacado com uma borda azul. A
  média e a soma das colunas da direita usam só os horários dentro da faixa.
- **Bolinha ao lado do dia (•):** **data comemorativa / atípica** (Ano-Novo, aniversário de SP...). Importa
  porque essas datas mexem muito no trânsito.
- **Legenda:** a escala de cor tem limites em km (no protótipo, 290 / 450 / 630) e um botão **Escala**.
- **Cartões de cima:** um dia escolhido (média e soma de lentidão) e o ano (dias úteis, média anual e
  **pico de lentidão** com data e hora).
- **Filtros:** ano, mês (meses sem dados ficam desabilitados), dia da semana, recolher/expandir meses.
- **Barra do topo:** data e hora da **última atualização dos dados** vindos da CET (ex.: "17/08 · 14:00").
  É requisito: o usuário precisa saber de quando são os números.

**Termal histórico** é a mesma tabela olhando para trás (anos desde 2019), com os meses fechados por padrão.

## Telas
Lista única em `web/src/lib/telas.ts`. Fora a Tabela termal, todas só têm o cabeçalho e o seletor de faixa.

| Grupo | Tela | Para que serve (pelo que se sabe hoje) |
|---|---|---|
| Acompanhamento | Tabela termal | o mapa de calor acima, ano corrente |
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
| `Cet.IndicadoresTermal.Api` | Controllers, `Program.cs`, `TratadorDeExcecoes`, JWT |
| `Cet.IndicadoresTermal.Aplicacao` | Casos de uso: login, renovar, sair e `ConsultarTabelaTermalUseCase` |
| `Cet.IndicadoresTermal.Comunicacao` | DTOs de requisição e resposta |
| `Cet.IndicadoresTermal.Dominio` | Entidades (`Sessao`, `Perfil`), interfaces de repositório e gateway, `Termal/` (regras copiadas do framework) |
| `Cet.IndicadoresTermal.Infra` | EF Core, `SessaoRepositorio`, `TermalRepositorioSimulado`, `CetGateway` (real) e `CetGatewayMock` |

### O que já está pronto
- **Login no AD da CET** pelo `ICetGateway.CredenciaisConferemAsync`; em dev, uma simulação liga no lugar.
  Sessão com JWT + token de renovação gravado no banco (`Sessao`), renovar e sair. Aviso no login quando a
  sessão expira (TERMAL-141).
- **Perfis:** Administrador, Operações, Consulta.
- **Layout:** barra do topo, menu lateral, cabeçalho de tela.
- **Faixa de cálculo** (TERMAL-121 a 127): botão no cabeçalho de toda tela, com faixas prontas (Diurno,
  Pico manhã, Pico tarde, Dia todo) ou Manual (início e fim, também clicando na barra dos 48 horários). As
  posições vão de 0 a 47: Diurno é `inicio: 12` (06:00) até `fim: 40` (20:00). Ver
  `web/src/lib/faixa-de-calculo.ts`, commit `f3a0c90`.
- **Tabela termal com dados simulados** (branch `feat/termal-tabela-termal`, 4 commits):

  | Commit | O que entrou |
  |---|---|
  | `e3283fd` | `Dominio/Termal` copiado do framework, com os testes dos números do backlog |
  | `0fe402a` | `ITermalRepositorio` + `TermalRepositorioSimulado` (dados do protótipo, 2019 a 17/08/2026, só em Development) |
  | `917e367` | `GET /api/v1/termal/tabela` (ano, mês, faixa, dias da semana, dia; inválido → 400) |
  | `110acc6` | A tela: cartões, filtros, grade colorida, faixa em azul, datas atípicas, última atualização |

  Conferido contra o protótipo: em 2019 batem as médias por horário, a média diária, a média mensal e o pico
  (1.902 km em 05/09 às 18:30).

### Diferença para confirmar com a CET
A **média anual** do cartão não bate com o protótipo: 2026 dá **403 km com 150 dias úteis** (protótipo: 402 com
149) e 2019 dá 487 (protótipo: 484). Os dias que entram na média são **exatamente os mesmos** do protótipo, então a
diferença está na conta do cartão. O sistema segue a regra do backlog (média dos dias que entram).

### Ambiente local
- O banco sobe com `docker compose -p cet-termal -f infra/docker-compose.yml up -d`. Sem o `-p`, o Docker confunde
  com o banco do [[cet-medicao]] (as duas pastas se chamam `infra`) e troca um container pelo outro.
- A API só sobe em **Development**: abra a `.slnx` (não a pasta), em **Debug**, perfil **https**. Em Release pelo
  modo pasta ela sobe como Production e para por falta de configuração.
- Login de teste: o da simulação descrito no README do repo.

## Conceitos usados aqui
- [[Arquitetura em camadas]]
- [[Gateway]]: `ICetGateway` no Dominio, real e mock na Infra
- [[Repository Pattern]]: `ITermalRepositorio`, simulado agora e lido do banco depois
- [[Injeção de dependência]]
- [[async-await e CancellationToken]]
- [[Records]]: DTOs da `Comunicacao`
- [[Migrations]]

## Decisões
- [[2026-11-23 Copiar o domínio do Termal do framework]]

## Próximos passos
- [ ] Abrir o **PR** da `feat/termal-tabela-termal` para a `develop` (talvez com o número do card nos commits).
- [ ] **Busca dos dados na CET** (próxima PR): gateway da WazeApi (base: `ClienteDaApiDaCet` da PR 18), tabela do
  índice da cidade com migration, busca sob demanda dos dias faltantes e periódica do dia de hoje, repositório
  que lê do banco no lugar do simulado. Precisa da URL e do token de homologação (nos User Secrets).
- [ ] Confirmar com o time se "sob demanda" também cobre o dia de hoje.
- [ ] Confirmar com a CET a conta da **média anual** do cartão (403 × 402).
- [x] Definir **como a CET entrega os dados**: API própria (WazeApi), gravando no nosso banco.
- [ ] Mostrar a **última atualização** na barra do topo (hoje aparece embaixo dos cartões).
- [x] Marcar **datas comemorativas / atípicas** nos dias (calendário do domínio, na Tabela termal).
- [ ] Definir de onde vêm os **limites das cores** da escala (regra fixa da CET ou configurável).
- [ ] Criar a tela **Termal histórico** no código (está no protótipo).
- [ ] **Exportar relatórios** (futuro).
