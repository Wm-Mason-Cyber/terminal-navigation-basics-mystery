# The Case of the Missing NCL Banner
### A Terminal Navigation Mystery — Mason High School

> [!TIP]
> **Your mission:** Use the Linux command line to investigate the disappearance of the
> Mason High School NCL Banner from Room B112. Navigate the school's file
> system, gather evidence, identify the culprit, and submit your solution.

The school is a **file system**. Rooms and locations are **directories (folders)**. Clues are
**files**. You navigate using terminal commands — the same ones professionals use every day.

---

## Command Reference

Keep this open as you investigate. You will use every command on this list.

### Finding Your Way

| Command     | What It Does                                          | Example            |
|-------------|-------------------------------------------------------|--------------------|
| `pwd`       | **P**rint **w**orking **d**irectory — shows where you are | `pwd`          |
| `ls`        | **L**i**s**t files and folders here                   | `ls`               |
| `ls -lAh`   | List **A**ll files (even hidden ones) with details    | `ls -lAh`          |
| `whoami`    | Show your username                                    | `whoami`           |
| `history`   | Show all commands you have typed this session         | `history`          |

### Moving Around

| Command       | What It Does                                  | Example              |
|---------------|-----------------------------------------------|----------------------|
| `cd <name>`   | Enter a directory                             | `cd school`          |
| `cd ..`       | Go **up** one level                           | `cd ..`              |
| `cd ../..`    | Go **up** two levels at once                  | `cd ../..`           |
| `cd ~`        | Go to your **home** directory                 | `cd ~`               |
| `cd /`        | Go to the **root** of the entire file system  | `cd /`               |
| `cd -`        | Jump **back** to where you just were          | `cd -`               |

### Reading Files

| Command       | What It Does                      | Example               |
|---------------|-----------------------------------|-----------------------|
| `cat <file>`  | Print a file's contents to screen | `cat clue.txt`        |

### Creating and Removing

| Command        | What It Does                                    | Example                    |
|----------------|-------------------------------------------------|----------------------------|
| `mkdir <name>` | Create a new directory                          | `mkdir solution`           |
| `touch <file>` | Create a new empty file                         | `touch answer.txt`         |
| `rm <file>`    | Delete a file                                   | `rm junk.txt`              |
| `rm -r <dir>`  | Delete a directory and everything inside it     | `rm -r scratch`            |
| `echo "text"`  | Print text (or write it into a file with `>>`)  | `echo "hello" >> file.txt` |

### Shortcuts

| Shortcut  | What It Does                             |
|-----------|------------------------------------------|
| **TAB**   | Autocomplete a filename or directory     |
| **↑ / ↓** | Scroll through previous commands         |
| `!!`      | Repeat your **last** command exactly     |

> **TAB tip:** If a folder name is long, type the first 3–4 letters and press TAB.
> The shell will complete it for you. Try it — it saves a lot of typing!

---

## Starting Your Investigation

### Step 1 — Get oriented

You are already logged in. Run these two commands first:

```bash
whoami
pwd
```

Note your username and where you start. You will need this later.

### Step 2 — Navigate to the mystery

```bash
cd /opt/comets-mystery
ls
cat welcome.txt
```

### Step 3 — Enter the school and get the map

```bash
cd school
cat map.txt
```

### Step 4 — Begin in Room B112

That is where the banner was last seen.

```bash
cd B112
ls
```

Read every file you find. Each one contains clues — and hints about where to look next.

> **Important:** Some clues are in **hidden files**. Hidden files start with a dot (`.`)
> and do not appear with a plain `ls`. Use `ls -lAh` to reveal them!

---

## Investigation Tips

- **Lost?** Run `pwd` to see exactly where you are. Then `cat /opt/comets-mystery/school/map.txt`
  to see the full school layout.
- **Long directory names?** Press TAB after the first few letters to autocomplete.
- **Want to go back?** `cd -` jumps back to the directory you were just in.
- **Reread a file?** Press **↑** to bring back your last command, or type `!!` and press Enter.
- **Suspects:** There are three principals. Check all their offices — not everyone is guilty,
  but alibis matter.

---

## Submitting Your Solution

Once you have solved the mystery, follow these steps **exactly** to create and submit your
solution file. Your command history is part of the grade — it proves you did the work.

### Step 1 — Review your history

```bash
history
```

Scroll through it. Can you retrace your investigation? Make sure you used the commands
from the reference table above before you submit.

### Step 2 — Go to your home directory

```bash
cd ~
pwd
```

`pwd` should show `/home/YOUR_USERNAME`.

### Step 3 — Clean up your scratch directory

A `scratch/` folder was set up in your home directory. Remove it:

```bash
ls
rm -r scratch
ls
```

Confirm it is gone before moving on.

### Step 4 — Create your solution directory and file

```bash
mkdir solution
touch solution/answer.txt
```

### Step 5 — Write your answer

Use `echo` with `>>` to **append** lines to your file. Fill in the blanks:

```bash
echo "STUDENT: your-username-here"           >> solution/answer.txt
echo "CULPRIT: [full name of the person]"    >> solution/answer.txt
echo "LOCATION: [where the banner ended up]" >> solution/answer.txt
echo "EVIDENCE: [list the key clues you found — be specific]" >> solution/answer.txt
```

### Step 6 — Append your command history

```bash
history >> solution/answer.txt
```

### Step 7 — Read your solution file to confirm it looks right

```bash
cat solution/answer.txt
```

Want to read it again? Try `!!` — it repeats your last command instantly.

### Step 8 — You are done!

Call Mr. Rice over, or keep your terminal open showing `cat solution/answer.txt`.

**You are finished when:**
- `cat ~/solution/answer.txt` shows your answer and your history
- Your history log contains evidence of all the commands from the checklist below

---

## Grading Checklist

Your `solution/answer.txt` history log will be checked for evidence that you used each of
the following. Use this as a self-check before you submit.

- [ ] `whoami` — run at the start
- [ ] `pwd` — used to check your location
- [ ] `ls` — used to explore directories
- [ ] `ls -lAh` — used to find hidden files (used at least twice)
- [ ] `cd <directory>` — navigated into rooms/directories
- [ ] `cd ..` or `cd ../..` — navigated up at least one level
- [ ] `cd ~` — returned to your home directory
- [ ] `cd -` — used the "go back" shortcut at least once
- [ ] `cat` — read clue files
- [ ] `mkdir` — created the solution directory
- [ ] `touch` — created the answer file
- [ ] `rm -r` — removed the scratch directory
- [ ] `echo` — wrote your solution answer
- [ ] `history` — appended to the solution file
- [ ] Tab autocomplete — used on a long directory name (check: was it in the hallway?)
- [ ] Correct culprit identified in your answer

---

*Go Comets! Good luck, Detective.*
*— Mr. Rice, Room B112*
