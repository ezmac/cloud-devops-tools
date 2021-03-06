# cloud/devops type tools

General no warranties attached repo for tools I use from time to time. I need a stash for them that isn't spread across my file system. PRs welcome.  Drop me a note if you find them useful.

 - install.sh - symlink these tools into _my_ path.  Default is `~/.local/bin`. First argument is an override of where it installs.  Simple script, read it to understand.  Trims .sh suffix when symlinking for pretty on your terminal.

 - ssmgrep.sh - tool to apply grep to all ssm param store parameters and show matches
   Example: `ssmgrep old.mysql-server-domain.com`

 - ssmedit.sh - tool that uses $EDITOR to open and write back an SSM parameter.  In theory, should work with atom or whatever, so long as you have EDITOR set.
   Example: `ssmedit --profile sandbox -d -f /apps/node-app/dev/.env`

 - ssmls.sh - list parameters by path outputting full key/path only.  Defaults to /
   Example: `ssmls --profile sandbox /apps/`

## How to:

If you don't care about the details and aren't opinionated about where files go in your home directory, do this:
```
./init.sh
# if init.sh tells you to run a command, please do so.
./install.sh
# Edit your ~/.environmental_variables to set values
```

### If you're opinionated:

Both init.sh and install.sh take the install directory as their first argument; do whatever you want with that.




## TODO

 - ssmcat.sh - tool to concat a parameter's contents and stdout.

 - ssmtee.sh - emulate tee but for ssm parameter.
   should write back with whatever...

   The goal of these two is to be able to pipeline ssm operations.
  something like this:
  ```
     for i in `...`; do
       ssmcat $i | sed -i 's/asdf/hjkl/g' |ssmtee $i
     done
   ```

 - ssmfind.sh - tool to find ssm parameters by properties, kind of like the `find` command in linux.
   - ssmfind -name \*myapp\*
   - ssmfind [-mtime, -newer, etc]
 - refactoring:
   - there's enough common in these that I shouldn't repeat it.  Each tool with the ssm prefix takes an optional profile and uses aws environment.  code should be central so I don't duplicate.

## Help and tool contributions welcome
Send me a PR or an issue.
I'm trying to keep this pure shell and awscli, but if the tool uses a common enough language, I'd consider inclusion.
