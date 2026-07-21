# CLAUDE.md

Guidance for working in this repository — written for Claude Code (or anyone
landing in a fresh environment) to get productive fast.

## What this repo is

A collection of ready-made **Nix flake dev-shell templates**, one per language
or tool (`rust/`, `go/`, `python/`, `node/`, `haskell/`, …). Each subdirectory
has its own `flake.nix` exposing a `devShells.<system>.default` you enter with
`nix develop`. The root `flake.nix` registers every template so they can be
consumed with `nix flake init -t`.

## First: do you even have Nix?

Everything here needs `nix`. Many fresh environments — a new Claude Code web
session, a bare CI runner, a plain container — **don't have it**, and you can't
`nix develop` your way into installing it (that's circular). Bootstrap it with
the script in the `claude-code` template:

```bash
./claude-code/bootstrap.sh        # installs Nix, writes .nix-bootstrap-env.sh
. ./.nix-bootstrap-env.sh          # put `nix` on PATH in the current shell
nix --version                      # verify (expect 2.30.x)
```

The script is idempotent and picks the first method that works:

1. **Already installed** → nothing to do.
2. **nix-portable** (rootless single binary from GitHub) → preferred on a
   normal machine.
3. **Static tarball** from `releases.nixos.org`, installed single-user into
   `/nix` → the fallback that works in locked-down sandboxes.

See `claude-code/README.md` for details and tunables (`NIX_VERSION`,
`NP_PREFIX`, `ENV_FILE`).

> **Note for the Claude Code web sandbox:** the network policy proxy-gates
> GitHub to the session's own repo, so method 2 (nix-portable) fails there —
> but `cache.nixos.org` and `releases.nixos.org` are reachable, so method 3
> succeeds automatically. The bare install-script hosts (`nixos.org`,
> `install.determinate.systems`) are blocked, which is why this repo bootstraps
> from `releases.nixos.org` directly instead of `curl … | sh`. `/nix` lives in
> the ephemeral container and is gone next session, so re-run the bootstrap
> each time.

## Using the templates

Once `nix` is on PATH (remember to `. ./.nix-bootstrap-env.sh` in each new
shell):

```bash
# Enter a template's dev shell from a checkout of this repo:
nix develop ./rust
nix develop ./python --command bash -c 'python --version'

# Inspect what a flake provides:
nix flake show ./go

# Scaffold a new project elsewhere from a template:
nix flake init -t github:lessuselesss/nix-flake-dev-templates#rust
```

`nix develop` with no path uses the **root** flake's dev shell (Nix tooling:
`nixfmt`, etc.).

### direnv

Each template ships an `.envrc` containing `use flake`. With
[direnv](https://direnv.net/) installed, `cd` into a template directory and
`direnv allow` to enter/exit its shell automatically. `.direnv/` is gitignored.

## Repository layout

- `flake.nix` — root flake; registers all templates under `templates.*` and
  provides a dev shell + formatter.
- `<language>/` — one directory per template, each with `flake.nix`,
  `flake.lock`, and `.envrc`.
- `claude-code/` — Claude Code dev shell **plus `bootstrap.sh`** (the Nix
  bootstrapper) and `lib.nix` (helpers to layer Claude Code onto other shells).
- `empty/` — minimal template to copy when adding a new one.

## Conventions when editing templates

- Templates pin nixpkgs via FlakeHub (`inputs.nixpkgs.url =
  "https://flakehub.com/f/NixOS/nixpkgs/0.1";`). Match the surrounding style.
- Support all four systems: `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`,
  `aarch64-darwin` (see the `forEachSupportedSystem` helper in any template).
- Adding a template? Create `<name>/` (copy `empty/`), then register it in the
  root `flake.nix` under `templates`, keeping the alphabetical ordering.
- Format Nix with the repo formatter: `nix fmt` (or `nix run .#formatter`).

## Verifying a change

```bash
. ./.nix-bootstrap-env.sh
nix flake check ./<template>          # evaluate a single template
nix develop ./<template> --command true   # confirm the shell builds/enters
```

Builds here run **unsandboxed** (`sandbox = false`, no `nixbld` group) because
the bootstrap targets rootless/container environments. Cached substitutions
from `cache.nixos.org` are unaffected; be mindful only for from-source builds
that assume a pure sandbox.
