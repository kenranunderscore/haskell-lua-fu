{
  description = "Trying out using Lua with Haskell";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
