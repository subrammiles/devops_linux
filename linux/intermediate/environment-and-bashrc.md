# Environment Variables and Shell Configuration

## What environment variables are

Environment variables are named values that every process inherits from its parent. Programs read them for settings such as paths, credentials and modes.

```bash
env                     # List all environment variables
printenv HOME           # Print one
echo "$PATH"            # Same, using the shell
```

Common ones:

| Variable | Meaning |
|----------|---------|
| `HOME`   | Your home directory |
| `USER`   | Your username |
| `PATH`   | Directories searched for commands, separated by `:` |
| `SHELL`  | Your login shell |
| `PWD`    | Current directory |
| `EDITOR` | Default editor for tools like `crontab -e` and `git commit` |
| `LANG`   | Language and locale |

## Shell variables vs environment variables

```bash
greeting="hi"           # Shell variable: only this shell sees it
bash -c 'echo $greeting'   # Prints nothing: the child doesn't inherit it

export greeting="hi"    # Environment variable: children inherit it
bash -c 'echo $greeting'   # hi
```

Set a variable for one command only:

```bash
APP_ENV=staging ./run.sh
```

Remove a variable:

```bash
unset greeting
```

## `PATH`: how commands are found

When you type `kubectl`, the shell looks through each directory in `PATH`, left to right, and runs the first match.

```bash
echo "$PATH" | tr ':' '\n'      # One directory per line
which kubectl                   # Which file would run
```

Add your own scripts directory:

```bash
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"   # Put it first so it takes priority
```

To run a program in the current directory that isn't in `PATH`, use `./program`.

## Startup files

Bash reads different files depending on how it starts:

| File | When it runs |
|------|--------------|
| `/etc/profile`, `~/.profile` (or `~/.bash_profile`) | Login shells, such as SSH logins and the first desktop login |
| `~/.bashrc` | Every new interactive terminal |
| `/etc/environment` | System-wide variables for all users (simple `KEY=value` lines) |

In practice, put your aliases, functions and `PATH` changes in `~/.bashrc`. On Ubuntu, `~/.profile` already loads `~/.bashrc`.

After editing, reload it in the current terminal:

```bash
source ~/.bashrc        # or: . ~/.bashrc
```

## A useful `~/.bashrc` section

```bash
# --- my settings ---
export EDITOR=nano
export PATH="$HOME/bin:$PATH"

# Aliases: short names for longer commands
alias ll='ls -lah'
alias ..='cd ..'
alias gs='git status'
alias k='kubectl'
alias ports='sudo ss -tulpn'

# Function: make a directory and enter it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Bigger history, without duplicates
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
```

```bash
alias              # List current aliases
unalias ll         # Remove one
\ls                # Run the real ls, bypassing an alias
```

## `.env` files

Applications often keep settings in a `.env` file:

```text
DB_HOST=localhost
DB_PORT=5432
```

Load it into the current shell:

```bash
set -a              # Export every variable that gets set
source .env
set +a
```

Never commit `.env` files that contain passwords or keys. Add `.env` to `.gitignore`.

## Command history shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Search history as you type (press again for older matches) |
| `!!`     | Repeat the last command (`sudo !!` reruns it with sudo) |
| `!$`     | Last argument of the previous command |
| `history` | Show numbered history; `!42` reruns command 42 |
| `Ctrl+A` / `Ctrl+E` | Jump to start / end of line |
| `Ctrl+U` / `Ctrl+K` | Delete to start / end of line |
| `Ctrl+L` | Clear the screen |

## Practice

1. Run `echo "$PATH" | tr ':' '\n'` and find where `ls` lives with `which ls`.
2. Add `alias ll='ls -lah'` to `~/.bashrc`, run `source ~/.bashrc`, then try `ll`.
3. Create `~/bin/hello` with `echo hello` inside, make it executable, add `~/bin` to `PATH`, and run `hello` from any directory.
4. Compare `x=1; bash -c 'echo $x'` with `export x=1; bash -c 'echo $x'`.

Next: [archives-and-compression.md](archives-and-compression.md)
