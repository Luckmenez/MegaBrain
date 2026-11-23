---
tipo: post-linkedin
tema: Fitness functions
status: rascunho
publicado_em:
---
# Fitness functions: o calibre da arquitetura

## Conceito
Metáfora do calibre "passa / não passa" de fábrica: uma máquina rápida (agente de IA, ou o dev com
pressa) despeja peças numa esteira e toda peça passa por um calibre que só aceita a medida da regra.
Estilo blueprint, objeto central (esteira + calibre) com anotações em volta e um anexo com o código.
O que se move: duas peças passam no verde; `Desconto` com o pino `→ Infra` trava, cai nas reprovadas,
a seta volta para a máquina e ela sai certa.

## Roteiro
- **Título:** FITNESS FUNCTIONS. **Subtítulo:** funções de aptidão: o calibre que confere a
  arquitetura a cada peça. Carimbo da prancha: FOLHA 01 · DOMÍNIO ✕ INFRA.
- **Cena:** máquina `agente de IA (ou o dev com pressa)` → esteira → calibre `REGRA` com luz →
  `✓ merge` à direita e alçapão para `✕ reprovadas`. Peças `Pedido`, `Cliente` e `Desconto`
  (pino a mais `→ Infra`).
- **Anotações:** "rápida, mas não conhece sua arquitetura" · "medida objetiva: passa ou não passa" ·
  carimbo "REPROVADO · Domínio → Infra" · "o build quebra antes do merge" · "a IA lê a falha e corrige".
- **Anexo A:** regra do NetArchTest (`ResideInNamespace("Loja.Dominio")` →
  `ShouldNot().HaveDependencyOn("Loja.Infra")` → `IsSuccessful`), com "roda no CI, a cada PR".
- **Cota:** "cada característica, um calibre": camadas · ciclos · tempo de resposta.
- **Animação (10 s):** 0–3 s `Pedido` e `Cliente` passam no verde · 3–5 s `Desconto` trava, luz
  vermelha e carimbo · 5–6 s cai nas reprovadas · 6–7,5 s seta de volta à máquina · 7,5–9,3 s
  `Desconto` sem o pino passa no verde.
- **Gancho guardado** (conceito 2, a placa × a catraca): "pedir não é garantir". Pode servir de
  primeira linha do texto.

## Texto do post (escrito pelo Lucas)

Primeira versão (2026-11-18), antes da revisão:

> Você conhece as fitness functions?
>
> Quem teve a experiência de ler "Fundamentos da Arquitetura de softwares" com toda certeza lembra dos conceitos de fitness functions ( ou função de aptidão ).
>
> A ideia aqui é a de que que apesar de os desenvolvedores e o arquiteto definirem normas para a arquitetura que eles irão usar, é difícil garantir que qualquer um dos engenheiros utilizem as regras definidas.
>
> As Fitness Functions estão aqui justamente para garantir que essas normas estão de acordo com o que foi combinado ao iniciar o projeto.
>
> Pode-se pensar que na era da IA esse tipo de prática esteja datada, mas é nesse momento que ela ganha mais valor!
>
> No momento da IA onde qualquer um pode rodar um prompt e mudar todo o projeto de uma vez só, é imprescindível que os engenheiros e arquiteto coloquem barreiras arquiteturais onde a IA entende que foi gerado um bloqueio e principalmente algumas regras precisam ser respeitadas.
>
> E você? Costuma aplicar esse tipo de função nos seus projetos?

## Revisão
