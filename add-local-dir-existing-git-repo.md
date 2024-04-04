### Add a local directory to exisiting git repo

Run the following commands

```bash
git init --initial-branch=k6-scripts    # initialize repo with named local branch
git status
git add .
git remote add origin git@gitlab.credil.org:vanadium/devops-tools.git   # example repo
git fetch
git commit -m "k6-scripts"
git config --global --edit      # change author details
git commit --amend --reset-author
git push --set-upstream origin k6-scripts       # push to remote repo creating new remote branch
```