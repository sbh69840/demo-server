{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    common.url = "github:nammayatri/common";
    euler-hs.url = "github:srid/euler-hs/ghc810--nixify";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ ./haskell ./cpp ];

      perSystem = { self', pkgs, system, lib, config, ... }: {
        devShells.default = pkgs.mkShell {
          inputsFrom = 
            [
              self'.devShells.with-cpp
              config.haskellProjects.default.outputs.devShell
            ];
        };
      };
    };
}
