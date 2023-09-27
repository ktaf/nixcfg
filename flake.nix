{
  description = "ktaf-nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      user = "kourosh";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        ${user} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = import ./modules/home.nix;
            }
          ];
        };
      };
    };
}

#nixos-23.05

