# rm-lock – Agent Guide

Pure-bash accidental deletion protection system. Zero dependencies.

## Key files

| File | Role |
|------|------|
| `rm-lock.sh` | Entry point — sources all lib modules, registers `rm-lock` CLI and `rm()` override |
| `lib/*.sh` | Module scripts — `check.sh`, `add.sh`, `remove.sh`, `list.sh`, `status.sh`, `edit.sh`, `help.sh` |
| `scripts/install/install.sh` | Installer — copies files to target dir, creates `/etc/profile.d/rm-lock.sh` |
| `Makefile` | Optional automation wrapper around install/uninstall/test |
| `tests/test.sh` | Test suite |

## How protection works

`rm-lock.sh` sources `lib/check.sh` which defines a bash function `rm()` that shadows `/bin/rm`. In interactive shells only (`[[ $- != *i* ]]`), it checks `~/.rm-lock` (or `$RMLOCK_FILE`) for an exact match of the target path. Non-exact matches (subdirs, contained files, parents) pass through.

## Commands

### Installation (run from repo root)
```
make install                             # install to ~/.local/lib/rm-lock
make install INSTALL_DIR=/custom/path    # custom path
bash scripts/install/install.sh          # same, via script directly
make uninstall                           # clean removal
bash scripts/install/uninstall.sh        # same, via script
```

### After install (open new shell or `source /etc/profile`)
```
rm-lock add ~/projects/data              # protect a path
rm-lock add ~/data ~/models              # protect multiple paths
rm-lock remove ~/projects/old            # remove from protection
rm-lock list                             # show all protected paths
rm-lock status                           # show lock file info
rm-lock edit                             # open ~/.rm-lock in $EDITOR
```

## Testing

```
make test
```

Or directly:
```
bash tests/test.sh
```

## Notable quirks

- **Install creates `/etc/profile.d/rm-lock.sh`** — requires `sudo` for system-wide shell integration.
- **Test suite exists** at `tests/test.sh` — runs via `make test` or `bash tests/test.sh`.
- **Protection is interactive-shell only** — scripts and CI bypass the `rm` override (checked via `$-` containing `i`).
- **Exact match only** — only the literal path in the lock file is blocked; subdirectories, children, and parents pass through.
- **Paths stored as-is** — no `realpath` resolution; matching is literal; symlinks, hardlinks, and bind mounts not detected.
- **Lock file path** overridden via `RMLOCK_FILE` env var (defaults to `~/.rm-lock`).
- **Install dir** set via `INSTALL_DIR` arg to `make` or `install.sh` (defaults to `~/.local/lib/rm-lock`).
- **Two branches**: `main` (stable) and `feat/rm-lock-shell` (feature work in progress).
