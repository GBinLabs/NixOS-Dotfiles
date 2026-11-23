{ config, lib, ... }:
let
  cfg = config.Capture.obs;
in
{
  options.Capture.obs = {
    enable = lib.mkEnableOption "OBS Studio y perfiles de grabación";

    host = lib.mkOption {
      type = lib.types.enum [
        "PC"
        "Netbook"
      ];
      default = "PC";
      description = "Selecciona los perfiles y escenas OBS de cada equipo";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [ ./OBS/Home.nix ];
  };
}
