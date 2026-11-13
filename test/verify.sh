#!/usr/bin/env bash
# shellcheck disable=SC2015  # ok/bad never fail, so A && B || C is safe here
# Post-install checks. Run inside the container (or on any machine) after install.sh.
# Commands are checked through an interactive zsh so the PATH built by .zshrc is what is tested.
set -o nounset -o pipefail

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; fail=1; }
check() { # check <description> <command...>
    local desc=$1; shift
    if "$@" &>/dev/null; then ok "$desc"; else bad "$desc"; fi
}
inzsh() { zsh -ic "$1" 2>/dev/null; }

echo "== commands on PATH (via zsh) =="
for c in zsh git tmux nvim fzf rg fd lazygit delta oh-my-posh asdf node python ruby go aws jq tree-sitter cargo; do
    check "$c" inzsh "command -v $c"
done

echo "== symlinks into the repo =="
lazygit_cfg="$(inzsh 'lazygit --print-config-dir' | tr -d '\r')/config.yml"
for l in ~/.zshrc ~/.tmux.conf ~/.config/nvim ~/.config/ghostty \
         ~/.config/git/ignore ~/.tool-versions "$lazygit_cfg"; do
    target="$(readlink -f "$l" 2>/dev/null || true)"
    if [[ "$target" == "$DOTFILES"/* ]]; then ok "$l"; else bad "$l -> ${target:-missing}"; fi
done

echo "== pinned runtimes match asdf/.tool-versions =="
want() { awk -v n="$1" '$1==n {print $2}' "$DOTFILES/asdf/.tool-versions"; }
[[ "$(inzsh 'node -v' | tr -d '\r')" == "v$(want nodejs)" ]] && ok "node $(want nodejs)" || bad "node != $(want nodejs)"
[[ "$(inzsh 'python -V' | tr -d '\r')" == "Python $(want python)" ]] && ok "python $(want python)" || bad "python != $(want python)"
[[ "$(inzsh 'ruby -e "print RUBY_VERSION"' | tr -d '\r')" == "$(want ruby)" ]] && ok "ruby $(want ruby)" || bad "ruby != $(want ruby)"
[[ "$(inzsh 'go env GOVERSION' | tr -d '\r')" == "go$(want golang)" ]] && ok "go $(want golang)" || bad "go != $(want golang)"

echo "== git =="
[[ "$(git config --get core.pager)" == "delta" ]] && ok "core.pager = delta" || bad "core.pager != delta"
[[ "$(git config --get pull.rebase)" == "true" ]] && ok "pull.rebase = true" || bad "pull.rebase != true"

echo "== zsh =="
# Without a tty, zsh-vi-mode always prints "can't change option: zle"; that is a test artifact, not a bug
startup="$(zsh -ic exit 2>&1 </dev/null | grep -v "can't change option: zle")"
[[ -z "$startup" ]] && ok "interactive startup prints nothing" || { bad "interactive startup output:"; printf '%s\n' "$startup" | sed 's/^/         /'; }
for p in zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting; do
    check "plugin $p" test -d ~/.oh-my-zsh/custom/plugins/$p
done

echo "== tmux =="
tmux_out="$(tmux -L verify -f ~/.tmux.conf new-session -d 2>&1)"
[[ -z "$tmux_out" ]] && ok "tmux.conf loads without errors" || { bad "tmux.conf errors:"; printf '%s\n' "$tmux_out" | sed 's/^/         /'; }
[[ "$(tmux -L verify show -gv history-limit 2>/dev/null)" == "50000" ]] && ok "history-limit 50000" || bad "history-limit != 50000"
tmux -L verify kill-server &>/dev/null
for p in tpm tmux-resurrect tmux-continuum; do
    check "tmux plugin $p" test -d ~/.tmux/plugins/$p
done

echo "== neovim =="
# Bootstraps lazy.nvim and installs plugins on a clean machine, which is the real first-run path
check "nvim headless first run + plugin sync" timeout 900 nvim --headless "+Lazy! sync" +qa

echo
if (( fail )); then echo "FAILED"; exit 1; fi
echo "PASSED"
