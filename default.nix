{
  compiler ? "ghc94",
  pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive.3364b5b117f65fe1ce65a3cdd5612a078a3b31e3.tar.gz";
    sha256 = "sha256-Bs6/5LpvYp379qVqGt9mXxxx9GSE789k3oFc+OAL07M=";
  }) {
    config = {
      allowBroken = false;
      allowUnfree = true;
    };

    overlays = [
      (self: super: {
        libbase64 = self.callPackage ./libbase64.nix {};
      })
    ];
  },
}:

let
  hsPkgs = pkgs.haskell.packages.${compiler};
  hsLib = pkgs.haskell.lib;

  aklomp = hsPkgs.developPackage {
    name = "aklomp";
    root = ./.;


    modifier = drv: hsLib.overrideCabal drv (old: {
      librarySystemDepends = (old.librarySystemDepends or []) ++ [pkgs.libbase64];

      configureFlags = (old.configureFlags or []) ++ [
        "--extra-lib-dirs=${pkgs.libbase64}/lib"
        "--extra-include-dirs=${pkgs.libbase64}/include"
      ];
    });
  };
in
{
  inherit aklomp;
}
