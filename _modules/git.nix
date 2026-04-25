{ pkgs, user, ... }: {

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
