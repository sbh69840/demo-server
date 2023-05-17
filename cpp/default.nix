
{ ... }:

{
  perSystem = { pkgs, lib, ... }: {
    packages.with-cpp = pkgs.stdenv.mkDerivation rec {
      name = "with-cpp";
      src = lib.cleanSourceWith {
        src = ./.;
        filter = name: _: builtins.baseNameOf name == "main.cpp";
      };
      buildInputs = with pkgs; [ gcc hiredis redis-plus-plus asio ];
      buildPhase = ''
        mkdir -p $out/bin
        cd $src
        g++ -O2 main.cpp -o $out/bin/${name} -lhiredis -lredis++
      '';
    };

    devShells.with-cpp = pkgs.mkShell {
      name = "with-cpp";
      nativeBuildInputs = [ pkgs.gcc ];
      buildInputs = with pkgs; [ hiredis redis-plus-plus asio ];
    };
  };
}
