# ============================================================
# packages-cluster.nix
# CLI tools + a LIGHT python env for notebook viewing only.
# Deliberately no numpy/scipy/pandas/matplotlib/julia/haskell here --
# per your call, scientific environments belong in per-project
# flake.nix files (am-dt-modeling, automated-rocrate, etc.), not
# baked into the home-manager profile.
# ============================================================
{ pkgs, aicommit2Pkg, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    htop
    tree
    jq
    pwgen
    nixpkgs-review
    github-cli
    jujutsu
    aicommit2Pkg

    # Quick-install / environment tools -- not scientific stacks
    # themselves, just the means to spin one up fast when needed.
    uv
    poetry
    micromamba

    # Light python: enough to view/run a notebook someone hands you,
    # not a scientific stack. Actual project deps stay in project flakes.
    (python313.withPackages (p: [
      p.jupyter
      p.ipython
    ]))
  ];

  # NOTE: MPI, Julia, numpy/scipy/pandas, Haskell etc. intentionally
  # excluded. Per your call: scientific/project-specific environments
  # live in individual flake.nix files alongside the relevant workflow
  # (am-dt-modeling, phase-field-schema/automated-rocrate), not in the
  # home-manager profile. This also sidesteps the earlier MPI-shadowing
  # concern entirely.
}
