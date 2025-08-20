{
  description = "A Nix-flake-based development environment for Claude Code";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";

  outputs =
    inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ nodejs ];

            shellHook = ''
              PREF_FILE="$PWD/.claude_choice"
              LAUNCH_MODE=""

              if [ -n "$CLAUDE_LAUNCH_MODE" ]; then
                LAUNCH_MODE="$CLAUDE_LAUNCH_MODE"
              elif [ -f "$PREF_FILE" ]; then
                LAUNCH_MODE=$(cat "$PREF_FILE")
              fi

              case "$LAUNCH_MODE" in
                "terminal")
                  echo "Opening terminal."
                  ;; 
                "claude")
                  echo "Launching Claude Code..."
                  claude &
                  ;; 
                *)
                  echo "No launch mode specified. Defaulting to terminal."
                  echo "To choose a mode, set CLAUDE_LAUNCH_MODE to 'terminal' or 'claude' in your .envrc, or create a .claude_choice file with 'terminal' or 'claude'."
                  echo "Example: echo 'export CLAUDE_LAUNCH_MODE=\"claude\"' >> .envrc"
                  ;; 
              esac
            '';
          };
        }
      );
    };
}