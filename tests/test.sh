#!/usr/bin/env bash
# test.sh — test suite for rm-lock

export RMLOCK_FILE=$(mktemp)
TESTDIR=$(mktemp -d)
PASS=0; FAIL=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RMLOCK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$RMLOCK_DIR/rm-lock.sh"

cleanup() { rm -f "$RMLOCK_FILE"; command rm -rf "$TESTDIR"; }
trap cleanup EXIT

ok()   { printf '  ✓ %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  ✗ %s\n' "$1"; FAIL=$((FAIL+1)); }

assert_ok() {
    local desc="$1"; shift
    if "$@" &>/dev/null 2>&1; then ok "$desc"; else fail "$desc"; fi
}
assert_fail() {
    local desc="$1"; shift
    if "$@" &>/dev/null 2>&1; then fail "$desc"; else ok "$desc"; fi
}

# ── setup ──────────────────────────────────────────────────────────────────

mkdir -p "$TESTDIR/data" "$TESTDIR/cache" "$TESTDIR/temp"
touch "$TESTDIR/data/file.txt" "$TESTDIR/cache/cache.db"

# ── add ────────────────────────────────────────────────────────────────────

echo; echo "[ add ]"

_rmlock_add "$TESTDIR/data" "$TESTDIR/cache" >/dev/null

assert_ok  "data written to lock file"   grep -qxF "$TESTDIR/data"  "$RMLOCK_FILE"
assert_ok  "cache written to lock file"  grep -qxF "$TESTDIR/cache" "$RMLOCK_FILE"

_rmlock_add "$TESTDIR/data" &>/dev/null
count=$(grep -cxF "$TESTDIR/data" "$RMLOCK_FILE")
[[ "$count" -eq 1 ]] && ok "double-add is a no-op" || fail "double-add is a no-op"

# ── list ───────────────────────────────────────────────────────────────────

echo; echo "[ list ]"

_rmlock_list > /tmp/_rmlock_test_list.txt
assert_ok "list shows data"  grep -q "$TESTDIR/data"  /tmp/_rmlock_test_list.txt
assert_ok "list shows cache" grep -q "$TESTDIR/cache" /tmp/_rmlock_test_list.txt
command rm -f /tmp/_rmlock_test_list.txt

# ── status ─────────────────────────────────────────────────────────────────

echo; echo "[ status ]"

_rmlock_status > /tmp/_rmlock_test_status.txt
assert_ok "status shows lock file path" grep -q "$RMLOCK_FILE" /tmp/_rmlock_test_status.txt
assert_ok "status shows entry count"    grep -q "2"            /tmp/_rmlock_test_status.txt
command rm -f /tmp/_rmlock_test_status.txt

# ── check logic ────────────────────────────────────────────────────────────

echo; echo "[ check ]"

_test_check() {
    local target="$1" want_blocked="$2"
    local blocked=0 line
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="${line//[[:space:]]/}"
        [[ -z "$line" ]] && continue
        [[ "$target" == "$line" ]] && blocked=1 && break
    done < "$RMLOCK_FILE"
    [[ "$blocked" -eq "$want_blocked" ]]
}

assert_ok  "exact match is blocked"   _test_check "$TESTDIR/data"          1
assert_ok  "cache is blocked"         _test_check "$TESTDIR/cache"         1
assert_ok  "unprotected is allowed"   _test_check "$TESTDIR/temp"          0
assert_ok  "subdir is allowed"        _test_check "$TESTDIR/data/file.txt" 0
assert_ok  "parent dir is allowed"    _test_check "$TESTDIR"               0

# ── remove ─────────────────────────────────────────────────────────────────

echo; echo "[ remove ]"

_rmlock_remove "$TESTDIR/cache" >/dev/null
assert_fail "cache removed from lock file" grep -qxF "$TESTDIR/cache" "$RMLOCK_FILE"
assert_ok   "data still in lock file"      grep -qxF "$TESTDIR/data"  "$RMLOCK_FILE"
assert_ok   "removed path is now allowed"  _test_check "$TESTDIR/cache" 0

# ── inline comments ────────────────────────────────────────────────────────

echo; echo "[ comments ]"

echo "$TESTDIR/temp # my temp dir" >> "$RMLOCK_FILE"
assert_ok "inline comment stripped, path matched" _test_check "$TESTDIR/temp" 1

# ── RMLOCK_FILE override ───────────────────────────────────────────────────

echo; echo "[ RMLOCK_FILE override ]"

altfile=$(mktemp)
RMLOCK_FILE="$altfile" _rmlock_add "$TESTDIR/cache" >/dev/null
assert_ok "alt lock file written" grep -qxF "$TESTDIR/cache" "$altfile"
command rm -f "$altfile"

# ── summary ────────────────────────────────────────────────────────────────

echo
echo "───────────────────────────────"
printf "  Passed: %d  Failed: %d\n" "$PASS" "$FAIL"
echo "───────────────────────────────"
[[ $FAIL -eq 0 ]]
