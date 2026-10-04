# ZaiusTide workflow: Windows test -> GitHub -> Linux build

One rule: **code is only ever edited on Windows. The Linux server only pulls and builds.**
Never copy a DLL between machines. If the Linux box needs new code, it gets it from GitHub.

## Every change

1. **Windows:** make a branch for the change (`Git > New Branch`, e.g. `fix-yaraq-gem`).
2. Edit, build in Visual Studio, test on the Windows test server.
3. Database changes: put a `.sql` script in `Database/Updates/...` in the repo. Never change only a live database.
4. **Windows:** commit, then push the branch to GitHub.
5. On GitHub, open a pull request and merge it into `master` (or from a command prompt: `git checkout master`, `git merge --ff-only <branch>`, `git push origin master`).
6. **Linux:** run the SQL script for that change (if any), then `Ops/deploy.sh`, stop the server when asked, press Enter, start it.
7. Confirm: `cat ~/ace-live/BUILD_INFO.txt` shows the commit you just merged.

## Rules that would have prevented the bugs we hit

- Only `Config.js`, `log4net.config`, dats and logs are machine-specific. They are in `.gitignore` and are never committed.
- `bin/` and `obj/` are in `.gitignore`. Each machine builds its own.
- The server on Linux runs from `~/ace-live`, built by `deploy.sh`. Nothing is edited there by hand.
- If something behaves like old code, check `BUILD_INFO.txt` first, then the commit in GitHub.

## One-time setup on Linux

    mkdir -p ~/ace-config
    cp <your current Config.js> ~/ace-config/Config.js
    cp <your current log4net.config> ~/ace-config/log4net.config   # the fixed one without asyncForwarder
    git clone https://github.com/AzraelTL/JawnTide.git ~/JawnTide
    chmod +x ~/JawnTide/Ops/deploy.sh
