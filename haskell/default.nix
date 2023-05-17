{ inputs, ... }:
{
  imports = [ inputs.haskell-flake.flakeModule inputs.common.flakeModules.ghc810 ];
  perSystem = { self', pkgs, system, lib, config, ... }: {
    haskellProjects.default = {
      imports = [
        inputs.euler-hs.haskellFlakeProjectModules.output
      ];
      basePackages = config.haskellProjects.ghc810.outputs.finalPackages;

      overrides = self: super: with pkgs.haskell.lib; { euler-hs = dontHaddock (dontCheck (self.callCabal2nix "euler-hs" "${inputs.euler-hs}" {})); };
      projectRoot = ./.;
    };
  };
}
