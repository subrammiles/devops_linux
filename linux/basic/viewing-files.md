# Viewing and Editing Files

`cat`, `less`, `head`, `tail`, `wc`, `nano`, `vim`

## `cat` — print a whole file

```bash
cat file.txt               # Print file
cat -n file.txt            # With line numbers
cat a.txt b.txt > all.txt  # Concatenate files into one
```

Best for short files. For long files use `less`.

## `less` — scroll through a file

```bash
less /var/log/syslog
```

| Key | Action |
|-----|--------|
| `Space` / `b` | Page down / page up |
| `↑` `↓` | Line by line |
| `g` / `G` | Start / end of file |
| `/word` | Search forward (`n` next, `N` previous) |
| `q` | Quit |

## `head` and `tail`

```bash
head file.txt              # First 10 lines
head -n 20 file.txt        # First 20 lines
tail file.txt              # Last 10 lines
tail -n 50 app.log         # Last 50 lines
tail -f /var/log/syslog    # Follow: keep printing new lines (Ctrl+C to stop)
```

`tail -f` is one of the most-used commands in DevOps: watch a log while you reproduce a problem.

## `wc` — count

```bash
wc file.txt       # lines, words, bytes
wc -l file.txt    # just lines
```

## Editing files in the terminal

### nano (easiest)

```bash
nano notes.txt
```

Shortcuts are shown at the bottom (`^` means Ctrl): `Ctrl+O` save, `Ctrl+X` exit, `Ctrl+W` search, `Ctrl+K` cut line, `Ctrl+U` paste.

### vim (powerful, available almost everywhere)

```bash
vim notes.txt
```

Vim has *modes*. Survival guide:

| Key | Action |
|-----|--------|
| `i` | Enter insert mode (type text) |
| `Esc` | Back to normal mode |
| `:w` | Save |
| `:q` | Quit |
| `:wq` or `:x` | Save and quit |
| `:q!` | Quit without saving |
| `dd` | Delete (cut) line |
| `yy` / `p` | Copy line / paste |
| `u` | Undo |
| `/text` | Search |

Run `vimtutor` for a 30-minute interactive lesson.

## Practice

1. `head -n 5 /etc/passwd`
2. `wc -l /etc/passwd` — how many accounts are on the system?
3. Open a second terminal and run `tail -f /var/log/syslog` (or `journalctl -f`).
4. Create a file with `nano hello.txt`, save it, and `cat` it.

Previous: [files-and-directories.md](files-and-directories.md) · Next: [permissions.md](permissions.md)
