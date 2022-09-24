{
  description = "Trying out using Lua with Haskell";

  outputs = { self, nixpkgs }:
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
                  # jailbreak because of bytestring 0.11
                  sdl2 = final.haskell.lib.compose.doJailbreak hprev.sdl2;
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
