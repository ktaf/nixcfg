{ pkgs, user, ... }:

{
  nixpkgs = { config = { allowUnfree = true; }; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "25.11";

    packages = with pkgs; [ ];
  };

  programs.git = {
    enable = true;
    userName = "ktaf";
    userEmail = "kouroshtaf@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      protocol.keybase.allow = "always";
      pull.rebase = "false";
    };
  };
}
