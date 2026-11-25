---
origem: claude
revisado: false
tipo: decisao
projeto: cetsp-indicadores-termal
data: 2026-11-24
status: aceita
---
# Buscar os dias anteriores por uma fila no banco

## Contexto
A busca de 5 em 5 minutos do [[cetsp-indicadores-termal]] só traz **hoje e ontem**. Os dias mais antigos (a série
vai desde 2019) não estavam no nosso banco, e a Tabela termal mostrava só o que já tinha sido coletado.

O plano combinado com o time foi: **buscar no banco; se não tiver, buscar na CET**. A dúvida era **onde** fazer
essa busca, porque:
- um dia inteiro leva de **6 a 25 s** na WazeApi; um ano, de 40 minutos a mais de 2 horas;
- a tela abre num período e a **escala de cores usa os últimos 12 meses**, então até um mês pede um ano;
- a homologação da WazeApi aponta para o **banco de produção da CET**: centenas de chamadas seguidas pesam lá.

## Opções consideradas
1. **Buscar dentro da requisição da tela**: a API vê o que falta, busca na CET e só depois responde.
2. **Fila no banco + [[Serviço em segundo plano (BackgroundService)|serviço em segundo plano]]**: a API responde na
   hora com o que tem e anota os dias que faltam; o serviço busca um por vez.
3. **Meio-termo**: até uns 3 dias faltando, busca na requisição; acima disso, fila.
4. **Carga inicial de tudo desde 2019** antes de abrir a tela.

## Decisão e porquê
**Opção 2.**
- **A 1 não funciona:** o navegador desiste da requisição muito antes das horas que um ano leva, e seriam
  centenas de chamadas seguidas no banco de produção da CET.
- **A 3 complica sem ganho:** dois caminhos para a mesma coisa, e o caso comum (abrir um ano) cai na fila de
  qualquer jeito.
- **A 4 não resolve sozinha:** os buracos (API parada no fim de semana) continuariam aparecendo. Ela fica como
  complemento, para depois.
- **A fila no banco** não se perde se a API reiniciar, deixa a tela rápida (mostra o que tem e se atualiza
  sozinha) e controla o ritmo: **um dia por vez, com 10 s de pausa**.

## Consequências
- **A tela mostra "Buscando N dias na CET"** e se atualiza a cada 10 s até a fila esvaziar.
- **A primeira vez demora; a segunda é instantânea:** cada dia é buscado uma vez só, até os que a CET devolve
  vazios, porque a linha da fila **fica gravada** depois de buscada.
- **O mais recente primeiro:** o último período pedido passa na frente (quem troca de ano vê o ano novo encher
  antes).
- **Desiste depois de 3 falhas** (decidido em 24/11/2026, depois que 09/12/2025 falhou 15 vezes e prendeu a fila
  e o aviso da tela). O motivo fica gravado no dia.
- **Só busca o que alguém pediu:** um ano que ninguém abre não entra na fila. A carga inicial desde 2019 fica como
  próximo passo.
- **Código:** `api/src/.../UseCases/Termal/DiasAnteriores/` e `Servicos/BuscaDeDiasAnterioresEmSegundoPlano.cs`,
  commits `a4069ad` (fila) e `f60a4ce` (desistir depois de 3 falhas), branch `feat/termal-dias-anteriores`.
