[CmdletBinding()]
param([switch]$Practice,[switch]$Exam)
$ErrorActionPreference = 'Stop'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$progress = Join-Path $PSScriptRoot 'PROGRESS.md'
if (!(Test-Path -LiteralPath $progress)) { Set-Content -Path $progress -Encoding ascii -Value '# Exam-day practice evidence' }
function Record([string]$Text) {
    Write-Output $Text
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try { Add-Content -LiteralPath $progress -Encoding ascii -Value $Text -ErrorAction Stop; return }
        catch { if ($attempt -eq 5) { throw }; Start-Sleep -Milliseconds 150 }
    }
}
$script:failures = 0
function Check([string]$Tool,[string[]]$Arguments) {
    if (!(Get-Command $Tool -ErrorAction SilentlyContinue)) { $script:failures++; Record ('BLOCKED: tool missing after PATH refresh: '+$Tool); return }
    try { $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'; try { $result = & $Tool @Arguments 2>&1; $code = $LASTEXITCODE } finally { $ErrorActionPreference = $old }; Record ('{0} {1}: exit={2}' -f $Tool,($Arguments -join ' '),$code); $result | ForEach-Object { Record ([string]$_) }; if ($code -eq 0) { Record ('PASS: '+$Tool) } else { $script:failures++; Record ('FAIL: '+$Tool) } }
    catch { $script:failures++; Record ('BLOCKED: '+$Tool+' '+$_.Exception.Message) }
}
Record ('## Precheck '+(Get-Date -Format s))
Record ('PowerShell '+$PSVersionTable.PSVersion.ToString())
Check 'git' @('--version')
Check 'docker' @('--version')
Check 'kubectl' @('version','--client')
Check 'minikube' @('version')
Check 'terraform' @('version')
Check 'wsl.exe' @('-d','Ubuntu','--','ansible','--version')
Check 'docker' @('info','--format','{{.ServerVersion}}')
Check 'kubectl' @('config','current-context')
Check 'kubectl' @('config','get-contexts','-o','name')
Check 'docker' @('ps','-a','--format','{{.Names}} | {{.Image}} | {{.Status}} | {{.Ports}}')
Check 'minikube' @('status','-p','capstone-simple')
foreach ($port in @(18080,30099,30199)) {
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
    Record ('INFO: host TCP port '+$port+' '+$(if ($listeners.Count) {'IN USE (PIDs '+(($listeners | Select-Object -ExpandProperty OwningProcess -Unique) -join ',')+')'} else {'FREE'}))
}
foreach ($name in @('payment-live','payment-live-practice')) { Check 'docker' @('ps','-a','--filter',('name=^/'+$name+'$'),'--format','{{.Names}} | {{.Status}}') }
Record 'INFO: precheck is read-only; host port availability does not prove a Kubernetes NodePort is free.'
if ($Practice -and $Exam) { Record 'BLOCKED: choose one mode only.'; exit 1 }
if ($Exam) {
    $names = & docker ps -a --filter 'name=^/payment-live$' --format '{{.Names}}'
    $code = $LASTEXITCODE
    Record ('Exam guard docker ps exit='+$code)
    if ($code -ne 0 -or $names) { Record 'BLOCKED: -Exam refused; payment-live exists or cannot be checked.'; exit 1 }
}
if ($script:failures) { Record 'FAIL: precheck has failed or blocked checks.'; exit 1 }
Record 'PASS: all precheck commands completed with exit 0.'
exit 0


