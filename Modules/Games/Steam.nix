{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.Juegos.steam;
in
{
  options.Juegos.steam = {
    enable = lib.mkEnableOption "Steam y compatibilidad Proton";

    usuario = lib.mkOption {
      type = lib.types.str;
      default = "bin";
      example = "usuario";
      description = "Usuario propietario de la biblioteca de Steam en /home.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      platformOptimizations.enable = true;
      extraCompatPackages = with pkgs; [
        proton-cachyos_x86_64_v3
      ];
    };

    systemd.tmpfiles.rules = [
      "d /home/${cfg.usuario}/Games 0755 ${cfg.usuario} users -"
      "d /home/${cfg.usuario}/Games/SteamLibrary 0755 ${cfg.usuario} users -"
    ];
  };
}
