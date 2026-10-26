# Section A - answer by content
Status "knowledge, not run" means no runtime verification is claimed.

| No. | Answer and one-line reasoning | Evidence status |
|---|---|---|
| 1 | git pull = fetch plus integration (merge in the paper); fetch alone only downloads. Pull can be configured to rebase. | knowledge, not run |
| 2 | --soft keeps changes staged; --hard discards tracked changes from index and working tree. | knowledge, not run |
| 3 | ENV sets image/runtime environment variables; ARG is a build-time input. | knowledge, not run |
| 4 | Multi-stage builds exclude compilers/build tools from the final runtime image. | knowledge, not run |
| 5 | echo prints a message into the Jenkins build log. | RUN: exam-pipeline #1 local log verified; all three echo messages and Finished: SUCCESS |
| 6 | Separate agents protect the controller from resource exhaustion and untrusted build code. | knowledge, not run |
| 7 | kubectl config current-context prints the selected context. | RUN: precheck exit 0, docker-desktop |
| 8 | RollingUpdate replaces Pods incrementally to preserve availability when readiness/capacity permit. | knowledge, not run |
| 9 | Inject a Secret through valueFrom.secretKeyRef or mount a Secret volume. | knowledge, not run |
| 10 | Terraform provisions infrastructure; Ansible configures and manages it. | knowledge, not run; practical evidence pending |

Reference checks: [Docker run](https://docs.docker.com/reference/cli/docker/container/run/),
[Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/),
[Terraform local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file),
[Ansible ad-hoc](https://docs.ansible.com/projects/ansible/latest/command_guide/intro_adhoc.html).
These are knowledge references, not evidence that local commands passed.


