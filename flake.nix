#============================================================
# flake.nix  (full file -- passes isCluster via extraSpecialArgs
# so bash.nix can branch on it)
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
  };

  outputs = { nixpkgs, home-manager, agenix, aicommit2, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      unfreeModule = {
        nixpkgs.config.allowUnfree = true;
      };
    in
    {
      homeConfigurations = {
        # home-manager switch --flake .#wd15   (laptop, pippi)
        wd15 = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            isCluster = false;
            aicommit2Pkg = aicommit2.packages.${system}.default;
          };
          modules = [ ./home.nix unfreeModule agenix.homeManagerModules.default ];
        };

        # home-manager switch --flake .#cluster   (mr-french)
        cluster = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            isCluster = true;
            aicommit2Pkg = aicommit2.packages.${system}.default;
          };
          modules = [ ./home-cluster.nix unfreeModule agenix.homeManagerModules.default ];
        };
      };
    };
}
