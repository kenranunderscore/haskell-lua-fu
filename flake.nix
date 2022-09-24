{
  description = "Trying out using Lua with Haskell";

  inputs.haskell-sdl2 = {
    url = "github:haskell-game/sdl2";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            haskellPackages = prev.haskell.packages.ghc92.override (old: {
              overrides =
                final.lib.composeExtensions (old.overrides or (_: _: { }))
                (hfinal: hprev: {
                  # need to use a recent version of sdl2, or we're
                  # running into bugs
                  sdl2 = final.haskell.lib.compose.overrideSrc {
                    src = inputs.haskell-sdl2;
                    version = "2.5.4.0";
                  } hprev.sdl2;
                });
            });
          })
        ];
      };
    in {
      devShells.${system}.default = pkgs.haskellPackages.shellFor {
        packages = _:
          [
            (pkgs.haskellPackages.callCabal2nix "haskell-lua-fu"
              (pkgs.lib.cleanSource ./.) { })
          ];
        nativeBuildInputs = with pkgs; [ cabal-install ghc ];
      };
    };
}
