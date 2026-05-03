# Terminal Navigation Basics — Mason Mystery

A terminal-based mystery game for introductory computer science / digital literacy students.
Students SSH into a server and use Linux command-line navigation to explore a directory-based
"school" and solve the mystery of the missing Comets Championship Banner.

## Overview

**Mystery:** The Mason High School championship banner has gone missing from Room B112
over the weekend. Students must navigate the school's file system, gather clues, and identify
the culprit.

**Learning objectives:** By completing this activity, students practice:

| Command / Concept   | Skill                                              |
|---------------------|----------------------------------------------------|
| `pwd`               | Print working directory                            |
| `ls`, `ls -lAh`     | List files, including hidden files with details    |
| `cd <dir>`          | Navigate into a directory                          |
| `cd ..`, `cd ../..` | Navigate up one or two levels                      |
| `cd ~`              | Navigate to home directory                         |
| `cd /`              | Navigate to root                                   |
| `cd -`              | Jump back to previous directory                    |
| `cat`               | Read file contents                                 |
| `whoami`            | Check current user                                 |
| `mkdir`, `touch`    | Create directories and files                       |
| `rm`, `rm -r`       | Delete files and directories                       |
| `echo`              | Write text to a file                               |
| `history`           | Review command history                             |
| Tab autocomplete    | Complete long filenames                            |
| ↑ / ↓ arrows        | Navigate command history                           |
| `!!` (bang-bang)    | Repeat last command                                |

---

## Repository Structure

```
.
├── README.md                — This file (teacher/admin documentation)
├── LESSON.md                — Student-facing lesson and instructions
├── game/                    — Mystery game files (deployed to /opt/comets-mystery/)
│   ├── welcome.txt
│   └── school/
│       ├── map.txt
│       ├── B112/            — Mr. Rice's classroom (starting point)
│       ├── hallway/
│       ├── office/
│       │   └── principals/
│       │       ├── brown_office/
│       │       ├── drake_office/
│       │       └── rompies_office/
│       ├── gym/
│       │   └── trophy_room/
│       └── cafeteria/
└── setup/
    ├── setup_game.sh        — Deploys game files to /opt/comets-mystery/
    ├── create_users.sh      — Creates student users from a CSV
    ├── reset_homes.sh       — Resets student home directories between classes
    └── students.csv.example — Example CSV format for student accounts
```

---

## Server Setup

### Requirements

- Linux server or container (Ubuntu/Debian recommended)
- Root access for initial setup
- SSH server running (`openssh-server`)
- Students connect via SSH using username/password

A lightweight LXC container on Proxmox or a Docker container with an SSH server works well.

### Quick Start

1. Clone this repository on the server:
   ```bash
   git clone <repo-url> /tmp/comets-mystery-setup
   cd /tmp/comets-mystery-setup
   ```

2. Deploy the game files to `/opt/comets-mystery/`:
   ```bash
   sudo bash setup/setup_game.sh
   ```

3. Create your student CSV (it is gitignored so passwords stay off GitHub):
   ```bash
   cp setup/students.csv.example setup/students.csv
   # Edit setup/students.csv with your real students and passwords
   sudo bash setup/create_users.sh setup/students.csv
   ```
   See `setup/students.csv.example` for the expected format.

4. Share the server IP and each student's username/password.

### Student Permissions

| Location                    | Permissions                                       |
|-----------------------------|---------------------------------------------------|
| `/opt/comets-mystery/`      | World-readable, not writable (read-only clues)   |
| `/home/<username>/`         | `700` — only that student can read/write          |
| `~/solution/answer.txt`     | Created by student; invisible to other students   |

Students can navigate and read every game file but cannot modify them or delete clues for
classmates. Each student's home directory is private, so solution files are not visible to peers.

### Resetting Between Classes

To wipe and recreate each student's `scratch/` and remove any existing `solution/` directory:
```bash
sudo bash setup/reset_homes.sh setup/students.csv.example
```

To re-deploy game files (safe to re-run at any time):
```bash
sudo bash setup/setup_game.sh
```

---

## The Mystery — SPOILER

Go and find [SPOLERS.md](#) if you really need the help, and don't like fun. 

Ideally: only scroll as far through the spoilers as you must, to get un-stuck.

---

## Teaching Notes

- **Tab autocomplete:** The directory `locker_2024_championship_season/` in the hallway is
  intentionally long. Give students a hint about TAB before they get frustrated.
- **Hidden files:** Two key clues (`.janitor_log.txt` and `.draft_memo.txt`) require `ls -lAh`.
  Let students get stuck briefly before hinting — this is a core teaching moment.
- **`cd -`:** After going deep into `office/principals/brown_office/`, students need to navigate
  to `gym/`. Use this as the moment to demonstrate `cd -`.
- **`!!` (bang-bang):** In the final solution step, students are prompted to re-run `cat` on
  their answer file to confirm it looks right. This is the natural place to introduce `!!`.

---

## License

See LICENSE file. Created for classroom use by Mr. Rice, Mason High School.
Adapt freely — just update the names, room number, and mascot for your school!
