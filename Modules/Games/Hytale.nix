{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.Juegos.hytale;
in
{
  options.Juegos.hytale.enable = lib.mkEnableOption "Hytale Launcher";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hytale-launcher
    ];
  };
}
