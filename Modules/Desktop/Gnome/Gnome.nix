{pkgs, ...}: {
  services = {
    displayManager = {
      gdm = {
        enable = true;
        banner = "¡Hola!";
        autoSuspend = true;
        debug = false;
      };
      defaultSession = "gnome";
    };
    desktopManager.gnome.enable = true;
    gnome = {
      core-apps.enable = false;
      localsearch.enable = false;
      tinysparql.enable = false;
    };
  };

  environment = {
    gnome.excludePackages = [
      pkgs.gnome-tour
      pkgs.gnome-user-docs
    ];
    shells = with pkgs; [zsh];
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      GNOME = ["org.gnome.Ptyxis.desktop"];
      default = ["org.gnome.Ptyxis.desktop"];
    };
  };
}
