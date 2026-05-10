# rm-lock – Agent Guide

Pure-bash accidental deletion protection system. Zero dependencies.

## Key files

| File | Role |
|------|------|
| `scripts/rm-lock-lib.sh` | Core library — `rm_lock_enable()`, `rm_lock_check_arg()`, etc. |
| `scripts/rm-lock-utils.sh` | CLI utilities — `rm_lock_init()`, `rm_lock_add()`, etc. |
| `install.sh` | Installer — copies files, creates CLI dispatcher, updates shell config |
| `Makefile` | Optional automation wrapper around `install.sh` |

## How protection works

`rm_lock_enable()` defines a bash function `rm()` that shadows `/bin/rm`. In interactive shells only (`[[ $- != *i* ]]`), it walks the directory tree upward for `.rm-lock` files and blocks deletion of exact directory matches. Non-exact matches (contents, subdirs, files) pass through.

## Commands

### Installation (run from repo root)
```
bash install.sh                          # install
bash install.sh install --prefix ~/.config/rm-lock  # custom path
bash install.sh uninstall                # clean removal
bash install.sh status                   # verify installation
make install                             # same, via Makefile
make install PREFIX=~/.config/rm-lock    # custom path via make
```

### After install (reload shell first: `source ~/.bashrc`)
```
rm-lock init data cache models           # create .rm-lock
rm-lock add results                      # add dirs to protection
rm-lock remove cache                     # remove from protection
rm-lock list                             # show protected dirs
rm-lock status                           # show all protection (walks up tree)
rm-lock verify                           # check .rm-lock integrity
rm-lock disable                          # temporarily disable
rm-lock enable                           # re-enable
```

## Testing

No test file exists in the repo (`test-rm-lock.sh` referenced in docs is absent). `make test` will fail.

## Notable quirks

- **Test suite missing** — `test-rm-lock.sh` and `MODULAR_SETUP.md` are referenced in docs but not present.
- **Install modifies user shell config** — `install.sh` appends sourcing lines to `~/.bashrc` and `~/.zshrc`. Always warn an agent about this side effect.
- **Protection is interactive-shell only** — scripts bypass the `rm` override.
- **Path resolution** uses `realpath` first, falls back to `readlink -f`.
- **Custom prefix** set via `RM_LOCK_PREFIX` env var or `--prefix` flag.
- **Two branches**: `main` (stable) and `feat/rm-lock-shell` (feature work in progress).
