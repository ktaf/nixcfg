{ ... }: {

  # Enable ZSH and oh-my-zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = builtins.readFile ../../extras/zshrc;
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
      tg = "terragrunt";
      ssh = "TERM=xterm-256color ssh";
      rebase = "git checkout main && git pull && git checkout - && git rebase main";
      nixhm = "home-manager switch --flake .#kourosh";
      deadnix = "nix run github:astro/deadnix -- -eq .";
      wayload = "rm ~/.config/waybar/config && cp ~/nixcfg/.config/waybar/config ~/.config/waybar/config && systemctl --user restart waybar";
      clean = "nix-collect-garbage -d";
      cleanold = "nix-collect-garbage --delete-old";
    };
  };
}
