---
tipo: padrao
area: C#
origem: claude
revisado: false
criado: 2026-11-13
---
# Testes

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.

## Bibliotecas
| Item | Biblioteca | Para quê |
|---|---|---|
| - [ ] | `xunit` + `xunit.runner.visualstudio` | rodar os testes (no Gerenciador de Testes do Visual Studio) |
| - [ ] | `NSubstitute` | substituir dependências: `Substitute.For<ICetGateway>()` |
| - [ ] | `AwesomeAssertions` | conferir resultados com frases: `resultado.Should().HaveCount(2)` |
| - [ ] | `Microsoft.EntityFrameworkCore.Sqlite` | testar repositório e transação com banco de verdade, em memória |
| - [ ] | `coverlet.collector` | medir cobertura |

## Como escrever
- [ ] Nome do teste como frase, com `_`: `Deve_devolver_lista_vazia_quando_o_usuario_nao_participa_de_nenhum_contrato`.
- [ ] Teste de caso de uso: dependências com NSubstitute e relógio falso (`TimeProvider`) numa data fixa.
- [ ] Concorrência e transação se testam com banco (SQLite), não com mock: mock não trava linha.
- [ ] Dados de teste montados por fábricas em `Suporte/`, para o teste mostrar só o que importa nele.
- [ ] Um projeto de testes, com pastas espelhando as camadas. Ver [[Estrutura de pastas]].
