# ============================================================
# flake.nix (refactored with Overlay + DRY helper function)
# ============================================================
{
  description = "Home Manager configuration of wd15: laptop (pippi) + HPC cluster (mr-french)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aicommit2.url = "github:tak-bro/aicommit2";

    ## Zen Browser flake
    zen-browser.url = "github:youwen5/zen-browser-flake";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, aicommit2, zen-browser, ... }:
    let
      system = "x86_64-linux";

      # 1. Overlay to inject flake packages directly into pkgs
      overlays = [
        (final: prev: {
          zen-browser = zen-browser.packages.${system}.default;
          aicommit2 = aicommit2.packages.${system}.default;
        })
      ];

      # 2. Instantiate pkgs with allowUnfree and our custom overlay
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        inherit overlays;
      };

      unfreeModule = {
        nixpkgs.config.allowUnfree = true;
      };

      # 3. Helper function to eliminate duplication between targets
      mkHome = { module, isCluster }: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit isCluster inputs;
        };
        modules = [
          module
          unfreeModule
          agenix.homeManagerModules.default
        ];
      };
    in
    {
      homeConfigurations = {
        # home-manager switch --flake .#wd15   (laptop, pippi)
        wd15 = mkHome {
          module = ./laptop.nix;
          isCluster = false;
        };

        # home-manager switch --flake .#cluster   (mr-french)
        cluster = mkHome {
          module = ./cluster.nix;
          isCluster = true;
        };
      };
    };
}
