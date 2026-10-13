sudo apt update
sudo apt install mysql-server

## Linux command-line and shell scripting basics

These commands are useful when working in a terminal and writing simple Bash scripts.

### Moving around and listing files

```bash
pwd                 # Show the current directory
ls                  # List files and directories
ls -la              # Include hidden files and show details
cd /path/to/folder  # Change to a directory
cd ..               # Move up one directory
cd ~                # Go to your home directory
```

### Working with files and folders

```bash
mkdir notes                 # Create a directory
touch notes/todo.txt        # Create an empty file (or update its timestamp)
cat notes/todo.txt          # Print a file's contents
cp source.txt copy.txt      # Copy a file
mv old-name.txt new.txt     # Move or rename a file
```

Use `rm filename` to delete a file. Deletion with `rm` is usually permanent, so check the path before running it.

### Permissions with `chmod`

`chmod` changes file permissions. Add execute permission to a script so you can run it directly:

```bash
chmod +x hello.sh
./hello.sh
```

You can also run a script through Bash without changing its execute permission:

```bash
bash hello.sh
```

### A first Bash script

Save this as `hello.sh`:

```bash
#!/usr/bin/env bash

name="Linux learner"
echo "Hello, $name!"
```

The first line selects Bash, and `echo` prints text. Run it with `bash hello.sh`, or make it executable with `chmod +x hello.sh` and run `./hello.sh`.
