#!/bin/bash
# DEB pre-remove script

utility_cleanup() {
    utils=("add" "check" "edit" "help" "list" "remove" "status")

    for util in "{$utils[@]}"; do
        unset -f "_rmlock_$util";
    done
}

cleanup() {
    PROFILED_FILE="/etc/profile.d/rm-lock.sh"
    rm -f "$PROFILED_FILE"
    unset -f "rm-lock"
    utility_cleanup

    echo "rm-lock uninstalled"
}

cleanup
