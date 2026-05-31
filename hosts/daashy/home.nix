{ pkgs, user, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

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
