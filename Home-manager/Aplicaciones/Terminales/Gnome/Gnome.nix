{pkgs, ...}: {
  programs = {
    ptyxis = {
      enable = true;
      package = pkgs.ptyxis;
    };
  };
}
