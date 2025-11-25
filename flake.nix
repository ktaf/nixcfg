{
  description = "ktaf NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-master, home-manager, nixos-hardware, nix-index-database, ... } @ inputs:
    let
      user = "kourosh";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
        overlays = [
          # Only these attrs come from nixpkgs-master; everything else stays on unstable
          (final: prev:
            let
              pkgsMaster = import nixpkgs-master {
                inherit system;
                config = prev.config;
              };
            in
            {
              # terraform-docs = pkgsMaster.terraform-docs;
              awscli2 = pkgsMaster.awscli2;
            }
          )
        ];
      };
      lib = nixpkgs.lib;
      makeNixosSystem = hostModule: { extraModules ? [ ] }:
        let
          dir = builtins.dirOf hostModule;
          hasHome = builtins.pathExists (dir + "/home.nix");
          homeModules =
            if hasHome then [
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit user; };
                  users.${user} = import (dir + "/home.nix");
                };
              }
            ] else [ ];
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [ hostModule ] ++ homeModules ++ extraModules;
        };
    in
    {
      homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit self nixpkgs inputs;
        };
        modules = [
          nix-index-database.homeModules.nix-index
          ./hosts/x1g12-HM/home.nix
          ./_modules_hm/gui
          ./_modules_hm/terminal
          ./_modules_hm/syncthing.nix
        ];
      };
      nixosConfigurations = {
        homie = makeNixosSystem ./hosts/homie/configuration.nix { };
        arvanix = makeNixosSystem ./hosts/arvanix/configuration.nix { };
        x1g12 = makeNixosSystem ./hosts/x1g12/configuration.nix {
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
          ];
        };
        ed800 = makeNixosSystem ./hosts/ed800/configuration.nix { };
        dellakam = makeNixosSystem ./hosts/dellakam/configuration.nix { };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
#nixos-25.11
