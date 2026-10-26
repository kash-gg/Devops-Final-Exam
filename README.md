# DevOps Final Exam - TE7950 Section B, Exam Set 10

Exam-day source kit for the Enterprise Multi-Tier Payment and Notification Capstone.
Prepared and practiced using Windows PowerShell 5.1.

- [Exam runbook: 70 minutes plus 5 spare](EXAM-RUNBOOK.md)
- [Sanitized practice results](PROGRESS.md)
- [Practice report and limitations](PRACTICE-REPORT.md)
- [Viva revision](VIVA.md)
- [Section A answer key](MCQ-REVISION.md)

## Tasks and files
| Task | Files |
|---|---|
| Precheck | 00-precheck.ps1 |
| Git | 01-git-commands.md, version.txt |
| Jira | 02-jira-steps.md, JIRA-EVIDENCE.md |
| Jenkins | Jenkinsfile.exam, 03-jenkins-steps.md, JENKINS-EVIDENCE.md |
| Docker | Dockerfile, 04-docker.ps1 |
| Kubernetes | exam-k8s.yaml, 05-k8s.ps1, generated practice YAML |
| Terraform + Ansible | iac/capstone.tf, 06-iac.ps1, provider lock file, generated sample env and inspection script |

All six tasks passed the recorded practice verification. Jira uses manual screenshot/confirmation evidence.
These are historical practice results, not GitHub Actions results.

## Running the kit
Copy the files to D:\exam-day and follow the runbook. Start with:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File D:\exam-day\00-precheck.ps1 -Practice

Scripts default to practice mode. Review the target before confirming Kubernetes apply.
The files contain the intentional example lab paths and resource settings needed to run the kit.

| Item | Practice | Exam |
|---|---|---|
| Container | payment-live-practice | payment-live |
| Namespace | exam-practice | default |
| Context | capstone-simple | explicitly supplied exam context |
| NodePort | 30199 | 30099 |
| Git folder | D:\exam-git-practice | exam repo |

Exam mode refuses an existing payment-live container. Docker name conflicts stop safely; cleanup is never automatic.
Jenkins only echoes and needs a Windows agent. The Docker echo command exits immediately.
Terraform's generated URL is localhost:30099 in both modes, as required by the paper.

## Publication
This is the user-approved source-only public copy with sanitized evidence summaries.
Raw environment logs, host inventories, screenshots, credentials, Terraform state and provider binaries are excluded.
The public repo uses fresh publishing history and a GitHub noreply identity.
release-v1.0 and annotated v1.0.0-final identify this uploaded kit snapshot.
The original practice repository, commits and tag objects remain local and unchanged.

Publishing source files does not push Docker image layers. Build locally from Dockerfile.
Run terraform init on a new machine. Pre-cache alpine, nginx:alpine in the actual cluster runtime and the Terraform local provider while online.
