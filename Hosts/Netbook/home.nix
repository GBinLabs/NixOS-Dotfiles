_: {
  imports = [ ../../Home-manager/default.nix ];

  Discord.enable = true;

  git-config = {
    enable = true;
    keyFile = "~/.ssh/id_ed25519";
  };

  ssh-config = {
    enable = true;
    pcKeyFile = "~/.ssh/pc_ed25519";
  };

  home = {
    username = "bin";
    homeDirectory = "/home/bin";
    stateVersion = "24.11";
  };

  manual.manpages.enable = false;

  programs.home-manager.enable = true;
}
