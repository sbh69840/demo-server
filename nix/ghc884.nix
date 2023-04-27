{ inputs, ... }:
{
perSystem = { self', pkgs, system, lib, config, ... }: {
  haskellProjects.ghc884 =
  let
    # Taken from: https://github.com/nammayatri/common/blob/9bcce05a676cb6ce50f267ddb538e714caa73fd8/nix/ghc810.nix#L9-L19
    # A function that enables us to write `foo = [ dontCheck ]` instead of `foo =
    # lib.pipe super.foo [ dontCheck ]` in haskell-flake's `overrides`.
    compilePipe = f: self: super:
      lib.mapAttrs
        (name: value:
          if lib.isList value then
            lib.pipe super.${name} value
          else
            value
        )
        (f self super);
  in
  {
    basePackages = inputs.nixpkgs-ghc-8.legacyPackages.${system}.haskell.packages.ghc884;
    source-overrides = {
      # Dependencies from Hackage
      aeson = "1.5.6.0";
      http2 = "3.0.2";
      euler-hs = inputs.euler-hs-ghc-8-8;
      sequelize = inputs.sequelize;
      mason = "0.2.3";
      beam-mysql = inputs.beam-mysql-ghc-8-8;
      beam-sqlite = inputs.beam-ghc-8-8 + /beam-sqlite;
      beam-migrate = inputs.beam-ghc-8-8 + /beam-migrate;
      beam-postgres = inputs.beam-ghc-8-8 + /beam-postgres;
      beam-core = inputs.beam-ghc-8-8 + /beam-core;
      hedis = inputs.hedis-ghc-8-8;
      mysql-haskell = inputs.mysql-haskell;
    };
    overrides = compilePipe (self: super: with pkgs.haskell.lib.compose; {
      beam-mysql = [ dontCheck unmarkBroken doJailbreak ];
      word24 = [ unmarkBroken ];
      servant-mock = [ unmarkBroken dontCheck doJailbreak ];
      beam-core = [ doJailbreak ];
      beam-migrate = [ doJailbreak ];
      beam-sqlite = [ doJailbreak ];
      beam-postgres = [ doJailbreak dontCheck ];
      hedis = [ dontCheck ];
      aeson = [ doJailbreak ];
      http2 = [ dontCheck ];
      mysql-haskell = [ dontCheck doJailbreak ];
      sequelize = [ dontCheck ];
      euler-hs = [ doJailbreak dontCheck dontHaddock ];
    });
  };
};
}
