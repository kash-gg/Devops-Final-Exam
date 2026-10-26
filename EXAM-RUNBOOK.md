# Section B - 75 minutes
Start in Windows PowerShell 5.1: Set-Location D:\exam-day
Check each native command's $LASTEXITCODE. Practice is the default.
Do not run -Exam on this host: payment-live and both local contexts are protected.

| Order | Task | Minutes | Commands / clicks and screenshot |
|---|---|---:|---|
| 1 | Git | 10 | Follow 01-git-commands.md in scratch/exam repo. Capture git log --oneline --graph --all --decorate; git cat-file -t v1.0.0-final (tag); git tag -n; git status. |
| 2 | Jira | 8 | Backlog > intended sprint > Board > completed tickets to Done > Complete sprint > Reports. Capture board and sprint burndown/report. |
| 3 | Jenkins | 10 | New exam-pipeline > Pipeline script > paste Jenkinsfile.exam > Save > Build Now. Capture all three stages and Finished: SUCCESS. |
| 4 | Docker | 12 | .\04-docker.ps1 -Exam; docker ps -a --filter name=payment-live; docker logs payment-live. Capture echo and Exited (0). For Up evidence use -KeepAlive on a fresh approved name after approved cleanup; CMD is overridden to sleep 300. |
| 5 | Kubernetes | 18 | .\05-k8s.ps1 -Exam -ExamContext YOUR_EXAM_CONTEXT; confirm APPLY. Capture kubectl --context YOUR_EXAM_CONTEXT get all -l tier=backend -n default and get svc -n default: 2 ready Pods and 30099 NodePort. |
| 6 | Terraform + Ansible | 12 | .\06-iac.ps1 -Exam. Capture validate/apply, exact capstone.env contents and Ansible cat/stat output. |
| | Verification spare | 5 | Recheck outputs and screenshots. Total work 70 + spare 5 = 75. |

Practice: .\00-precheck.ps1 -Practice; .\04-docker.ps1 -Practice;
after approved container removal, .\04-docker.ps1 -Practice -KeepAlive;
.\06-iac.ps1 -Practice; .\05-k8s.ps1 -Practice (confirm target before APPLY).
All files should stay in D:\exam-day. Do not alter your existing study repository.

IaC exact commands (already in script): terraform init; terraform validate;
terraform apply -auto-approve. From Ubuntu /mnt/d/exam-day/iac:
ansible localhost -m command -a "cat capstone.env" -c local
ansible localhost -m stat -a "path=capstone.env" -c local
Use the generated ansible-inspect.sh through wsl -d Ubuntu -- bash; no WSL config changes.

Troubleshoot: daemon unavailable -> open Docker Desktop yourself and retry.
payment-live exists -> STOP, preserve it; use practice name. Never auto-remove.
NodePort allocated -> inspect target cluster services; do not replace existing services.
Missing tool -> refresh PATH:
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
ImagePullBackOff/provider download error -> report network/cache limitation; no false PASS.
Keep docker-desktop as default context; scripts always pass --context.
Pre-cache alpine, nginx:alpine in the target cluster, and Terraform local provider
before the exam when network access is available. Installing tools requires permission.

