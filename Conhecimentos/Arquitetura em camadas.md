---
tipo: conceito
area: Arquitetura
projetos: [cash-flow, cet-medicao]
criado: 2026-11-13
---
# Arquitetura em camadas

## O que é
Dividir o sistema em projetos com papéis diferentes (API, Aplicação, Domínio, Infra) e seguir **uma regra**:
as dependências apontam para dentro, na direção do Domínio. O Domínio não conhece ninguém.

```text
        Api ───▶ Aplicacao ───▶ Dominio ◀─── Infra
   (HTTP, JWT)  (casos de uso)  (regras,      (EF Core, SQL,
                                 interfaces)   CET, arquivos)
```

É a ideia central da *Clean Architecture* e da *Arquitetura Hexagonal* (portas e adaptadores), com nomes diferentes.

## Por que existe / que problema resolve
Regra de negócio muda pouco; banco, framework e sistemas externos mudam muito. Se a regra depende do banco,
trocar o banco (ou testar sem banco) obriga a mexer na regra.

O truque é a **inversão de dependência**:
1. O Domínio declara o que precisa como **interface** (`IMedicaoRepositorio`, `ICetGateway`).
2. A Infra **implementa** essa interface (`MedicaoRepositorio` com EF Core, `CetGatewayMock`).
3. A [[Injeção de dependência]] liga uma na outra quando a aplicação sobe.

Assim a Aplicação chama `ICetGateway` sem saber se do outro lado está a CET real, um mock ou um teste.

## Como aparece no código
**[[cet-medicao]]**: a regra é seguida. Todas as interfaces moram no Dominio:
```text
Dominio/Repositorios/IMedicaoRepositorio.cs   → Infra/DataAccess/Repositorio/MedicaoRepositorio.cs
Dominio/Repositorios/IUnidadeDeTrabalho.cs    → Infra/DataAccess/Repositorio/UnidadeDeTrabalho.cs
Dominio/Gateways/ICetGateway.cs               → Infra/Gateways/CetGatewayMock.cs
```
As implementações da Infra são `internal`: de fora só se enxerga a interface.

**[[cash-flow]]**: a regra é quebrada em um ponto: `IUnitOfWork` está na Infrastructure, e por isso a
Application referencia a Infrastructure. Foi uma escolha consciente para seguir o curso:
[[2026-11-11 Manter IUnitOfWork na Infrastructure]]. O cet-medicao mostra como fica o "certo".

## Pontos de atenção
- **Teste rápido da regra:** abra o `.csproj` do Domínio. Se ele referencia EF Core, ASP.NET ou outro projeto
  da solução, a regra foi quebrada.
- **DTO não é entidade.** A camada `Comunicacao` tem os records que entram e saem pela API. A entidade fica
  no Domínio e não vaza para fora: um mapeador converte (`MedicaoMapeador`).
- Camada demais também é problema. Se uma camada só repassa chamadas sem decidir nada, ela pode não ser necessária.

## Com minhas palavras


## Relacionados
- [[Gateway]]
- [[Unit of Work]]
- [[Modelo de domínio rico]]
- [[Injeção de dependência]]
- [[Repository Pattern]]
