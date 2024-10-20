{ ... }:{

  # Enable ZSH and oh-my-zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile ../extras/zshrc;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = { enable = true; };
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
        "'git checkout main && git pull && git checkout - && git rebase main'";
      nixhm = "home-manager switch --flake .#kourosh";
      #switch = "sudo nixos-rebuild switch --flake .#xps9510";
      #switchu = "sudo nixos-rebuild switch --upgrade --flake .#xps9510";
      clean = "sudo nix-collect-garbage -d";
      cleanold = "sudo nix-collect-garbage --delete-old";
      #cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
    };
  };
}
