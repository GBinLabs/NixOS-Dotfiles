{ config, lib, ... }:
{
  imports = [
    ./Steam.nix
    ./FreesmLauncher.nix
    ./Gamescope.nix
    ./LSFG-VK.nix
    ./MangoHud.nix
    ./Hytale.nix
    ./Environment.nix
  ];

  options.Juegos.enable = lib.mkEnableOption "Perfil completo de juegos";

  config.Juegos = {
    steam.enable = lib.mkDefault config.Juegos.enable;
    freesmlauncher.enable = lib.mkDefault config.Juegos.enable;
    gamescope.enable = lib.mkDefault config.Juegos.enable;
    mangohud.enable = lib.mkDefault config.Juegos.enable;
    hytale.enable = lib.mkDefault config.Juegos.enable;
    environment.enable = lib.mkDefault config.Juegos.enable;
    LSFG-VK.enable = lib.mkDefault config.Juegos.enable;
  };
}
