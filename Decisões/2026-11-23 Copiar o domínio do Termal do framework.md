---
origem: claude
revisado: false
tipo: decisao
projeto: cetsp-indicadores-termal
data: 2026-11-23
status: aceita
---
# Copiar o domínio do Termal do framework

## Contexto
O mesmo produto, **Indicadores e Termal**, existe em dois lugares, de propósito:
- **[[cetsp-indicadores-termal]]:** a solução **isolada da CET**. A CET é cliente e quer a dela, separada.
- **Módulo `waze` do `rautaki-framework-trafego`:** o produto que a Rautaki vende a outras empresas que dependem de
  dados viários. Nasceu da necessidade da CET.

A PR 18 do framework já tinha o Termal quase inteiro: busca na API da CET, regras, telas e exportação. Ela é enorme
(419 arquivos, cerca de 138 mil linhas) e tem dono e cliente próprios. A pergunta era: dá para só copiar a PR?

## Opções consideradas
1. **Copiar a PR inteira.**
2. **Extrair as regras para um pacote compartilhado**, usado pelos dois sistemas.
3. **Copiar só o domínio** (`Dominio/Termal`) e reescrever o resto no padrão do projeto da CET.

## Decisão e porquê
**Opção 3.**
- **A 1 não funciona.** A PR depende de cerca de 15 pacotes `Rautaki.Framework.Core.*` (vários clientes no mesmo
  sistema, mensageria, auditoria), de **Postgres** com tabelas partidas por mês e de um front montado sobre pacotes
  `@rautakitecnologia/*`. O projeto da CET é .NET + **SQL Server** + shadcn, sem framework.
- **A 2 não é permitida.** A solução da CET **não pode depender de nada da Rautaki**, nem de um pacote só de regras
  (decidido em 23/11/2026).
- **O domínio já estava isolado.** `Dominio/Termal` só usa `System.*`: compilou sozinho, sem nenhum ajuste. É a
  parte mais difícil (as regras G1 a G12 do backlog da CET) e já vem com testes que conferem os números do backlog.

## Consequências
- **Cópia fiel.** Os arquivos copiados ficam **iguais ao original**, só com o namespace trocado. Por isso eles fogem
  dos meus [[CSharp|padrões de C#]] (`var`, mais de um tipo por arquivo). Vale a exceção: assim dá para comparar um
  lado com o outro e os dois sistemas mostram os mesmos números.
- **Origem anotada.** Cada arquivo copiado diz de onde veio (caminho no framework, PR 18, commit `4bae4b7`).
- **Sincronia à mão.** Uma correção numa regra precisa ser feita **nos dois lados**.
- **O resto é reescrito.** Coleta, banco, API e telas seguem o padrão do projeto da CET, usando a PR como
  referência.
- **Resultado:** commit `e3283fd` na branch `feat/termal-tabela-termal`.
