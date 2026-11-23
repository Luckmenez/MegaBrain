---
tipo: padrao
area: C#
origem: claude
revisado: true
criado: 2026-11-13
---
# Estrutura de pastas

Parte de [[CSharp|Padrões de C#]]. Só vale item marcado `- [x]`.
Como organizar **dentro** de cada projeto. Quais projetos existem: [[Projetos da solução]].

## Regra geral
- [x] O namespace segue a pasta (`dotnet_style_namespace_match_folder` no `.editorconfig`).
- [x] Um tipo por arquivo, com o mesmo nome do tipo.

## Por projeto
- [x] **Aplicacao**: pasta por funcionalidade e, dentro, uma pasta por ação, com a interface, a classe e os tipos
  que só ela usa:
  ```text
  UseCases/Medicoes/Enviar/IEnviarMedicaoUseCase.cs
  UseCases/Medicoes/Enviar/EnviarMedicaoUseCase.cs
  UseCases/Medicoes/Enviar/FiscalDaMedicao.cs
  UseCases/Medicoes/MedicaoMapeador.cs        ← compartilhado pelas ações de Medicoes
  ```
- [x] **Dominio**: pasta por tipo de coisa:
  `Entidades/`, `Excecoes/`, `Repositorios/` (interfaces), `Gateways/` (interfaces e tipos de sistemas externos).
- [x] **Exceções**, conforme a opção escolhida em [[Projetos da solução#Onde moram as exceções: duas opções]]:
  ```text
  Opção A: Dominio/Excecoes/              Opção B: X.Exception/
    ErroDaAplicacaoException.cs  (base)     ExceptionBase/ErroDaAplicacaoException.cs  (base)
    RegraVioladaException.cs                ExceptionBase/RegraVioladaException.cs
    CodigosDeErro.cs                        CodigosDeErro.cs
    ResourceMensagensDeErro.resx            ResourceMensagensDeErro.resx
                                            ResourceMensagensDeErro.en.resx   ← uma por idioma
  ```
- [x] **Comunicacao**: `Requisicoes/<Funcionalidade>/` e `Respostas/<Funcionalidade>/`.
- [x] **Infra**: `DataAccess/` (`DbContext`, `Configuracoes/`, `Repositorio/`, `Migrations/`, `Semente/`),
  `Gateways/` e `Seguranca/`.
- [x] **Api**: `Controllers/`, `Erros/`, `Seguranca/`, `OpenApi/`.
- [x] **Tests**: as mesmas pastas da camada testada (`Aplicacao/Medicoes/...`), mais `Suporte/` para fábricas de dados e relógio falso.

## Nomes de arquivo
- [x] Caso de uso: `<Verbo><Coisa>UseCase.cs` (`ListarContratosPropriosUseCase`).
- [x] DTO: `<Coisa>Requisicao.cs` e `<Coisa>Resposta.cs`, ou um nome de negócio quando for mais claro (`MedicaoResumo`).
- [x] Configuração do EF: `<Entidade>Configuracao.cs`.
