{
  description = "ktaf NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, nixos-hardware, nixGL, ... }:
    let
      user = "kourosh";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
    in {
      nixosConfigurations = {
        x1g12 = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./hosts/x1g12/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user; };
                users.${user} = import ./hosts/x1g12/home.nix;
              };
            }
          ];
        };
        arvanix = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./hosts/arvanix/configuration.nix
          ];
        };
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
      };
    homeConfigurations."kourosh" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit self nixpkgs;
      };
      modules = [./hosts/x1g12/home.nix];
    };
    };
}

#nixos-24.05
