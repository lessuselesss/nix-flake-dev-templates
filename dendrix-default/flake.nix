{
  description = "Dendrix default template - community-driven composable Nix configurations";
  
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    dendrix.url = "github:vic/dendrix";
  };
  
  outputs = { nixpkgs, dendrix, ... }:
    dendrix.templates.default.outputs (dendrix.templates.default.inputs // { inherit nixpkgs; });
}