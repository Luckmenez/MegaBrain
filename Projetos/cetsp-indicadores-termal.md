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

> **Momento atual (23/11/2026):** a base está pronta (login, layout, filtro de horário). O **tratamento de
> dados ainda não começou** e está para começar. O protótipo é uma referência viva: código e protótipo vão
> sendo ajustados juntos, então podem não bater 100%.

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
Lista única em `web/src/lib/telas.ts`. Hoje todas só têm o cabeçalho e o seletor de faixa.

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
| `Cet.IndicadoresTermal.Aplicacao` | Casos de uso (hoje só login, renovar e sair) |
| `Cet.IndicadoresTermal.Comunicacao` | DTOs de requisição e resposta |
| `Cet.IndicadoresTermal.Dominio` | Entidades (`Sessao`, `Perfil`), interfaces de repositório e gateway |
| `Cet.IndicadoresTermal.Infra` | EF Core, `SessaoRepositorio`, `CetGateway` (real) e `CetGatewayMock` |

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

## Conceitos usados aqui
- [[Arquitetura em camadas]]
- [[Gateway]]: `ICetGateway` no Dominio, real e mock na Infra
- [[Injeção de dependência]]
- [[async-await e CancellationToken]]
- [[Records]]: DTOs da `Comunicacao`
- [[Migrations]]

## Decisões
- (nenhuma registrada ainda)

## Próximos passos
- [ ] **Tratamento de dados** (está para começar): entidades de lentidão, a carga dos dados da CET e os
  primeiros endpoints de indicadores.
- [ ] Definir **como a CET entrega os dados**: API consultada na hora ou carga importada para o nosso banco?
- [ ] Registrar a **data e hora de cada atualização** para mostrar no topo.
- [ ] Marcar **datas comemorativas / atípicas** nos dias.
- [ ] Definir de onde vêm os **limites das cores** da escala (regra fixa da CET ou configurável).
- [ ] Criar a tela **Termal histórico** no código (está no protótipo).
- [ ] **Exportar relatórios** (futuro).
