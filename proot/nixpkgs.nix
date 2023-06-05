{
  pkgs ? import <nixpkgs> {},
  ...
}:

with builtins;
let
  overlay = curr: prev: {
    talloc = prev.talloc.overrideAttrs (old: {
      wafConfigureFlags = old.wafConfigureFlags ++ [
        "--disable-python"
      ];
    });
  };
  overlayedPkgs = import pkgs.path { overlays = [overlay]; inherit (pkgs) system; };
  static = overlayedPkgs.pkgsStatic;
  proot = static.proot.override { enablePython = false; };
in
proot.overrideAttrs (old:{
  src = pkgs.fetchFromGitHub {
    repo = "proot";
    owner = "proot-me";
    rev = "5f780cba57ce7ce557a389e1572e0d30026fcbca";
    sha256 = "sha256-BVA7fQOw1PpB/OFtbojJhws+unI3XN69qfB2SBPrA0Y=";
  };
  nativeBuildInputs = with static; old.nativeBuildInputs ++ [
    libarchive.dev pkg-config
  ];
  PKG_CONFIG_PATH = [
    "${static.libarchive.dev}/lib/pkgconfig"
  ];
})
