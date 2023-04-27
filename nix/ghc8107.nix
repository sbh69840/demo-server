{ inputs, ... }:
{
  perSystem = { self', pkgs, system, lib, config, ... }: {
    haskellProjects.ghc8107 = {
      imports = [
        inputs.euler-hs.haskellFlakeProjectModules.output
      ];
      basePackages = config.haskellProjects.ghc810.outputs.finalPackages;

      # Dependency overrides go here. See https://haskell.flake.page/dependency
      source-overrides = { 
        lens-aeson = "1.1.1";
      };
      overrides = self: super: with pkgs.haskell.lib; { euler-hs = dontHaddock (dontCheck (self.callCabal2nix "euler-hs" "${inputs.euler-hs}" {})); };

      devShell = {
       tools = hp: { fourmolu = hp.fourmolu; ghcid = hp.ghcid; };
       hlsCheck.enable = true;
      };
    };
  };
}
