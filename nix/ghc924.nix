{ inputs, ...}:
{
  perSystem = { self', pkgs, system, lib, config, ... }: {
    haskellProjects.ghc924 = {
      basePackages = pkgs.haskell.packages.ghc924;
      source-overrides = { 
        euler-hs = inputs.euler-hs-ghc9;
        sequelize = inputs.sequelizeGhc9;
        beam-mysql = inputs.beam-mysql;
        word24 = inputs.word24;
        tinylog = inputs.tinylog;
        aeson = "2.1.1.0";
        beam-sqlite = inputs.beam + /beam-sqlite;
        beam-migrate = inputs.beam + /beam-migrate;
        beam-postgres = inputs.beam + /beam-postgres;
        beam-core = inputs.beam + /beam-core;
        hedis = inputs.hedis;
      };
      overrides = self: super:
        with pkgs.haskell.lib.compose;
        lib.mapAttrs (k: v: lib.pipe super.${k} v) {
          euler-hs = [ dontCheck dontHaddock doJailbreak ];
          binary-parsers = [ unmarkBroken doJailbreak ];
          word24 = [ dontCheck ];
          wire-streams = [ doJailbreak ];
          mysql-haskell = [ doJailbreak ];
          beam-core = [ doJailbreak ];
          beam-migrate = [ doJailbreak ];
          beam-sqlite = [ doJailbreak ];
          beam-postgres = [ doJailbreak dontCheck ];
          hedis = [ dontCheck ];
          stylish-haskell = [ doJailbreak ];
        };

      devShell = {
       tools = hp: { fourmolu = hp.fourmolu; ghcid = hp.ghcid; };
       hlsCheck.enable = true;
      };
    };
  };
}
