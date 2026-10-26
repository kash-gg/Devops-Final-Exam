[CmdletBinding()]
param([switch]$Practice,[switch]$Exam,[switch]$KeepAlive)
$ErrorActionPreference = 'Stop'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$progress = Join-Path $PSScriptRoot 'PROGRESS.md'
function Record([string]$Text) {
    Write-Output $Text
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try { Add-Content -LiteralPath $progress -Encoding ascii -Value $Text -ErrorAction Stop; return }
        catch { if ($attempt -eq 5) { throw }; Start-Sleep -Milliseconds 150 }
    }
}
function Run([string]$Tool,[string[]]$Arguments) {
    if (!(Get-Command $Tool -ErrorAction SilentlyContinue)) { throw ('BLOCKED: tool missing after PATH refresh: '+$Tool) }
    Record ('COMMAND: '+$Tool+' '+($Arguments -join ' '))
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $result = @(& $Tool @Arguments 2>&1); $code = $LASTEXITCODE } finally { $ErrorActionPreference = $old }
    $script:LastOutput = ($result | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    foreach ($line in $result) { Record ([string]$line) }
    Record ('EXIT: '+$code)
    if ($code -ne 0) { throw ('FAIL: '+$Tool+' exited '+$code) }
}
function Guard {
    if ($Practice -and $Exam) { throw 'BLOCKED: choose one mode only.' }
    if ($Exam) {
        Run 'docker' @('ps','-a','--filter','name=^/payment-live$','--format','{{.Names}}')
        if ($script:LastOutput.Trim()) { throw 'BLOCKED: -Exam refused: preserved container payment-live exists. Nothing removed.' }
    }
}

try {
    Record ('## Docker '+(Get-Date -Format s))
    Guard
    $name = if ($Exam) { 'payment-live' } else { 'payment-live-practice' }
    Run 'docker' @('ps','-a','--filter',('name=^/'+$name+'$'),'--format','{{.Names}}')
    if ($script:LastOutput.Trim()) { throw ('BLOCKED: '+$name+' already exists. Inspect it; obtain approval before removal. Safe rerun made no changes.') }
    Run 'docker' @('build','-t','payment-engine:capstone','-f',(Join-Path $PSScriptRoot 'Dockerfile'),$PSScriptRoot)
    $argsRun = @('run','-d','--name',$name,'--label','exam-day.owner=exam-day','payment-engine:capstone')
    if ($KeepAlive) { $argsRun += @('sleep','300') }
    Run 'docker' $argsRun
    if (!$KeepAlive) {
        Run 'docker' @('wait',$name)
        if ($script:LastOutput.Trim() -ne '0') { throw 'FAIL: echo container did not exit with code 0.' }
    }
    Run 'docker' @('ps','-a','--filter',('name=^/'+$name+'$'))
    Run 'docker' @('logs',$name)
    if (!$KeepAlive -and $script:LastOutput.Trim() -cne 'Payment Gateway Running') { throw 'FAIL: unexpected echo container log.' }
    Run 'docker' @('ps','--filter',('name=^/'+$name+'$'))
    if ($KeepAlive) {
        Run 'docker' @('inspect','--format','{{.State.Running}}',$name)
        if ($script:LastOutput.Trim() -ne 'true') { throw 'FAIL: KeepAlive container is not running.' }
        Record 'PASS: Docker KeepAlive override sleep 300 is running; image CMD unchanged.'
    } else {
        Record 'PASS: Docker echo output inspected; process exited with code 0.'
        Record 'INFO: echo finishes immediately. Plain docker ps will NOT list this exited container; use docker ps -a.'
    }
    Record ('EXAMINER COMMAND: docker ps --filter name='+$name)
    Record ('EXAMINER COMMAND: docker ps -a --filter name='+$name)
    Record ('CLEANUP (approval required, not executed): docker rm '+$name)
    Record 'INFO: If KeepAlive is still Up, wait for its 300-second sleep to finish before approved docker rm. No automatic deletion.'
    exit 0
} catch { Record $_.Exception.Message; exit 1 }



