# Liga cada skill de Skills/ em ~/.claude/skills/ (Windows) e cria o endereco fixo ~/.claude/megabrain para o vault.
# Usa "junction": um atalho de pasta que nao precisa de administrador. Editar a skill no vault ja vale para o Claude.
# Uso: na pasta do vault, rode  powershell -ExecutionPolicy Bypass -File Skills\instalar.ps1
# (Sem acentos de proposito: o PowerShell 5.1 le este arquivo como ANSI.)

$origem = $PSScriptRoot
$vault = Split-Path $origem -Parent
$claude = Join-Path $HOME '.claude'
$destino = Join-Path $claude 'skills'
New-Item -ItemType Directory -Force -Path $destino | Out-Null

# Endereco fixo do vault: ~/.claude/megabrain aponta para onde o vault estiver nesta maquina.
# Os CLAUDE.md dos projetos importam notas por ele (@~/.claude/megabrain/...), igual em todo computador.
$atalhoVault = Join-Path $claude 'megabrain'
if (Test-Path $atalhoVault) {
    $item = Get-Item $atalhoVault -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        $alvo = @($item.Target)[0]
        if ($alvo -eq $vault) {
            Write-Host "ok        megabrain -> $vault (ja ligado)"
        } else {
            Write-Host "ATENCAO   megabrain aponta para $alvo, nao para $vault. Apague o atalho $atalhoVault e rode de novo."
        }
    } else {
        Write-Host "PULADO    megabrain: ja existe uma pasta de verdade em $atalhoVault. Renomeie e rode de novo."
    }
} else {
    New-Item -ItemType Junction -Path $atalhoVault -Target $vault | Out-Null
    Write-Host "instalado megabrain -> $vault"
}

Get-ChildItem -Path $origem -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object {
    $link = Join-Path $destino $_.Name
    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
            Write-Host "ok        $($_.Name) (ja ligada)"
        } else {
            Write-Host "PULADA    $($_.Name): ja existe uma pasta de verdade em $link. Apague-a ou renomeie e rode de novo."
        }
    } else {
        New-Item -ItemType Junction -Path $link -Target $_.FullName | Out-Null
        Write-Host "instalada $($_.Name)"
    }
}
