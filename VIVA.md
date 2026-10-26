# Viva - knowledge answers, not runtime evidence

**reset --soft / --hard:** --soft moves HEAD but retains index and working tree, so changes stay staged.
--hard resets HEAD, index and tracked working files; it can destroy uncommitted work.

**fetch / pull:** fetch downloads objects and updates remote-tracking refs.
pull fetches then integrates into the current branch (merge or rebase depending on configuration).

**Tags:** A lightweight tag is a direct ref to an object.
An annotated tag has its own object with tagger, date and message, and may be signed.

**Fast-forward / merge commit:** Fast-forward advances the branch to an existing descendant.
A merge commit records joined histories with multiple parents when branches diverge.

**Declarative / scripted; agent any:** Declarative uses pipeline/stages/steps structure; scripted uses Groovy flow.
agent any allocates any available agent; bat requires that chosen agent to be Windows.

**Why avoid controller builds:** Build code can exhaust controller resources or compromise its environment.
Separate agents isolate workloads and keep Jenkins coordination responsive.

**docker ps:** It shows running containers by default.
An echo process finishes with code 0; docker ps -a includes the exited container.

**CMD / ENTRYPOINT:** CMD supplies a default command or default arguments, replaceable at docker run.
ENTRYPOINT selects the executable; runtime arguments normally append to exec-form ENTRYPOINT.

**Image / container:** An image is a packaged filesystem and execution configuration.
A container is a created runtime instance with its own writable layer and process state.

**Multi-stage builds:** Multiple FROM stages separate compilation from the final runtime image.
COPY --from transfers only needed artifacts, leaving build tools out of the final image.

**Deployment / ReplicaSet / Pod:** A Deployment manages rollouts and ReplicaSets.
A ReplicaSet maintains a desired number of matching Pods; Pods run the application containers.

**Labels and selectors:** Labels identify objects; selectors choose matching objects.
Service selectors must match Pod labels to route to their endpoints; metadata labels make the Service itself searchable.

**Services / ports:** Default NodePort range is 30000-32767, though clusters can configure another range.
ClusterIP is internal; NodePort exposes a node port; LoadBalancer requests an external load balancer.

**RollingUpdate:** Replaces old replicas gradually using maxSurge and maxUnavailable.
Availability also depends on ready replicas, readiness checks and sufficient capacity.

**imagePullPolicy:** Always checks for an image at startup; IfNotPresent uses a local image if available.
Never requires a local image; pull policy does not make an unreachable registry available.

**Terraform / Ansible:** Terraform declaratively provisions resources and tracks bindings in state.
Ansible is agentless configuration automation; ad-hoc runs one task, playbooks describe reusable task sequences.

**plan / apply:** plan previews proposed actions against configuration and current state.
apply executes changes, optionally from a saved plan, and updates state.

**Burn-down:** Remaining work is plotted against sprint time.
Compare actual progress with the ideal trend; scope changes can raise the remaining-work line.

