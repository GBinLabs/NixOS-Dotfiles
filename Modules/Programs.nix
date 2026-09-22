{ lib, pkgs, ... }:
let
  # Última versión mayor de Temurin empaquetada en el nixpkgs seleccionado.
  # No equivale al HEAD de OpenJDK: conserva las compilaciones de Adoptium.
  temurinNames = builtins.filter (name: builtins.match "temurin-bin-[0-9]+" name != null) (
    builtins.attrNames pkgs
  );
  latestTemurin = lib.last (lib.naturalSort temurinNames);
in
{
  programs = {
    java = {
      enable = true;
      package = pkgs.${latestTemurin};
    };
    nh = {
      enable = true;
      flake = "/home/bin/.GitHub/NixOS-Dotfiles";
    };
    nix-ld = {
      enable = true;
    };
  };
}
