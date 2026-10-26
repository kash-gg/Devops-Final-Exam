# Sanitized practice verification summary

This public file summarizes checks actually performed during practice. It contains no raw host inventory, raw process output, user profile paths, screenshots, account identifiers or original Git author metadata.
The complete original logs remain local. These results describe the recorded practice run, not a current GitHub Actions run.

| Task | Status | Recorded evidence |
|---|---|---|
| Git | PASS | Read-only checks exited 0; main was clean; the release branch and annotated final tag resolved to the same commit; version.txt had the required content. |
| Jira | PASS | User screenshots showed all three work items Done and the burndown reaching zero. The user explicitly confirmed sprint closure. |
| Jenkins | PASS | The new exam pipeline's build log contained exactly the three required stages, three Windows bat steps, their expected messages and Finished: SUCCESS. |
| Docker | PASS | Build/run/wait/log/inspection commands exited 0; echo printed Payment Gateway Running and exited 0; the KeepAlive variant was verified running. |
| Kubernetes | PASS | After user approval: server dry-run, apply, rollout and get commands exited 0. Two Pods were Running; Deployment/ReplicaSet had 2 ready replicas; practice Service used NodePort 30199. |
| Terraform + Ansible | PASS | Init/validate/apply exited 0; generated file contents matched; WSL path check and Ansible cat/stat checks exited 0. |

All four PowerShell scripts were run under Windows PowerShell 5.1 in practice mode.
Missing tools or failed checks were never reported as PASS.
Early preparation/logging errors were corrected before the successful runs; full diagnostics remain in the local log.
Exam-mode and existing-container safety checks refused writes as expected.
No Jira or Jenkins UI clicks were automated. Git practice mutations were performed by the user; subsequent publishing is separately authorized.
Cleanup and protected-resource details are intentionally omitted from this public evidence summary.

## Public publishing history
This repository has a fresh publishing history using a GitHub noreply identity.
The original practice commits and tag objects remain local.
The public release branch and annotated tag identify the uploaded kit snapshot; they do not claim to be the original private commit objects.
