{ pkgs, user, ... }: {

  # Shell Package
  users.users.${user}.shell = pkgs.zsh;

  # Enable ZSH and oh-my-zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    setOptions = [
      "correct"
      # "nocaseglob" # Case insensitive globbing
      "rcexpandparam" # Array expension with parameters
      "nocheckjobs" # Don't warn about running processes when exiting
      "numericglobsort" # Sort filenames numerically when it makes sense
      "nobeep" # No beep
      "appendhistory" # Immediately append history instead of overwriting
      "histignorealldups" # If a new command is a duplicate, remove the older one
      "inc_append_history" # save commands are added to the history immediately, otherwise only when shell exits.
      "histignorespace"
    ];
    shellAliases = {
      ls = "eza";
      ll = "eza -lha";
      tree = "eza --tree";
      cat = "bat";
      k = "kubectl";
      kx = "kubectx";
      tf = "terraform";
      ssh = "TERM=xterm-256color ssh";
      rebase =
        "'git checkout master && git pull && git checkout - && git rebase master'";
      switch = "sudo nixos-rebuild switch --flake .#xps9510";
      switchu = "sudo nixos-rebuild switch --upgrade --flake .#xps9510";
      clean = "sudo nix-collect-garbage -d";
      cleanold = "sudo nix-collect-garbage --delete-old";
      cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
    };
    ohMyZsh = { enable = true; };
  };

  environment.etc.zshrc.text = builtins.readFile ../extras/zshrc;
}
