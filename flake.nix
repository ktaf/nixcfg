{
  description = "ktaf NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cyan-skillfish-governor.url = "github:ktaf/cyan-skillfish-governor";
  };
  outputs = { self, nixpkgs, home-manager, nixos-hardware, nix-index-database, ... } @ inputs:
    let
      user = "kourosh";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Build a NixOS host from ./hosts/<name>. A sibling home.nix, if present,
      # is wired in as a Home Manager module automatically.
      makeNixosSystem = name: extraModules:
        let
          dir = ./hosts + "/${name}";
          homeModules = lib.optionals (builtins.pathExists (dir + "/home.nix")) [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user inputs; };
                users.${user} = import (dir + "/home.nix");
              };
            }
          ];
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user inputs; };
          modules = [ (dir + "/configuration.nix") ] ++ homeModules ++ extraModules;
        };

      # hostname -> host-specific NixOS modules. The name must match the
      # directory under ./hosts.
      hosts = {
        homie = [ ];
        arvanix = [ ];
        dellakam = [ ];
        daashy = [ ];
        x1g12 = [ nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen ];
        bc-250 = [ inputs.cyan-skillfish-governor.nixosModules.default ];
        t14g5 = [ ];
      };
    in
    {
      nixosConfigurations = lib.mapAttrs makeNixosSystem hosts;

      homeConfigurations.ktaf = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit self nixpkgs inputs user; };
        modules = [
          nix-index-database.homeModules.nix-index
          ./hosts/t14g5-hm/home.nix
          ./_modules_hm/gui
          ./_modules_hm/terminal
          # ./_modules_hm/syncthing.nix
        ];
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
#nixos-26.05
