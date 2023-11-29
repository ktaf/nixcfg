{
  description = "ktaf-nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, nixos-hardware, ... }@inputs:
    let
      user = "kourosh";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        xps9510 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            nixos-hardware.nixosModules.dell-xps-15-9510
            nixos-hardware.nixosModules.dell-xps-15-9510-nvidia
            nixos-hardware.nixosModules.common-hidpi
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user} = import ./modules/home.nix;
              };
            }
          ];
        };
      };
    };
}

#nixos-24.05
