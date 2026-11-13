# Liga cada skill de Skills/ em ~/.claude/skills/ (Windows).
# Usa "junction": um atalho de pasta que nao precisa de administrador. Editar a skill no vault ja vale para o Claude.
# Uso: na pasta do vault, rode  powershell -ExecutionPolicy Bypass -File Skills\instalar.ps1
# (Sem acentos de proposito: o PowerShell 5.1 le este arquivo como ANSI.)

$origem = $PSScriptRoot
$destino = Join-Path $HOME '.claude\skills'
New-Item -ItemType Directory -Force -Path $destino | Out-Null

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
