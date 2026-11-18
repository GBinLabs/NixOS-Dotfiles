{ config, lib, ... }:
let
  cfg = config.Capture.obs;
in
{
  options.Capture.obs.enable = lib.mkEnableOption "OBS Studio y perfiles de grabación";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ./OBS/Home.nix
    ];
  };
}
