# Sanitized Jenkins evidence

Evidence source: the newly created exam pipeline's local build log, read independently after the user ran the build.

Verified stage order:
1. Build & Test
2. Docker Packaging
3. Deploy Cluster

Exactly three Windows bat steps were observed. Each printed its expected message.
The recorded build ended with Finished: SUCCESS.

PASS is based on that observed execution. These stages only echo; they perform no real compilation, Docker packaging or Kubernetes deployment.
Local log paths, account names, opaque Jenkins console annotations and unrelated job details are omitted.
