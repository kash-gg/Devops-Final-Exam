# Public practice report

All six Section B tasks passed their recorded practice checks.
See [sanitized verification summary](PROGRESS.md), [Jenkins evidence](JENKINS-EVIDENCE.md) and [Jira evidence](JIRA-EVIDENCE.md).

The four PowerShell scripts were actually executed using Windows PowerShell 5.1.
Native-command results were judged by exit codes. Git release verification used read-only commands.
Jenkins success was read from its build log; Jira success uses user screenshots and explicit completion confirmation.

## Limits
- This is a summary of the recorded practice run, not a fresh automated test run.
- Jenkins stages only echo and require a Windows agent.
- The Docker echo CMD exits with code 0; use docker ps -a. KeepAlive overrides CMD with sleep 300.
- Practice uses a separate container name, namespace and NodePort 30199.
- The Terraform output URL remains localhost:30099, exactly as specified by the paper.
- Other machines may need tools, network access, image caches and terraform init.
- Pre-cache alpine, nginx:alpine in the cluster runtime and the Terraform local provider.
- Raw host inventories, private environment details, Terraform state and provider binaries are not published.

For file descriptions and the 70-minute task schedule plus 5-minute spare, see [the runbook](EXAM-RUNBOOK.md).
