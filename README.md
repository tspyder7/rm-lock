# rm-lock

A global nuke guard for `rm`. Prevents accidental `rm -rf` on paths you care about.

---

## How it works

One global file at `~/.rm-lock`. Each line is an absolute path. When you run `rm`,
it checks if the resolved path is listed — exact match only, no child protection.

```
~/.rm-lock
────────────────────────────────────
/home/user/projects/data
/home/user/projects/models
/mnt/nas/backups
```

---

## Install

### Debian / Ubuntu (recommended)

Download and install the `.deb` from [releases](https://github.com/tspyder7/rm-lock/releases):

```bash
curl -fsSLO https://github.com/tspyder7/rm-lock/releases/latest/download/rm-lock_1.0.0_all.deb
sudo dpkg -i rm-lock_1.0.0_all.deb
source ~/.bashrc
```

**Uninstall:**
```bash
sudo dpkg -r rm-lock
```

The `.deb` package will:
- Install to `/usr/local/lib/rm-lock`
- Automatically patch `~/.bashrc` and `~/.zshrc` with the sourcing line
- Preserve your `~/.rm-lock` file on uninstall

### From source (development)

```bash
git clone https://github.com/tspyder7/rm-lock.git
cd rm-lock
make install        # installs to ~/.local/lib/rm-lock
source ~/.bashrc
```

**Uninstall:**
```bash
bash scripts/install/uninstall.sh   # removes installation, keeps ~/.rm-lock
```

Custom install path:
```bash
make install INSTALL_DIR=/usr/local/lib/rm-lock
```

### Build .deb locally

If you want to build the `.deb` package yourself:

```bash
# Install fpm (one-time)
gem install fpm

# Build the package
bash scripts/deb/build.sh        # creates dist/rm-lock_1.0.0_all.deb
bash scripts/deb/build.sh 2.0.0  # create specific version

# Install your build
sudo dpkg -i dist/rm-lock_2.0.0_all.deb
```

---

## Usage

```bash
rm-lock add ~/projects/data           # protect a path
rm-lock add ~/projects/data ~/models  # protect multiple at once
rm-lock remove ~/projects/old-data    # unprotect
rm-lock list                          # show all protected paths
rm-lock status                        # lock file path + override status
rm-lock edit                          # open ~/.rm-lock in $EDITOR
```

---

## What gets blocked vs allowed

```bash
rm-lock add ~/projects/data

rm -rf ~/projects/data          # ❌ blocked — exact match
rm    ~/projects/data           # ❌ blocked
rm -rf ~/projects/data/subdir   # ✅ allowed — only exact path protected
rm    ~/projects/data/file.txt  # ✅ allowed
rm -rf ~/projects               # ✅ allowed — parent is not protected
rm -rf ~/projects/other         # ✅ allowed — different path
```

---

## File structure

```
rm-lock/
├── rm-lock.sh        # entry point — source this in your shell config
├── Makefile          # make install / uninstall / test
├── dist/             # built distribution artifacts (.deb packages)
├── lib/
│   ├── check.sh      # rm() override — reads ~/.rm-lock on every rm call
│   ├── add.sh        # rm-lock add
│   ├── remove.sh     # rm-lock remove
│   ├── list.sh       # rm-lock list
│   ├── status.sh     # rm-lock status
│   └── edit.sh       # rm-lock edit
├── scripts/
│   ├── install/
│   │   ├── install.sh        # install to ~/.local/lib/rm-lock
│   │   └── uninstall.sh      # remove installation, keep ~/.rm-lock
│   ├── deb/
│   │   ├── build.sh          # build .deb package
│   │   ├── postinst.sh       # post-install (patches shell configs)
│   │   └── prerm.sh          # pre-remove (cleans shell configs)
└── tests/
    └── test.sh               # test suite
```

---

## Lock file format

Plain text, one absolute path per line. Comments and blank lines are ignored.

```
# databases
/home/user/postgres/data

# project inputs
/home/user/projects/raw-data
/home/user/projects/models   # expensive to retrain
```

---

## Override lock file path

```bash
export RMLOCK_FILE=/custom/path/.rm-lock
```

---

## Notes

- Interactive shell only — scripts and CI bypass the `rm` override automatically
  (checked via `$-` containing `i`)
- Exact match only — subdirectories and parent directories are not blocked
- Hardlinks and bind mounts are not detected — this is a convenience guard, not a security boundary
