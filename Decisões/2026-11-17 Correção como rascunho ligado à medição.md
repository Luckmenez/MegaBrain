---
origem: claude
revisado: false
tipo: decisao
projeto: cet-medicao
data: 2026-11-17
status: aceita
---
# Correção como rascunho ligado à medição

## Contexto
No [[cet-medicao]], o gestor devolve a medição ao fiscal com um motivo geral e um motivo por item. O fiscal
precisa **corrigir** (mudar quantidades, remover ou incluir itens, trocar documentos), poder **salvar e
continuar depois**, assinar de novo e reenviar. A medição passa a `Corrigida`, e a tela mostra o que mudou em
cada item apontado ("Sem alteração", "220 → 200 m²").

## Opções consideradas
1. Editar a própria medição enquanto ela está devolvida.
2. Uma tabela nova só para correções em andamento.
3. Reaproveitar a tabela `Rascunho` com uma coluna `MedicaoId`: nula para uma medição nova, preenchida para a
   correção daquela medição.

## Decisão e porquê
**Opção 3.**
- Com a opção 1, o gestor veria dados pela metade enquanto o fiscal corrige, e não haveria como "descartar"
  a correção.
- O rascunho já tem tudo o que a correção precisa (execução, itens, anexos, salvar, descartar), e o editor do
  front já sabe trabalhar com ele. A opção 2 duplicaria tudo isso.
- Um **índice único filtrado** (`MedicaoId IS NOT NULL`) garante no banco que uma medição tem no máximo uma
  correção em andamento.
- Abrir a correção (`POST /medicoes/{id}/correcao`) devolve a que já existe ou cria uma nova. Por isso a tela
  pode chamá-lo toda vez que o fiscal clica em Corrigir.
- No reenvio, a medição aplica os dados do rascunho (`MedicaoDeContrato.Corrigir`) e o rascunho é apagado na
  **mesma transação**: ver [[Unit of Work]] e [[Dual write]].
- O antes e o depois (`AlteracoesDaCorrecao`) ficam **no registro do histórico**, como JSON numa coluna: ver
  [[Value Converter do EF Core]]. A tela da medição corrigida lê a última correção do próprio histórico, sem
  precisar de colunas novas na medição.
- O que já era conferido no envio (unidade de serviço, vigência, itens do contrato) foi extraído para
  `ConferenciaDoContrato`, usada pelo envio e pela correção.

Commits `b64cc34` (domínio) e `29e502e` (API).

## Consequências
- Número e mês de referência não mudam na correção. A assinatura nova substitui a anterior, e o código antigo
  continua no histórico.
- Os anexos da medição entram no rascunho **sem arquivo guardado**, porque a medição só registra nome, tipo e
  tamanho até a CET definir o armazenamento. O conteúdo dos anexos novos é descartado no reenvio, como no envio.
- Limitação: o rascunho não guarda as **observações**. Se o fiscal salvar no meio da correção, as observações
  editadas se perdem; elas só são gravadas no reenvio.
- O gestor pode devolver de novo uma `Corrigida` (ela pode continuar errada): os novos itens apontados substituem
  os anteriores, e a próxima correção compara com eles. O fiscal "Solicitar devolução" ficou para outro fluxo.
