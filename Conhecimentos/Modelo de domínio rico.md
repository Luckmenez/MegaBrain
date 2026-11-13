---
tipo: conceito
area: Arquitetura
projetos: [cet-medicao]
criado: 2026-11-13
---
# Modelo de domínio rico

## O que é
Uma entidade que **protege as próprias regras**: as propriedades só mudam por métodos com nome de negócio
(`Enviar`, `Encaminhar`, `Devolver`), e cada método confere se a mudança é permitida.

O oposto é o **modelo anêmico**: uma classe só com `get; set;`, em que qualquer parte do código pode fazer
`medicao.Situacao = EnviadaFinanceira` sem conferir nada.

## Por que existe / que problema resolve
Com o modelo anêmico, a regra "só se encaminha uma medição que está com o gestor" precisa ser lembrada em
**todo** lugar que muda a situação. Basta um caso de uso esquecer para o banco ter um dado impossível.

Com o modelo rico, a regra fica em **um lugar só**, e é impossível pular: não existe `set` público.

## Como aparece no código
`Dominio/Entidades/MedicaoDeContrato.cs` do [[cet-medicao]]:

```csharp
public SituacaoMedicao Situacao { get; private set; }   // ninguém de fora muda
private readonly List<ItemMedicao> _itens = [];
public IReadOnlyList<ItemMedicao> Itens => _itens;        // de fora só se lê

public void Encaminhar(string gestorId, string gestorNome, string perfil, string email, DateTimeOffset agora)
{
    if (Situacao != SituacaoMedicao.ComGestor)
        throw new RegraVioladaException(CodigosDeErro.MedicaoInvalida,
            "Só uma medição com o gestor pode ser encaminhada à Financeira.");

    AssinaturaGestor = new AssinaturaDoGestor(gestorId, gestorNome, perfil, email, agora, NovoCodigoDeAssinatura());
    Situacao = SituacaoMedicao.EnviadaFinanceira;
    _historico.Add(/* registro do encaminhamento */);
}
```

Detalhes que valem aprender:
- **Construtor privado + método de fábrica** (`MedicaoDeContrato.Enviar(...)`): a medição só nasce por um
  caminho que valida tudo. O construtor vazio privado existe para o EF Core conseguir montar a entidade ao ler do banco.
- **Lista privada exposta como `IReadOnlyList`**: ninguém faz `medicao.Itens.Add(...)` por fora.
- **O histórico é gravado pelo próprio método**: impossível encaminhar sem registrar.

## Pontos de atenção
- **O que fica na entidade e o que fica no caso de uso?** Regra que só olha a própria medição (situação,
  quantidades, anexos) fica na entidade. Regra que precisa de banco ou de sistema externo ("este gestor é do
  contrato?", "tem saldo?") fica no caso de uso. Os comentários da `MedicaoDeContrato` dizem exatamente isso.
- Exceções do domínio (`RegraVioladaException`) viram HTTP 422 no `TratadorDeExcecoes`: a entidade não sabe
  nada de HTTP.
- Ver [[2026-11-04 Regras do envio na entidade antes da transação]].

## Com minhas palavras


## Relacionados
- [[Arquitetura em camadas]]
- [[Dual write]]
- [[Records]]
