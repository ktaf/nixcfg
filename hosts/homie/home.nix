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
    settings = {
      user = {
        name = "ktaf";
        email = "kouroshtaf@gmail.com";
      };
      init.defaultBranch = "main";
      core.editor = "vim";
      protocol.keybase.allow = "always";
      pull.rebase = false;
    };
  };
}
