{ pkgs, ... }: {
  programs.bash = {
    completion.enable = true;
    blesh.enable = true;

    interactiveShellInit = ''
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash \
        --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/gruvbox.omp.json)"

      HISTSIZE=10000
      HISTFILESIZE=20000
      HISTCONTROL=ignoreboth:erasedups

      shopt -s histappend
    '';
  };

  users.defaultUserShell = pkgs.bashInteractive;

  environment.systemPackages = with pkgs; [
    oh-my-posh
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}

