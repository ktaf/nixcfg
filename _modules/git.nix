{ ... }: {

  programs.git = {
    enable = true;
    config = {
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
