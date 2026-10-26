[CmdletBinding()]
param([switch]$Practice,[switch]$Exam)
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
    Record ('## IaC '+(Get-Date -Format s))
    Guard
    Push-Location (Join-Path $PSScriptRoot 'iac')
    try {
        Run 'terraform' @('init','-input=false','-no-color')
        Run 'terraform' @('validate','-no-color')
        Run 'terraform' @('apply','-auto-approve','-input=false','-no-color')
        $actual = Get-Content -LiteralPath 'capstone.env' -Raw
        $expected = "PAYMENT_GATEWAY_URL=http://localhost:30099`nSTATUS=DEPLOYED`n"
        if ($actual -cne $expected) { throw 'FAIL: capstone.env content mismatch.' }
        Record 'PASS: capstone.env exactly matches expected content.'
        Record $actual
        Run 'wsl.exe' @('-d','Ubuntu','--','test','-d','/mnt/d/exam-day/iac')
        Record 'PASS: Ubuntu can see /mnt/d/exam-day/iac.'
        $linuxScript = "cd /mnt/d/exam-day/iac || exit 1`nansible localhost -m command -a ""cat capstone.env"" -c local || exit 1`nansible localhost -m stat -a ""path=capstone.env"" -c local`n"
        Set-Content -LiteralPath 'ansible-inspect.sh' -Value $linuxScript -Encoding ascii -NoNewline
        Run 'wsl.exe' @('-d','Ubuntu','--','bash','/mnt/d/exam-day/iac/ansible-inspect.sh')
        if ($script:LastOutput -notmatch 'PAYMENT_GATEWAY_URL=http://localhost:30099' -or $script:LastOutput -notmatch 'STATUS=DEPLOYED' -or $script:LastOutput -notmatch '"exists": true') { throw 'FAIL: Ansible output did not verify expected contents and file existence.' }
        Record 'PASS: Terraform init/validate/apply and both Ansible ad-hoc inspections completed.'
    } finally { Pop-Location }
    exit 0
} catch { Record $_.Exception.Message; exit 1 }



