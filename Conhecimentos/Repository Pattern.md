---
origem: claude
revisado: false
tipo: conceito
area: Arquitetura
projetos: [cetsp-indicadores-termal, cet-medicao]
criado: 2026-11-23
---
# Repository Pattern

## O que é
Uma interface que representa **os seus dados guardados** na linguagem do domínio ("me dê os km destes dias").
Quem usa não sabe se eles vêm de um banco, de um arquivo ou de uma simulação; só a implementação sabe.

É o "irmão" do [[Gateway]]: o repositório esconde o **seu** banco, o gateway esconde o sistema **dos outros**.

## Por que existe / que problema resolve
- **Trocar a fonte sem mexer no resto.** O caso de uso, a API e a tela falam com a interface. Dá para começar
  com uma implementação simulada e trocar pela real depois, mudando um lugar só.
- **Testar.** No teste, a implementação vira uma versão em memória (`SessaoRepositorioEmMemoria`).
- **Separar ler de sincronizar.** O repositório **lê e grava o nosso banco**. Ele **não vai buscar** dado em
  outro sistema. Quem busca é outra peça (um serviço em segundo plano que usa um gateway).

## Como aparece no código
No [[cetsp-indicadores-termal]], a Tabela termal (branch `feat/termal-tabela-termal`):

```text
         ┌──────────── coleta (ainda não existe) ────────────┐
API da CET (WazeApi) ──► Gateway da CET ──► grava ──► nosso banco
                                                         │ lê
Tela ◄── API ◄── caso de uso ◄── ITermalRepositorio ◄────┘
```

- `api/src/Cet.IndicadoresTermal.Dominio/Repositorios/ITermalRepositorio.cs`: o contrato (`LerSerieAsync`,
  `LerValoresAsync`, `LerDatasAtipicasAsync`).
- `api/src/Cet.IndicadoresTermal.Infra/DataAccess/Repositorios/TermalRepositorioSimulado.cs`: enquanto a coleta não
  existe, finge que o banco já está cheio, lendo os dados do protótipo de um JSON. Só liga em desenvolvimento
  (`Termal:UsarSimulacao`). Commit `0fe402a`.
- Quando a coleta existir, nasce um repositório que lê do banco e o simulado sai. O
  `ConsultarTabelaTermalUseCase` não muda.

## Pontos de atenção
- **Repositório não é sincronização.** "Buscar na CET de 5 em 5 minutos" é trabalho de um serviço em segundo plano,
  não do repositório.
- **Simulação só em desenvolvimento.** Deixe uma trava que impede a API de subir com a simulação fora de
  Development, como no login simulado.
- **A interface fala a língua do domínio** (dias, horários, datas atípicas), não a do banco (tabelas, SQL).

## Com minhas palavras
_(escrito por mim, não pelo Claude)_

## Relacionados
- [[Gateway]]
- [[Arquitetura em camadas]]
- [[Unit of Work]]
- [[Injeção de dependência]]
