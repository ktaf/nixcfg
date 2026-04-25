{ lib, options, ... }:
let
  settings = {
    user = {
      name = lib.mkDefault "ktaf";
      email = lib.mkDefault "kouroshtaf@gmail.com";
    };
    init.defaultBranch = lib.mkDefault "main";
    core.editor = lib.mkDefault "vim";
    protocol.keybase.allow = lib.mkDefault "always";
    pull.rebase = lib.mkDefault false;
  };
in
{

  programs.git = {
    enable = true;
  } // (if options.programs.git ? config then {
    config = settings;
  } else {
    settings = settings;
  });

}
