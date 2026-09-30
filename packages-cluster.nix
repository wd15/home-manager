{ pkgs, ... }:

{
  imports = [ ./packages-common.nix ];

  home.packages = with pkgs; [
    # Light python: enough to view/run a notebook someone hands you.
    # Actual project deps (OpenFOAM, PyVista, Julia, etc.) stay in project flakes.
    (python313.withPackages (p: [
      p.jupyter
      p.ipython
    ]))
  ];
}
