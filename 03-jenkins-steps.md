# Jenkins: new inline Pipeline, user clicks only
1. Open your Windows Jenkins dashboard. Leave all existing jobs, credentials,
   global configuration, diagnostic job and service account unchanged.
2. Check for exam-pipeline first. If it exists, stop and ask before replacing it.
3. New Item > name exam-pipeline > Pipeline > OK.
4. Scroll to Pipeline > Definition: Pipeline script (inline).
5. Open D:\exam-day\Jenkinsfile.exam, copy all contents, paste into Script.
6. Do not choose Pipeline script from SCM. Save > Build Now.
7. Open the new build number > Console Output.
8. Expected, not yet verified: all three stages Build & Test, Docker Packaging,
   Deploy Cluster; their three echo messages; Finished: SUCCESS.

agent any means any available Jenkins agent. These bat steps require the assigned
agent to be Windows; this lab uses Windows Jenkins. Echo-only stages demonstrate
the required structure; they do not compile, package or deploy anything.
LocalSystem has no Python PATH, so this file uses only bat echo.

Tell Codex the build number. Codex reads only the new job's log:
C:\ProgramData\Jenkins\.jenkins\jobs\exam-pipeline\builds\N\log
If inaccessible, paste the full Console Output. A green expectation is not a PASS.

