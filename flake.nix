{
  description = "Home Manager configuration of wd15";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      homeConfigurations."wd15" = home-manager.lib.homeManagerConfiguration {
        # 1. We pass the raw nixpkgs input so Home Manager can instantiate it
        pkgs = nixpkgs.legacyPackages.${system};

        # 2. We pass configuration modules
        modules = [
          ./home.nix

          # 3. We configure nixpkgs here instead of in the 'let' block
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
}
