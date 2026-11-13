#!/usr/bin/env sh
# Liga cada skill de Skills/ em ~/.claude/skills/ (Mac e Linux), com link simbólico.
# Editar a skill no vault já vale para o Claude.
# Uso: na pasta do vault, rode  sh Skills/instalar.sh

origem="$(cd "$(dirname "$0")" && pwd)"
destino="$HOME/.claude/skills"
mkdir -p "$destino"

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
