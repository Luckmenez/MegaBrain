---
tipo: padrao
area: C#
origem: claude
revisado: false
criado: 2026-11-13
---
# Bibliotecas

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.

## Gestão dos pacotes
- [x] Versões num lugar só, em `Directory.Packages.props` (Central Package Management); o `.csproj` só diz
  `<PackageReference Include="..." />`, sem versão.
  *Por quê:* todos os projetos usam a mesma versão, e atualizar é mudar uma linha.
- [x] Dependência indireta com vulnerabilidade: fixar a versão corrigida no mesmo arquivo, com um comentário
  dizendo de onde ela vem e quando dá para remover.

## API
| Item  | Biblioteca                                                                    | Para quê                           | Fica em |
| ----- | ----------------------------------------------------------------------------- | ---------------------------------- | ------- |
| - [x] | `Microsoft.AspNetCore.OpenApi` + `Microsoft.Extensions.ApiDescription.Server` | gerar o contrato OpenAPI no build  | Api     |
| - [x] | `Swashbuckle.AspNetCore.SwaggerUI`                                            | tela do Swagger em desenvolvimento | Api     |
| - [ ] | `Microsoft.AspNetCore.Authentication.JwtBearer`                               | conferir o JWT das requisições     | Api     |
| - [ ] | `Microsoft.IdentityModel.JsonWebTokens`                                       | gerar o JWT                        | Infra   |

## Aplicação
| Item  | Biblioteca                                             | Para quê                                                    |
| ----- | ------------------------------------------------------ | ----------------------------------------------------------- |
| - [x] | `FluentValidation`                                     | validar a entrada das requisições. Ver [[FluentValidation]] |
| - [x] | `Microsoft.Extensions.Options.ConfigurationExtensions` | ler configuração em classes de Options                      |

## Banco
| Item  | Biblioteca                             | Para quê                                                                      |
| ----- | -------------------------------------- | ----------------------------------------------------------------------------- |
| - [ ] | `Microsoft.EntityFrameworkCore.`       | EF Core, sempre bom se certificar qual é o banco de dados da aplicação atual. |
| - [ ] | `Microsoft.EntityFrameworkCore.Design` | comandos `dotnet ef` (migrations)                                             |

## Testes
Ver [[Testes]].

## Evitar (sugestões, ainda não decididas)
- [ ] AutoMapper: mapear à mão num `Mapeador` estático. *Por quê:* o mapeamento fica visível e o erro
  aparece na compilação, não em execução.
- [ ] MediatR: chamar o caso de uso pela interface dele. *Por quê:* menos indireção para quem está aprendendo.
