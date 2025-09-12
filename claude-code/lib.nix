# Claude Code integration library for nix-flake-dev-templates
{ pkgs, lib }:

rec {
  # Core Claude Code functionality that can be composed with any shell
  claudeCodeShell = baseShell: baseShell.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.nodejs ];
    
    shellHook = (oldAttrs.shellHook or "") + ''
      # Claude Code Integration
      PREF_FILE="$PWD/.claude_choice"
      LAUNCH_MODE=""

      if [ -n "$CLAUDE_LAUNCH_MODE" ]; then
        LAUNCH_MODE="$CLAUDE_LAUNCH_MODE"
      elif [ -f "$PREF_FILE" ]; then
        LAUNCH_MODE=$(cat "$PREF_FILE")
      fi

      case "$LAUNCH_MODE" in
        "terminal")
          echo "Claude Code: Terminal mode enabled."
          ;; 
        "claude")
          echo "Claude Code: Launching Claude Code..."
          if command -v claude >/dev/null 2>&1; then
            claude &
          else
            echo "Claude Code: 'claude' command not found. Please install Claude Code CLI."
          fi
          ;; 
        *)
          echo "Claude Code: Available via opt-in."
          echo "Set CLAUDE_LAUNCH_MODE='claude' or create .claude_choice file with 'claude' to auto-launch."
          echo "Example: echo 'claude' > .claude_choice"
          ;; 
      esac
    '';
  });

  # Creates a development shell with optional Claude Code integration
  mkDevShell = { packages ? [], shellHook ? "", enableClaudeCode ? false, ... }@args:
    let
      baseShell = pkgs.mkShell (removeAttrs args ["enableClaudeCode"] // {
        inherit packages shellHook;
      });
    in
    if enableClaudeCode then claudeCodeShell baseShell else baseShell;

  # Template-specific CLAUDE.md generator
  generateClaudeMd = { language, packages ? [], extraContent ? "" }:
    let
      packageList = lib.concatStringsSep ", " (map (pkg: "`${pkg.pname or pkg.name or (toString pkg)}`") packages);
      languageSpecific = {
        "go" = ''
## Go Development with Claude Code

### Available Tools
${packageList}

### Common Tasks
- `go run .` - Run the application
- `go test ./...` - Run all tests
- `go mod tidy` - Clean up dependencies
- `go build` - Build the application

### Claude Code Integration
This environment includes Claude Code integration for AI-assisted development.
        '';
        "rust" = ''
## Rust Development with Claude Code

### Available Tools
${packageList}

### Common Tasks
- `cargo run` - Run the application
- `cargo test` - Run tests
- `cargo build --release` - Release build
- `cargo clippy` - Linting
- `cargo fmt` - Formatting

### Claude Code Integration
This environment includes Claude Code integration for AI-assisted development.
        '';
        "node" = ''
## Node.js Development with Claude Code

### Available Tools
${packageList}

### Common Tasks
- `npm install` - Install dependencies
- `npm run dev` - Development server
- `npm test` - Run tests
- `npm run build` - Production build

### Claude Code Integration
This environment includes Claude Code integration for AI-assisted development.
        '';
      };
    in
    ''
# ${language} Development Environment

This development environment provides ${language} tooling with optional Claude Code integration.

${languageSpecific.${language} or ''
## ${language} Development with Claude Code

### Available Tools
${packageList}

### Claude Code Integration
This environment includes Claude Code integration for AI-assisted development.
''}

## Claude Code Usage

### Activation
```bash
# Auto-launch Claude Code on shell entry
echo 'claude' > .claude_choice

# Or set environment variable
export CLAUDE_LAUNCH_MODE=claude

# Terminal-only mode
export CLAUDE_LAUNCH_MODE=terminal
```

### Environment Variables
- `CLAUDE_LAUNCH_MODE`: Controls Claude Code behavior ('claude', 'terminal', or unset)
- `.claude_choice` file: Persistent preference for the project

${extraContent}

## Getting Started

1. Enter the development shell: `nix develop`
2. Optionally enable Claude Code: `echo 'claude' > .claude_choice`
3. Start developing with AI assistance!
    '';
}