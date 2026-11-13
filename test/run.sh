#!/usr/bin/env bash
# Test install.sh on a clean Ubuntu container: install, install again (idempotency), then verify.
#
#   test/run.sh            run the full test
#   test/run.sh --shell    run install.sh once, then drop into zsh to poke around
#
# Tests the working tree (including uncommitted changes), not what is on the remote.
# Env: PLATFORM=linux/amd64 forces an architecture (default: host arch).
set -o errexit -o pipefail -o nounset

cd "$(dirname "${BASH_SOURCE[0]}")/.."

IMAGE=dotfiles-test-base
MODE="${1:-test}"

docker build -q -t "$IMAGE" -f test/Dockerfile test >/dev/null

args=()
[[ -n "${PLATFORM:-}" ]] && args+=(--platform "$PLATFORM")
[[ -t 0 ]] && args+=(-i)
[[ -t 1 ]] && args+=(-t)

# The repo is mounted read-only and copied in, so runs never touch the host tree.
# zsh/private is removed: it can hold secrets that must not leak into the container.
docker run --rm ${args[@]+"${args[@]}"} -e MODE="$MODE" -v "$PWD":/src:ro "$IMAGE" bash -c '
    set -e
    cp -R /src ~/.dotfiles
    rm -rf ~/.dotfiles/zsh/private ~/.dotfiles/nvim/lazy-lock.json
    cd ~/.dotfiles
    ./install.sh
    if [[ "$MODE" == "--shell" ]]; then
        exec zsh -i
    fi
    echo "== second run (idempotency) =="
    ./install.sh
    ./test/verify.sh
'
