#!/usr/bin/env sh
# Liga cada skill de Skills/ em ~/.claude/skills/ (Mac e Linux), com link simbólico,
# e cria o endereço fixo ~/.claude/megabrain para o vault.
# Editar a skill no vault já vale para o Claude.
# Uso: na pasta do vault, rode  sh Skills/instalar.sh

origem="$(cd "$(dirname "$0")" && pwd)"
vault="$(dirname "$origem")"
destino="$HOME/.claude/skills"
mkdir -p "$destino"

# Endereço fixo do vault: ~/.claude/megabrain aponta para onde o vault estiver nesta máquina.
# Os CLAUDE.md dos projetos importam notas por ele (@~/.claude/megabrain/...), igual em todo computador.
atalho_vault="$HOME/.claude/megabrain"
if [ -L "$atalho_vault" ]; then
  alvo="$(readlink "$atalho_vault")"
  if [ "$alvo" = "$vault" ]; then
    echo "ok        megabrain -> $vault (já ligado)"
  else
    echo "ATENÇÃO   megabrain aponta para $alvo, não para $vault. Apague o link $atalho_vault e rode de novo."
  fi
elif [ -e "$atalho_vault" ]; then
  echo "PULADO    megabrain: já existe uma pasta de verdade em $atalho_vault. Renomeie e rode de novo."
else
  ln -s "$vault" "$atalho_vault"
  echo "instalado megabrain -> $vault"
fi

for pasta in "$origem"/*/; do
  [ -f "$pasta/SKILL.md" ] || continue
  nome="$(basename "$pasta")"
  link="$destino/$nome"
  if [ -L "$link" ]; then
    echo "ok        $nome (já ligada)"
  elif [ -e "$link" ]; then
    echo "PULADA    $nome: já existe uma pasta de verdade em $link. Apague-a ou renomeie e rode de novo."
  else
    ln -s "${pasta%/}" "$link"
    echo "instalada $nome"
  fi
done

# Skills com scripts em Node (pasta ferramentas/ com package.json): instala as dependências.
for pasta in "$origem"/*/ferramentas/; do
  [ -f "$pasta/package.json" ] || continue
  nome="$(basename "$(dirname "$pasta")")"
  if ! command -v npm >/dev/null 2>&1; then
    echo "AVISO     $nome: instale o Node.js e rode o script de novo para usar os scripts dela."
  elif (cd "$pasta" && npm install --silent --no-fund --no-audit >/dev/null); then
    echo "npm ok    $nome/ferramentas"
  else
    echo "ERRO      npm install em $pasta"
  fi
done
