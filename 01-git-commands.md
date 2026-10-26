# Git: run these yourself in Windows PowerShell 5.1
These are instructions, not evidence of commands already run. Never use your existing study repository.
If D:\exam-git-practice already exists, inspect it and ask before reusing it.
Use your own configured Git identity; if a commit reports missing identity, configure it yourself.

```powershell
New-Item -ItemType Directory -Path D:\exam-git-practice -ErrorAction Stop
Set-Location D:\exam-git-practice
git init -b main
Set-Content -Path README.md -Value "Payment and Notification Capstone" -Encoding ascii
git add README.md
git commit -m "Initial README"
git switch -c release-v1.0
Set-Content -Path version.txt -Value "v1.0-prod-bundle" -Encoding ascii
git add version.txt
git commit -m "Finalize production bundle v1.0"
git switch main
git merge release-v1.0
git tag -a v1.0.0-final -m "Final Capstone Release"
git log --oneline --graph --all --decorate
git tag -n
git cat-file -t v1.0.0-final
git show v1.0.0-final --stat
git status
```

Expected, NOT observed: initial branch main; a second commit containing version.txt;
merge usually prints Fast-forward; main and release-v1.0 point at that commit.
tag -n includes v1.0.0-final and Final Capstone Release; cat-file prints tag;
show lists version.txt; status says working tree clean. Commit IDs vary.
Stop on any nonzero $LASTEXITCODE. Do not rerun init/commits/tag blindly.

A fast-forward advances main without a new merge commit when main is an ancestor.
Divergent histories normally require a merge commit with two parents; resolve conflicts
before committing. A fast-forward satisfies this paper's merge requirement.

If a remote is required, YOU configure the correct exam remote, then:
```powershell
git push -u origin main
git push origin release-v1.0
git push origin v1.0.0-final
```
No remote/push is needed unless requested by the examiner.

Tell Codex when finished. Codex will use only status, log, branch, tag -n and
cat-file -t (plus reading version.txt) to verify. git show above is for YOU.

