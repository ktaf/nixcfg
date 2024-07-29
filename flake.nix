{
  description = "ktaf NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, nixos-hardware, ... }:
    let
      user = "kourosh";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        xps9510 = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./hosts/xps9510/configuration.nix
            nixos-hardware.nixosModules.dell-xps-15-9510
            nixos-hardware.nixosModules.dell-xps-15-9510-nvidia
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user} = import ./hosts/xps9510/home.nix;
              };
            }
          ];
        };
        lat7310 = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./hosts/lat7310/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user} = import ./hosts/lat7310/home.nix;
              };
            }
          ];
        };
        nixos-arvan = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./hosts/nixos-arvan/configuration.nix
          ];
        };
      };
    };
}

#nixos-24.05
