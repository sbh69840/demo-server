{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-ghc-8.url = "github:nixos/nixpkgs/cf5e2d510316ae0e2e78486e28b79b1fa30799fa";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    common.url = "github:nammayatri/common";
    euler-hs = {
      url = "github:srid/euler-hs/ghc810--nixify";
    };
    euler-hs-ghc-8-8 = {
      url = "github:juspay/euler-hs/master";
      flake = false;
    };
    euler-hs-ghc9.url = "github:sbh69840/euler-hs/ghc924"; 
    euler-hs-ghc9.flake = false;
    sequelize.url = "github:juspay/haskell-sequelize/3abc8fe10edde3fd1c9a776ede81d057dc590341";
    sequelize.flake = false;
    sequelizeGhc9.url = "github:juspay/haskell-sequelize/31948e744e431320492031cfddd01e7a9896631d";
    sequelizeGhc9.flake = false;
    beam-mysql.url = "github:sbh69840/beam-mysql/a5085e921c61ac45bd9cb7b44947b42160ace5ef";
    beam-mysql.flake = false;
    word24.url = "github:winterland1989/word24/445f791e35ddc8098f05879dbcd07c41b115cb39";
    word24.flake = false;
    tinylog.url = "gitlab:arjunkathuria/tinylog/08d3b6066cd2f883e183b7cd01809d1711092d33";
    tinylog.flake = false;
    beam.url = "github:sbh69840/beam/e92f7ddf66f3ddbf9a76e25491c767eea9ca7186";
    beam.flake = false;
    hedis.url = "github:juspay/hedis/10e07f3242b6f522ec7b64bfbf6241fafd279978";
    hedis.flake = false;
    mason.url = "github:fumieval/mason/2ad57dca476f5b5990a2753b08435581bf9a214d";
    mason.flake = false;
    beam-ghc-8-8.url = "github:srid/beam/ghc810";
    beam-ghc-8-8.flake = false;
    beam-mysql-ghc-8-8.url = "github:juspay/beam-mysql/4c876ea2eae60bf3402d6f5c1ecb60a386fe3ace";
    beam-mysql-ghc-8-8.flake = false;
    hedis-ghc-8-8.url = "github:juspay/hedis/46ea0ea78e6d8d1a2b1a66e6f08078a37864ad80";
    hedis-ghc-8-8.flake = false;
    mysql-haskell.url = "github:juspay/mysql-haskell/788022d65538db422b02ecc0be138b862d2e5cee"; # https://github.com/winterland1989/mysql-haskell/pull/38
    mysql-haskell.flake = false;
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule inputs.common.flakeModules.ghc810 ./nix/ghc884.nix  ./nix/ghc8107.nix  ./nix/ghc924.nix ];

      perSystem = { self', pkgs, system, lib, config, ... }: {
        packages.default = self'.packages.ghc884-with-euler;
        devShells.cpp = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.gcc ];
          buildInputs = with pkgs; [ hiredis redis-plus-plus asio ];
        };
      };
    };
}
