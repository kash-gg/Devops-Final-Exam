[CmdletBinding()]
param([switch]$Practice,[switch]$Exam,[string]$ExamContext)
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
    Record ('## Kubernetes '+(Get-Date -Format s))
    Guard
    $context = 'capstone-simple'; $ns = 'exam-practice'; $port = 30199
    if ($Exam) {
        if (!$ExamContext) { throw 'BLOCKED: supply -ExamContext with your separate exam cluster context.' }
        if ($ExamContext -in @('capstone-simple','docker-desktop')) { throw 'BLOCKED: preserved contexts cannot be used for exam writes on this machine.' }
        $context = $ExamContext; $ns = 'default'; $port = 30099
    }
    Record ('TARGET: context='+$context+' namespace='+$ns+' NodePort='+$port)
    $k = @('--context',$context,'--request-timeout=20s')
    Run 'kubectl' ($k + @('get','services','--all-namespaces','-o','json'))
    $services = $script:LastOutput | ConvertFrom-Json
    foreach ($service in $services.items) {
        foreach ($p in $service.spec.ports) {
            if ($p.nodePort -eq $port -and !(($service.metadata.namespace -eq $ns) -and ($service.metadata.name -eq 'payment-backend') -and ($service.metadata.annotations.'exam-day/owner' -eq 'exam-day'))) {
                throw ('BLOCKED: NodePort '+$port+' allocated to '+$service.metadata.namespace+'/'+$service.metadata.name)
            }
        }
    }
    if (!$Exam) {
        Run 'minikube' @('ssh','-p','capstone-simple','--','sudo ss -lnt')
        if ($script:LastOutput -match ':30199\s') { throw 'BLOCKED: TCP 30199 already has a listener in the Minikube node.' }
    }
    Record ('PASS: NodePort '+$port+' has no conflicting Service allocation in target cluster.')
    Run 'kubectl' ($k + @('get','namespaces','-o','json'))
    $namespaces = ($script:LastOutput | ConvertFrom-Json).items
    $existingNs = $namespaces | Where-Object { $_.metadata.name -eq $ns }
    if (!$Exam -and $existingNs -and $existingNs.metadata.annotations.'exam-day/owner' -ne 'exam-day') { throw 'BLOCKED: exam-practice exists without kit ownership. Ask before replacing any resource.' }
    if ($existingNs) {
    Run 'kubectl' ($k + @('get','deployments,services','-n',$ns,'-o','json','--ignore-not-found'))
    $existing = ($script:LastOutput | ConvertFrom-Json).items
    foreach ($item in $existing) {
        if ($item.metadata.name -eq 'payment-backend' -or $item.metadata.labels.tier -eq 'backend') {
            if ($item.metadata.annotations.'exam-day/owner' -ne 'exam-day') { throw 'BLOCKED: conflicting existing resource. Ask before replacing it.' }
        }
    }
    }
    $yaml = (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'exam-k8s.yaml') -Raw).Replace('nodePort: 30099',('nodePort: '+$port)).Replace("`nmetadata:","`nmetadata:`n  annotations:`n    exam-day/owner: exam-day")
    $target = Join-Path $PSScriptRoot ('exam-k8s.'+$ns+'.yaml')
    Set-Content -LiteralPath $target -Value $yaml -Encoding ascii
    $approved = Read-Host ('Type APPLY to confirm first apply to '+$context+'/'+$ns+' NodePort '+$port)
    if ($approved -cne 'APPLY') { throw 'BLOCKED: Kubernetes apply not approved; no cluster resources changed.' }
    if (!$Exam -and !$existingNs) {
        Run 'kubectl' ($k + @('create','namespace',$ns))
        Run 'kubectl' ($k + @('annotate','namespace',$ns,'exam-day/owner=exam-day'))
    }
    Run 'kubectl' ($k + @('apply','--dry-run=server','-n',$ns,'-f',$target))
    Run 'kubectl' ($k + @('apply','-n',$ns,'-f',$target))
    try { Run 'kubectl' ($k + @('rollout','status','deployment/payment-backend','-n',$ns,'--timeout=180s')) }
    catch {
        Record 'FAIL: rollout incomplete; possible nginx:alpine image pull/network failure. Stopping; nothing deleted.'
        Run 'kubectl' ($k + @('get','pods','-n',$ns,'-l','tier=backend','-o','wide'))
        Run 'kubectl' ($k + @('get','events','-n',$ns,'--sort-by=.lastTimestamp'))
        throw 'FAIL: Kubernetes rollout did not complete.'
    }
    Run 'kubectl' ($k + @('get','all','-l','tier=backend','-n',$ns))
    Run 'kubectl' ($k + @('get','svc','-n',$ns))
    Run 'kubectl' ($k + @('get','deployment','payment-backend','-n',$ns,'-o','json'))
    $dep = $script:LastOutput | ConvertFrom-Json
    if ($dep.spec.replicas -ne 2 -or $dep.status.readyReplicas -ne 2) { throw 'FAIL: expected 2 ready replicas.' }
    Run 'kubectl' ($k + @('get','service','payment-backend','-n',$ns,'-o','json'))
    $svc = $script:LastOutput | ConvertFrom-Json
    if ($svc.spec.type -ne 'NodePort' -or $svc.spec.ports[0].nodePort -ne $port -or $svc.spec.selector.tier -ne 'backend') { throw 'FAIL: service verification failed.' }
    Record 'PASS: Kubernetes deployment has 2 ready replicas and matching backend NodePort Service.'
    Record 'CLEANUP (user approval required, not executed): kubectl --context capstone-simple delete namespace exam-practice'
    exit 0
} catch { Record $_.Exception.Message; exit 1 }




