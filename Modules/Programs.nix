{pkgs, ...}: {
  programs = {
    java = {
      enable = true;
      package = pkgs.temurin-bin-25;
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
      };
      flake = "/home/bin/.GitHub/NixOS-Dotfiles";
    };
    nix-ld = {
      enable = true;
    };
    xwayland = {
      enable = false;
    };
  };
}
