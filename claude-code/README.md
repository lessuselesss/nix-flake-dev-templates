# claude-code

A dev environment for working with [Claude Code](https://claude.com/claude-code),
plus a **`bootstrap.sh`** that installs a working Nix from scratch — for
environments (a fresh Claude Code web session, a bare CI runner, a container)
that don't have Nix yet.

## `bootstrap.sh` — get Nix from zero

You can't `nix develop` a template if you don't have `nix`. This script fixes
that. It's a plain shell script (not a flake — that would be circular) and
tries, in order:

1. **Already installed?** — if `nix` works, it does nothing.
2. **nix-portable** — a rootless single static binary from GitHub. Preferred
   on a normal machine; needs GitHub reachable.
3. **Static tarball** — the official build from `releases.nixos.org`,
   installed single-user into `/nix`. This is the fallback that works inside
   the Claude Code web sandbox, where GitHub is proxy-gated but
   `cache.nixos.org` / `releases.nixos.org` are open.

```bash
./claude-code/bootstrap.sh       # install Nix + write .nix-bootstrap-env.sh
. ./.nix-bootstrap-env.sh         # put nix on PATH in the current shell
nix --version                     # verify
nix develop ./claude-code         # enter this dev shell
```

The script is idempotent — re-running it just re-activates an existing
install. Tunables via env vars: `NIX_VERSION`, `NP_PREFIX`, `ENV_FILE`.

## The dev shell

Once Nix is available, `nix develop` here gives you a shell with `nodejs` and
an opt-in Claude Code launcher. Choose how it behaves:

```bash
echo 'claude' > .claude_choice          # auto-launch `claude` on entry
# or
export CLAUDE_LAUNCH_MODE=terminal      # terminal only (no auto-launch)
```

`lib.nix` also exposes helpers (`claudeCodeShell`, `mkDevShell`,
`generateClaudeMd`) for layering Claude Code integration onto other templates.

## Using it as a template

```bash
nix flake init -t github:lessuselesss/nix-flake-dev-templates#claude-code
```
