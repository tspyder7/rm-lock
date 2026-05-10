#!/usr/bin/env bash
# lib/edit.sh — open ~/.rm-lock in $EDITOR

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_edit() {
    touch "$RMLOCK_FILE"
    "${EDITOR:-vi}" "$RMLOCK_FILE"
}
