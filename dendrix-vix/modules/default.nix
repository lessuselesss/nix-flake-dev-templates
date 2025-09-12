{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.dendrix.flakeModules.vix
  ];

  systems = import inputs.systems;
}