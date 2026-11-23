---
tipo: indice
---
# Revisar

Aqui fica tudo o que o Claude criou ou alterou e eu ainda não conferi. O vault é meu: nada que a IA escreveu
vale como certo antes de passar por aqui.

## Como revisar uma nota
1. Abra a nota e leia. Corrija, corte ou apague o que não concordar.
2. Em notas de padrão (`Padrões/`), marque `- [x]` só nos itens que eu aprovo.
3. No painel de **Propriedades** do topo da nota, marque `revisado`. A nota some da lista abaixo.

## Ainda não revisadas
```query
[revisado:false]
```

## Tudo o que o Claude criou
Mesmo depois de revisadas, as notas guardam `origem: claude`.
```query
[origem:claude]
```

## Arquivos sem propriedades (conferir à mão)
Estes não têm frontmatter de nota, então não aparecem nas listas acima:
- [ ] `CLAUDE.md`: regras do vault que o Claude segue
- [ ] `~/.claude/CLAUDE.md` (fora do vault): a linha que manda o Claude ler `Padrões/` antes de implementar
- [ ] [[Skills/registrar-no-cerebro/SKILL|registrar-no-cerebro]]: skill
- [ ] [[Skills/revisar-conceito/SKILL|revisar-conceito]]: skill
- [ ] [[Skills/quebrar-historia-jira/SKILL|quebrar-historia-jira]]: skill
- [ ] `Skills/instalar.ps1` e `Skills/instalar.sh`: scripts de instalação
- [ ] [[Templates/Padrao|Template de padrão]] e [[Templates/Projeto|Template de projeto]]

## Ver exatamente o que mudou
Cada alteração do Claude entra no git com um commit próprio, e o Claude só faz commit quando eu peço.
- **Antes do commit:** `git status` e `git diff` na pasta do vault mostram linha por linha o que mudou.
- **Depois:** `git log --stat` lista os commits e os arquivos de cada um.
